## 短剧项目（后端 + AI 服务 + 移动端）

一个包含 Spring Boot 后端、FastAPI AI 检索服务与 Flutter 移动端的完整短剧应用。移动端通过后端 `/api` 访问，后端将 AI 请求转发给 Python AI 服务。

### 目录结构

short-drama/
backend/ # Java Spring Boot 后端
ai_service/ # Python FastAPI + FAISS AI 检索服务
mobile_app/ # Flutter 客户端


### 技术栈
- 后端：Spring Boot、MyBatis-Plus、Redis（可选）、Elasticsearch（可选）、MySQL
- AI 服务：FastAPI、FAISS、sentence-transformers
- 客户端：Flutter 3.8+

### 快速开始（本机）
1) 初始化数据库
```bash
mysql -h 127.0.0.1 -u root -p < backend/sql/create_table.sql
mysql -h 127.0.0.1 -u root -p < backend/sql/upgrade_drama_schema.sql
```

2) 启动 AI 服务（默认读取 `ai_service/index` 索引）
```bash
cd ai_service
python3 -m venv venv && source venv/bin/activate
pip install -U pip && pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8088
# 健康检查：curl http://127.0.0.1:8088/healthz
```

3) 启动后端（确保已配置数据库与 AI 服务地址）
```bash
cd backend
./mvnw package -DskipTests
java -jar target/backend-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
# 后端地址：http://127.0.0.1:8101/api
```

4) 启动移动端
```bash
cd mobile_app
flutter pub get
# 将 ApiConstants.baseUrl 改为你的后端地址（含 /api）
flutter run
```

### 端口与路径
- 后端：`http://<host>:8101/api`
- AI 服务：`http://<host>:8088`（对后端开放，不直接暴露给 App）
- App → 后端：`POST /api/ai/ask`
- 后端 → AI：`POST /rag/ask`

### 子模块文档
- 后端：见 `backend/README.md`
- AI 服务：见 `ai_service/README.md`
- 移动端：见 `mobile_app/README.md`

### 常见问题
- AI 超时：检查 `application.yml` 的 `ai.service.base-url` 与 8088 端口连通性
- App 访问失败：确认 `ApiConstants.baseUrl` 包含 `/api` 前缀
- 模拟器网络：Android 使用 `10.0.2.2` 访问主机；iOS 可用 `127.0.0.1`