from typing import List, Optional
from pydantic import BaseModel, Field

class AskRequest(BaseModel):
    question: str = Field(..., min_length=1, description="User query in English")
    topK: Optional[int] = Field(default=None, ge=1, le=50)
    scene: str = Field(default="search", description="search | recommend | qa")
    dramaId: Optional[int] = Field(default=None, description="Used for QA context")

class DramaHit(BaseModel):
    dramaId: int
    title: str
    category: Optional[str] = ""
    description: Optional[str] = ""
    snippet: Optional[str] = ""
    score: float

class AskResponse(BaseModel):
    answer: str
    relatedDramas: List[DramaHit]