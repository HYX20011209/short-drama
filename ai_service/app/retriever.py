import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import faiss  # type: ignore
import numpy as np
from sentence_transformers import SentenceTransformer

from .config import settings


class IndexStore:
    """
    Loads FAISS index and metadata produced by Step 1.
    Provides vector search and simple filtering helpers.
    """
    def __init__(self, index_dir: Path, model_name: str):
        self.index_dir = index_dir
        self.index_path = index_dir / "faiss.index"
        self.meta_path = index_dir / "metadata.jsonl"
        self.model_name = model_name

        if not self.index_path.exists():
            raise FileNotFoundError(f"FAISS index not found: {self.index_path}")
        if not self.meta_path.exists():
            raise FileNotFoundError(f"Metadata file not found: {self.meta_path}")

        self.index = faiss.read_index(str(self.index_path))
        self.metadata: List[Dict] = []
        with self.meta_path.open("r", encoding="utf-8") as f:
            for line in f:
                self.metadata.append(json.loads(line))

        self.drama_index_path = self.index_dir / "drama.faiss"
        self.drama_meta_path = self.index_dir / "drama_meta.jsonl"
        if not self.drama_index_path.exists() or not self.drama_meta_path.exists():
            raise FileNotFoundError("Drama-level index not found, please rebuild.")
        self.drama_index = faiss.read_index(str(self.drama_index_path))
        self.drama_meta: List[Dict] = []
        with self.drama_meta_path.open("r", encoding="utf-8") as f:
            for line in f:
                self.drama_meta.append(json.loads(line))

        # Load embedding model
        self.model = SentenceTransformer(self.model_name)

    def _embed(self, texts: List[str]) -> np.ndarray:
        emb = self.model.encode(
            texts, show_progress_bar=False, convert_to_numpy=True, normalize_embeddings=True
        )
        return emb.astype("float32")

    def search(self, query: str, topk: int) -> List[Tuple[int, float]]:
        q = self._embed([query])
        D, I = self.index.search(q, topk)
        # returns list of (meta_index, score)
        return [(int(i), float(s)) for i, s in zip(I[0], D[0])]

    def hits_to_drama(self, hits: List[Tuple[int, float]], dedup_by_drama: bool = True, limit: Optional[int] = None):
        """
        Convert vector hits to drama-level results (deduplicate by dramaId, keep best score).
        """
        by_drama: Dict[int, Dict] = {}
        for idx, score in hits:
            m = self.metadata[idx]
            did = int(m["dramaId"]) if str(m["dramaId"]).isdigit() else m["dramaId"]
            did = int(did)  # enforce int if possible
            prev = by_drama.get(did)
            if prev is None or score > prev["score"]:
                by_drama[did] = {
                    "dramaId": did,
                    "title": m.get("title", ""),
                    "category": m.get("category", ""),
                    "snippet": m.get("chunk", "")[:400].replace("\n", " "),
                    "score": score,
                }

        items = list(by_drama.values()) if dedup_by_drama else []
        if not dedup_by_drama:
            for idx, score in hits:
                m = self.metadata[idx]
                did = int(m["dramaId"]) if str(m["dramaId"]).isdigit() else m["dramaId"]
                did = int(did)
                items.append({
                    "dramaId": did,
                    "title": m.get("title", ""),
                    "category": m.get("category", ""),
                    "snippet": m.get("chunk", "")[:400].replace("\n", " "),
                    "score": score,
                })
        items.sort(key=lambda x: x["score"], reverse=True)
        if limit:
            items = items[:limit]
        return items

    def filter_hits_by_drama(self, hits: List[Tuple[int, float]], drama_id: int) -> List[Tuple[int, float]]:
        return [(idx, score) for idx, score in hits if int(self.metadata[idx].get("dramaId", -1)) == drama_id]
    
    def search_drama_level(self, query: str, topk: int) -> List[Tuple[int, float]]:
        q = self._embed([query])
        D, I = self.drama_index.search(q, topk)
        return [(int(i), float(s)) for i, s in zip(I[0], D[0])]

    def _tokenize(self, text: str) -> List[str]:
        text = (text or "").lower()
        text = re.sub(r"[^a-z0-9\-\+\s]", " ", text)
        toks = [t for t in text.split() if len(t) > 1]
        # 简单同义词归一（可扩展为读取 json 词典）
        syn = {
            "funny": ["comedy","humorous","humor"],
            "time-travel": ["time","travel","timetravel","isekai"],
            "time": ["time"],
            "travel": ["travel"],
        }
        mapped: List[str] = []
        for t in toks:
            mapped.append(t)
            for k, arr in syn.items():
                if t in arr:
                    mapped.append(k)
        return list(dict.fromkeys(mapped))  # 去重保序

    def _category_boost(self, query_tokens: List[str], category: str) -> float:
        c = (category or "").lower()
        bonus = 0.0
        # 朴素匹配，可按你实际 category 值调整映射
        if "comedy" in query_tokens and "comedy" in c: bonus += 0.12
        if "romance" in query_tokens and "romance" in c: bonus += 0.10
        if "mystery" in query_tokens and "mystery" in c: bonus += 0.10
        if "urban" in query_tokens and "urban" in c: bonus += 0.08
        if "costume" in query_tokens and "costume" in c: bonus += 0.08
        if "youth" in query_tokens and "youth" in c: bonus += 0.06
        return bonus

    def drama_level_hybrid(self, query: str, vec_topk: int, final_topk: int, alpha: float=0.8, min_tag_hits: int=1) -> List[Dict]:
        # 1) 向量召回（剧目级）
        vec_hits = self.search_drama_level(query, topk=max(vec_topk, final_topk*3))
        q_tokens = self._tokenize(query)

        # 2) 混合打分：向量 + tags 命中 + category 加权
        scored = []
        for idx, vscore in vec_hits:
            m = self.drama_meta[idx]
            tags = [t.lower() for t in (m.get("tags", []) or [])]
            tag_hits = sum(1 for t in q_tokens if t in tags)
            if min_tag_hits > 0 and tag_hits < min_tag_hits:
                continue
            tag_score = tag_hits / max(1, len(set(q_tokens)))
            cat_bonus = self._category_boost(q_tokens, m.get("category","") or "")
            hybrid = alpha * vscore + (1.0 - alpha) * tag_score + cat_bonus
            scored.append((idx, hybrid, vscore, tag_hits, cat_bonus))

        # 回退：若过滤太严，允许仅靠向量分返回
        if len(scored) < final_topk:
            scored = [(idx, vscore, vscore, 0, 0.0) for idx, vscore in vec_hits]

        scored.sort(key=lambda x: x[1], reverse=True)
        picked = scored[:final_topk]

        items: List[Dict] = []
        for idx, _, vscore, tag_hits, cat_bonus in picked:
            m = self.drama_meta[idx]
            items.append({
                "dramaId": int(m["dramaId"]) if str(m["dramaId"]).isdigit() else m["dramaId"],
                "title": m.get("title",""),
                "category": m.get("category",""),
                "snippet": ", ".join(m.get("tags",[]))[:160],
                "score": float(vscore + cat_bonus),
                "tagHits": int(tag_hits),
            })
        return items

# Singleton-like loader
_index_store: Optional[IndexStore] = None

def get_index_store() -> IndexStore:
    global _index_store
    if _index_store is None:
        _index_store = IndexStore(settings.ai_index_dir, settings.embedding_model_name)
    return _index_store