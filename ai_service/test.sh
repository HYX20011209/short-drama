python scripts/build_index.py \
  --source mysql \
  --table drama \
  --out-dir ai_service/index \
  --model-name BAAI/bge-small-en-v1.5 \
  --max-rows 200 \
  --test-query "funny time travel"