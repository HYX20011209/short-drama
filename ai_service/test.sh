# python scripts/build_index.py \
#   --source mysql \
#   --table drama \
#   --out-dir ai_service/index \
#   --model-name BAAI/bge-small-en-v1.5 \
#   --max-rows 200 \
#   --test-query "funny time travel"

# 在ai_service下运行
export PYTHONPATH=$(pwd)/..


uvicorn app.main:app --host 0.0.0.0 --port 8088
curl -H 'Content-Type: application/json' -d '{"question":"test","topK":3,"scene":"search"}'  http://127.0.0.1:8088/rag/ask