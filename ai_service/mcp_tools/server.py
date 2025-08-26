#!/usr/bin/env python3
"""
MCP Tool server for Short Drama RAG (stdio).
Tools:
- vector_search(query: str, topK: int=6) -> { ok, data: { items, answer } }
- qa_for_drama(question: str, dramaId: int, topK: int=6) -> { ok, data: { items, answer } }

Reuses FAISS index & embedding model from ai_service/app.
"""

from typing import Any, Dict, List
from mcp.server.fastmcp import FastMCP

from ai_service.app.retriever import get_index_store
from ai_service.app.llm import generate_answer

srv = FastMCP("short-drama-rag-tools")

def _ok(data: Dict[str, Any]) -> Dict[str, Any]:
    return {"ok": True, "data": data}

def _err(msg: str) -> Dict[str, Any]:
    return {"ok": False, "error": msg}

@srv.tool()
def vector_search(query: str, topK: int = 6) -> Dict[str, Any]:
    """
    Semantic search dramas by English query, returns topK unique dramas.
    """
    if not isinstance(query, str) or not query.strip():
        return _err("query must be a non-empty string")
    if not isinstance(topK, int) or topK <= 0 or topK > 50:
        return _err("topK must be an integer in 1..50")

    store = get_index_store()
    hits = store.search(query, topk=max(topK * 3, topK))
    items = store.hits_to_drama(hits, dedup_by_drama=True, limit=topK)
    answer = generate_answer(query, items, scene="search", drama_id=None)
    return _ok({"items": items, "answer": answer})

@srv.tool()
def qa_for_drama(question: str, dramaId: int, topK: int = 6) -> Dict[str, Any]:
    """
    Question answering constrained to a specific drama (by dramaId).
    """
    if not isinstance(question, str) or not question.strip():
        return _err("question must be a non-empty string")
    if not isinstance(dramaId, int):
        return _err("dramaId must be an integer")
    if not isinstance(topK, int) or topK <= 0 or topK > 50:
        return _err("topK must be an integer in 1..50")

    store = get_index_store()
    hits = store.search(question, topk=max(topK * 3, topK))
    hits = store.filter_hits_by_drama(hits, dramaId)
    if not hits:
        # fallback: unconstrained search
        hits = store.search(question, topk=max(topK * 2, topK))

    items = store.hits_to_drama(hits, dedup_by_drama=True, limit=topK)
    answer = generate_answer(question, items, scene="qa", drama_id=dramaId)
    return _ok({"items": items, "answer": answer})

if __name__ == "__main__":
    srv.run()  # stdio JSON-RPC