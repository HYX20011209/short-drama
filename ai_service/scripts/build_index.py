#!/usr/bin/env python3
"""
Build FAISS index for drama semantic search (English-first).
- Source: MySQL (via env) or CSV
- Text fields: title + description (extendable)
- Model: BAAI/bge-small-en-v1.5 (local, fast, English)
- Index: FAISS IndexFlatIP with normalized embeddings (cosine similarity)
Outputs:
- <out_dir>/faiss.index
- <out_dir>/metadata.jsonl
- <out_dir>/stats.json
"""

import argparse
import json
import math
import os
import re
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from tqdm import tqdm

try:
    import faiss  # type: ignore
except Exception as e:
    raise RuntimeError("FAISS is required. Please install faiss-cpu.") from e

from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer

# -----------------------------
# Utilities
# -----------------------------

def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)

def normalize_whitespace(s: str) -> str:
    s = re.sub(r"\s+", " ", s or "").strip()
    return s

def clean_text(s: str) -> str:
    # Basic cleaning; extend as needed (strip HTML, etc.)
    s = s.replace("\u3000", " ")
    s = normalize_whitespace(s)
    return s

def chunk_by_sentences(text: str, max_chars: int, overlap_chars: int) -> List[str]:
    """
    Split text into sentence-based chunks with optional overlap by repeating last sentence.
    """
    text = clean_text(text)
    if not text:
        return []

    # Simple English sentence splitter
    sentences = re.split(r"(?<=[\.\!\?])\s+", text)
    chunks = []
    cur = ""

    for sent in sentences:
        sent = normalize_whitespace(sent)
        if not sent:
            continue
        if len(cur) + 1 + len(sent) <= max_chars:
            cur = f"{cur} {sent}".strip() if cur else sent
        else:
            if cur:
                chunks.append(cur)
            # start new chunk; add overlap: repeat last sentence of previous chunk if available
            cur = sent
    if cur:
        chunks.append(cur)

    if overlap_chars > 0 and len(chunks) > 1:
        # Implement simple overlap by prepending a tail of previous chunk
        overlapped = []
        prev_tail = ""
        for i, c in enumerate(chunks):
            if i > 0:
                # take tail from previous
                tail = prev_tail[-overlap_chars:]
                c = normalize_whitespace(f"{tail} {c}")
            overlapped.append(c)
            prev_tail = c
        chunks = overlapped

    return chunks

def pick_first_present(cols: List[str], candidates: List[str]) -> Optional[str]:
    for c in candidates:
        if c in cols:
            return c
    return None

def normalize_dataframe(df_raw: pd.DataFrame) -> pd.DataFrame:
    """
    Map source columns to normalized schema: id, title, description, category
    Accept both camelCase and snake_case variants; fallback if missing.
    """
    cols = df_raw.columns.tolist()

    id_col = pick_first_present(cols, ["id", "ID", "dramaId", "drama_id"])
    title_col = pick_first_present(cols, ["title", "name", "Title"])
    desc_col = pick_first_present(cols, ["description", "desc", "synopsis", "overview"])
    cat_col = pick_first_present(cols, ["category", "tags", "genre", "Category"])

    if not id_col or not title_col:
        raise ValueError(f"Required columns not found. Have: {cols}. Need at least id/title.")

    df = pd.DataFrame({
        "id": df_raw[id_col],
        "title": df_raw[title_col],
        "description": df_raw[desc_col] if desc_col in df_raw else "",
        "category": df_raw[cat_col] if cat_col in df_raw else "",
    })

    # Ensure types and cleaning
    df["id"] = df["id"]
    for col in ["title", "description", "category"]:
        df[col] = df[col].astype(str).map(clean_text)

    # Drop empty titles
    df = df[df["title"].map(lambda x: len(x) > 0)]
    df = df.reset_index(drop=True)
    return df

# -----------------------------
# Data loading
# -----------------------------

def load_from_mysql(table: str, limit: Optional[int] = None) -> pd.DataFrame:
    """Load data from MySQL using env vars (DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME)."""
    load_dotenv(override=True)
    host = os.getenv("DB_HOST", "127.0.0.1")
    port = int(os.getenv("DB_PORT", "3306"))
    user = os.getenv("DB_USER", "root")
    password = os.getenv("DB_PASSWORD", "")
    db = os.getenv("DB_NAME", "short_drama")

    from sqlalchemy import create_engine, text  # lazy import
    uri = f"mysql+pymysql://{user}:{password}@{host}:{port}/{db}?charset=utf8mb4"
    engine = create_engine(uri)
    with engine.connect() as conn:
        # Load full table; then normalize columns flexibly
        sql = f"SELECT * FROM {table}"
        if limit and limit > 0:
            sql += f" LIMIT {int(limit)}"
        df_raw = pd.read_sql(text(sql), conn)
    return normalize_dataframe(df_raw)

