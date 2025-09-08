## AI 服务（FastAPI + FAISS）

### 简介
提供检索增强（RAG）能力的 AI 服务，加载本地 FAISS 索引并对外提供 `/rag/ask`。

### 环境要求
- Python 3.10+
- 依赖：`requirements.txt`

### 安装与启动
```bash
cd ai_service
python3 -m venv venv && source venv/bin/activate
pip install -U pip && pip install -r requirements.txt

# 启动
uvicorn app.main:app --host 0.0.0.0 --port 8088
# 健康检查
curl http://127.0.0.1:8088/healthz
```

### 索引
默认索引目录：`ai_service/index`（已包含示例索引）。
如需重建：
- 从 MySQL
```bash
export DB_HOST=127.0.0.1 DB_PORT=3306 DB_USER=root DB_PASSWORD=你的密码 DB_NAME=short_drama
python scripts/build_index.py --source mysql --table drama --out-dir index --model-name BAAI/bge-small-en-v1.5
```
- 从 CSV
```bash
python scripts/build_index.py --source csv --csv-path /path/to/drama.csv --out-dir ai_service/index
```

### 环境变量（可选，支持 `.env`）
```bash
# MySQL connection (used when --source=mysql)
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=short_drama

# ================== AI Service ==================
# Where the index and metadata are stored (from Step 1)
AI_INDEX_DIR=index

# Embedding model used online (should match offline model if possible)
EMBEDDING_MODEL_NAME=BAAI/bge-small-en-v1.5

# Default topK if not provided by request
TOPK_DEFAULT=6

# LLM provider: NONE (template answer only) or OPENAI
LLM_PROVIDER=NONE

# If using OPENAI:
OPENAI_API_KEY=YOUR_OPENAI_API_KEY
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_MODEL=gpt-4o-mini
```

### 接口
- `POST /rag/ask`
  - 入参：`question`、`scene`（search|recommend|qa）、`topK`、`dramaId?`
  - 出参：`answer` + `relatedDramas[]`
