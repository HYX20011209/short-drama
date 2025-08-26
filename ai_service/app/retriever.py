import json
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import numpy as np

import faiss  # type: ignore
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

# Singleton-like loader
_index_store: Optional[IndexStore] = None

def get_index_store() -> IndexStore:
    global _index_store
    if _index_store is None:
        _index_store = IndexStore(settings.ai_index_dir, settings.embedding_model_name)
    return _index_store