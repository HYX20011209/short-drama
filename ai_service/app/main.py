import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .llm import generate_answer
from .models import AskRequest, AskResponse, DramaHit
from .retriever import get_index_store


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        _ = get_index_store()
        logging.getLogger("uvicorn").info("AI index/model preloaded.")
        yield
    except Exception as e:
        logging.getLogger("uvicorn").warning(f"AI preloaded failed: {e}")

app = FastAPI(title="Short Drama AI Service", version="1.0.0", lifespan=lifespan)

# Allow local dev calls from anywhere; tighten in prod if needed
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/healthz")
def healthz():
    try:
        _ = get_index_store()  # ensure index load OK
        return {"ok": True, "indexDir": str(settings.ai_index_dir)}
    except Exception as e:
        return {"ok": False, "error": str(e)}

@app.post("/rag/ask", response_model=AskResponse)
def rag_ask(req: AskRequest):
    # Validate scene
    scene = (req.scene or "search").lower()
    if scene not in {"search", "recommend", "qa"}:
        raise HTTPException(status_code=400, detail="scene must be one of: search, recommend, qa")

    topk = req.topK or settings.topk_default
    if topk <= 0 or topk > 50:
        raise HTTPException(status_code=400, detail="topK must be in 1..50")

    store = get_index_store()

    if scene == "qa" and req.dramaId:
        # 段落级检索 + 限定当前剧
        hits = store.search(req.question, topk=max(topk * 3, topk))
        hits = store.filter_hits_by_drama(hits, req.dramaId)
        if not hits:
            hits = store.search(req.question, topk=max(topk * 2, topk))
        items = store.hits_to_drama(hits, dedup_by_drama=True, limit=topk)
    else:
        # search / recommend 使用剧目级混合检索（向量 + tags + category 加权）
        items = get_index_store().drama_level_hybrid(
            query=req.question,
            vec_topk=max(topk * 5, 50),
            final_topk=topk,
            alpha=0.8,
            min_tag_hits=1
        )

    #  Build answer (template / LLM)
    answer = generate_answer(req.question, items, scene=scene, drama_id=req.dramaId)

    # Map to response
    resp_items = [
        DramaHit(
            dramaId=int(it["dramaId"]),
            title=it.get("title") or "",
            category=it.get("category") or "",
            description="",  # keep minimal; backend can enrich to DramaVO if needed
            snippet=it.get("snippet") or "",
            score=float(it.get("score", 0.0)),
        )
        for it in items
    ]
    return AskResponse(answer=answer, relatedDramas=resp_items)