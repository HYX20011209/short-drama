import os
from dataclasses import dataclass
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(override=True)

@dataclass
class Settings:
    ai_index_dir: Path = Path(os.getenv("AI_INDEX_DIR", "ai_service/index")).resolve()
    embedding_model_name: str = os.getenv("EMBEDDING_MODEL_NAME", "BAAI/bge-small-en-v1.5")
    topk_default: int = int(os.getenv("TOPK_DEFAULT", "6"))

    llm_provider: str = os.getenv("LLM_PROVIDER", "NONE").upper()  # NONE or OPENAI
    openai_api_key: str = os.getenv("OPENAI_API_KEY", "")
    openai_base_url: str = os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
    openai_model: str = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

settings = Settings()