def load_from_csv(csv_path: Path, limit: Optional[int] = None) -> pd.DataFrame:
    df_raw = pd.read_csv(csv_path)
    if limit and limit > 0:
        df_raw = df_raw.head(limit)
    return normalize_dataframe(df_raw)

# -----------------------------
# Embedding + Index
# -----------------------------

def build_corpus(df: pd.DataFrame, min_chunk_chars: int, chunk_size: int, chunk_overlap: int) -> List[Dict]:
    """
    For each row, construct text = title + description, then chunk.
    Returns list of dicts: {dramaId, title, category, chunk, chunk_id}
    """
    corpus = []
    for _, row in df.iterrows():
        did = row["id"]
        title = row["title"]
        desc = row.get("description", "") or ""
        category = row.get("category", "") or ""

        base_text = f"{title}. {desc}".strip()
        chunks = chunk_by_sentences(base_text, max_chars=chunk_size, overlap_chars=chunk_overlap)
        # filter too short
        chunks = [c for c in chunks if len(c) >= min_chunk_chars]
        if not chunks:
            # fallback: at least use title
            chunks = [title]

        for idx, c in enumerate(chunks):
            corpus.append({
                "dramaId": int(did) if str(did).isdigit() else str(did),
                "title": title,
                "category": category,
                "chunk": c,
                "chunk_id": idx,
                "text_len": len(c),
            })
    return corpus

def embed_texts(model: SentenceTransformer, texts: List[str], batch_size: int, normalize: bool = True) -> np.ndarray:
    emb = model.encode(
        texts,
        batch_size=batch_size,
        show_progress_bar=True,
        convert_to_numpy=True,
        normalize_embeddings=normalize,
    )
    return emb.astype("float32")

def save_metadata(metadata_path: Path, corpus: List[Dict], extra: Dict) -> None:
    with metadata_path.open("w", encoding="utf-8") as f:
        for i, item in enumerate(corpus):
            rec = dict(item)
            rec["vector_index"] = i
            rec.update(extra)
            f.write(json.dumps(rec, ensure_ascii=False) + "\n")

def write_stats(stats_path: Path, stats: Dict) -> None:
    with stats_path.open("w", encoding="utf-8") as f:
        json.dump(stats, f, ensure_ascii=False, indent=2)

def extract_tags_for_items(texts: List[str], topk:int=8) -> List[List[str]]:
    vec = TfidfVectorizer(
        max_features=5000,
        ngram_range=(1,2),
        stop_words="english"
    )
    X = vec.fit_transform(texts)
    vocab = np.array(vec.get_feature_names_out())
    tags_list: List[List[str]] = []
    for i in range(X.shape[0]):
        row = X.getrow(i)
        if row.nnz == 0:
            tags_list.append([])
            continue
        idxs = np.argsort(row.toarray()[0])[-topk:]
        tags = [vocab[j] for j in idxs if len(vocab[j]) > 2]
        tags_list.append(tags)
    return tags_list

def build_drama_level(df: pd.DataFrame, model: SentenceTransformer, out_dir: Path) -> None:
    print("[DramaIndex] building drama-level index...")
    texts = [(f"{r['title']}. {r.get('description','') or ''}").strip() for _, r in df.iterrows()]
    tags_list = extract_tags_for_items(texts, topk=8)
    embs = model.encode(texts, batch_size=64, show_progress_bar=True, convert_to_numpy=True, normalize_embeddings=True).astype("float32")

    dim = embs.shape[1]
    index = faiss.IndexFlatIP(dim)
    index.add(embs)
    faiss.write_index(index, str(out_dir / "drama.faiss"))

    meta_path = out_dir / "drama_meta.jsonl"
    with meta_path.open("w", encoding="utf-8") as f:
        for i, (_, r) in enumerate(df.iterrows()):
            rec = {
                "dramaId": int(r["id"]) if str(r["id"]).isdigit() else r["id"],
                "title": r["title"],
                "category": r.get("category","") or "",
                "tags": tags_list[i],
            }
            f.write(json.dumps(rec, ensure_ascii=False) + "\n")
    print("[DramaIndex] saved faiss + metadata.")

# -----------------------------
# CLI
# -----------------------------

