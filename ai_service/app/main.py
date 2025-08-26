from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .models import AskRequest, AskResponse, DramaHit
from .retriever import get_index_store
from .llm import generate_answer

app = FastAPI(title="Short Drama AI Service", version="1.0.0")

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

    # 1) Vector search
    hits = store.search(req.question, topk=max(topk * 3, topk))  # over-fetch for better dedup

    # 2) Scene handling
    if scene == "qa" and req.dramaId:
        # Filter results to the given dramaId
        hits = store.filter_hits_by_drama(hits, req.dramaId)
        if not hits:
            # If no vector hits for given drama, fallback to generic search (no filter)
            hits = store.search(req.question, topk=max(topk * 2, topk))

    # 3) Convert to drama-level results (dedup by drama)
    items = store.hits_to_drama(hits, dedup_by_drama=True, limit=topk)

    # 4) Build answer (template / LLM)
    answer = generate_answer(req.question, items, scene=scene, drama_id=req.dramaId)

    # 5) Map to response
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