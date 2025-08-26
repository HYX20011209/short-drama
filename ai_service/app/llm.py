from typing import List, Dict, Optional
from .config import settings

def build_template_answer(question: str, items: List[Dict]) -> str:
    """
    English-first concise answer. Summarize and list top recommendations.
    """
    if not items:
        return f"Sorry, I couldn't find relevant dramas for: \"{question}\"."

    titles = [i["title"] for i in items[:3] if i.get("title")]
    title_str = ", ".join(titles) if titles else "some titles"
    return (
        f"Here are some dramas matching your request \"{question}\": {title_str}. "
        f"I chose them based on semantic similarity to your query and their descriptions. "
        f"Tap a card to view details and start watching."
    )

def generate_answer(question: str, items: List[Dict], scene: str, drama_id: Optional[int]) -> str:
    """
    LLM gateway (currently template-only unless OPENAI is configured).
    """
    if settings.llm_provider == "OPENAI" and settings.openai_api_key:
        # Optional: integrate OpenAI here if needed (requires 'openai' package)
        # Keep template to avoid extra dependency by default.
        pass
    return build_template_answer(question, items)