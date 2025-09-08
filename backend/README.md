## 后端（Spring Boot）

### 简介
对外暴露 REST API（上下文路径 `/api`），并作为 AI 网关，将 `/api/ai/ask` 转发到 Python FastAPI `/rag/ask`。

### 环境要求
- JDK 8
- Maven 3.8+（或使用 `./mvnw`）
- MySQL 8.x（必需）
- Redis（可选）

### 配置
编辑 `src/main/resources/application.yml`
- 数据库
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/short_drama
    username: root
    password: 你的密码
```
- AI 服务地址（务必改为 AI 服务实际可达地址）
```yaml
ai:
  service:
    base-url: "http://127.0.0.1:8088"
    timeout-ms: 30000
```
- 服务端口与上下文
```yaml
server:
  port: 8101
  servlet:
    context-path: /api
```

### 数据库初始化
```text
执行 init_full.sql
```

### 本地启动
在idea启动即可