def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(description="Build FAISS index for drama RAG (English-first).")
    ap.add_argument("--source", choices=["mysql", "csv"], required=True, help="Data source")
    ap.add_argument("--table", default="drama", help="MySQL table name (default: drama)")
    ap.add_argument("--csv-path", type=str, help="CSV path if source=csv")
    ap.add_argument("--out-dir", type=str, default="ai_service/index", help="Output directory")
    ap.add_argument("--model-name", type=str, default="BAAI/bge-small-en-v1.5", help="SentenceTransformer model")
    ap.add_argument("--chunk-size", type=int, default=400, help="Max characters per chunk")
    ap.add_argument("--chunk-overlap", type=int, default=60, help="Approximate overlap characters")
    ap.add_argument("--min-chunk-chars", type=int, default=80, help="Drop chunks shorter than this")
    ap.add_argument("--batch-size", type=int, default=64, help="Embedding batch size")
    ap.add_argument("--max-rows", type=int, default=0, help="Limit rows for quick test (0=all)")
    ap.add_argument("--test-query", type=str, default=None, help="Optional quick retrieval test query")
    return ap.parse_args()

def main():
    args = parse_args()
    t0 = time.time()

    out_dir = Path(args.out_dir).resolve()
    ensure_dir(out_dir)
    index_path = out_dir / "faiss.index"
    meta_path = out_dir / "metadata.jsonl"
    stats_path = out_dir / "stats.json"

    # 1) Load data
    if args.source == "mysql":
        df = load_from_mysql(table=args.table, limit=args.max_rows if args.max_rows > 0 else None)
        source_name = "mysql"
    else:
        if not args.csv_path:
            raise ValueError("--csv-path is required when source=csv")
        csv_path = Path(args.csv_path).resolve()
        if not csv_path.exists():
            raise FileNotFoundError(f"CSV not found: {csv_path}")
        df = load_from_csv(csv_path, limit=args.max_rows if args.max_rows > 0 else None)
        source_name = f"csv:{csv_path.name}"

    if df.empty:
        raise ValueError("No data loaded. Check source and fields.")
    print(f"[Data] Loaded rows: {len(df)} from {source_name}")

    # 2) Build corpus
    corpus = build_corpus(
        df=df,
        min_chunk_chars=args.min_chunk_chars,
        chunk_size=args.chunk_size,
        chunk_overlap=args.chunk_overlap,
    )
    if not corpus:
        raise ValueError("Empty corpus after chunking. Adjust chunk parameters.")
    print(f"[Corpus] Total chunks: {len(corpus)} (avg per item ~ {len(corpus)/max(len(df),1):.2f})")

    # 3) Load model
    print(f"[Model] Loading: {args.model_name}")
    model = SentenceTransformer(args.model_name)

    # 4) Embeddings
    texts = [c["chunk"] for c in corpus]
    embeddings = embed_texts(model, texts, batch_size=args.batch_size, normalize=True)
    dim = embeddings.shape[1]
    print(f"[Embed] Shape: {embeddings.shape}, dim={dim}")

    # 5) FAISS index (cosine via inner product on normalized vectors)
    index = faiss.IndexFlatIP(dim)
    index.add(embeddings)
    faiss.write_index(index, str(index_path))
    print(f"[FAISS] Index written to: {index_path}")

    # 6) Metadata + stats
    extra = {
        "source": source_name,
        "model": args.model_name,
    }
    save_metadata(meta_path, corpus, extra)
    print(f"[Meta] Metadata written to: {meta_path}")

    # Build drama-level index + metadata (per-drama, with tags)
    build_drama_level(df=df, model=model, out_dir=out_dir)

    elapsed = time.time() - t0
    stats = {
        "source": source_name,
        "rows": int(len(df)),
        "chunks": int(len(corpus)),
        "dimension": int(dim),
        "model": args.model_name,
        "chunk_size": args.chunk_size,
        "chunk_overlap": args.chunk_overlap,
        "min_chunk_chars": args.min_chunk_chars,
        "batch_size": args.batch_size,
        "built_at": datetime.utcnow().isoformat() + "Z",
        "elapsed_sec": round(elapsed, 3),
        "avg_chars_per_chunk": round(float(np.mean([c["text_len"] for c in corpus])), 2),
    }
    write_stats(stats_path, stats)
    print(f"[Stats] Stats written to: {stats_path}")
    print(f"[Done] Elapsed {elapsed:.2f}s")

    # 7) Optional quick retrieval test
    if args.test_query:
        print(f"\n[Test] Running quick search for: {args.test_query}")
        q_emb = embed_texts(model, [args.test_query], batch_size=1, normalize=True)
        top_k = min(5, len(corpus))
        D, I = index.search(q_emb, top_k)
        results = []
        for rank, (idx, score) in enumerate(zip(I[0], D[0]), start=1):
            meta = corpus[int(idx)]
            snippet = meta["chunk"][:160].replace("\n", " ")
            results.append({
                "rank": rank,
                "score": round(float(score), 4),
                "dramaId": meta["dramaId"],
                "title": meta["title"],
                "category": meta.get("category", ""),
                "snippet": snippet,
            })
        print(json.dumps(results, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()