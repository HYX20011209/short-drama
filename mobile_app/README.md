## 移动端（Flutter）

### 简介
Flutter 客户端，通过后端 `/api` 提供的接口访问业务与 AI 能力（`/api/ai/ask`）。

### 环境要求
- Flutter SDK 3.8.x
- Dart SDK 3.8.x（随 Flutter）

### 配置后端地址
编辑 `lib/utils/constants.dart`：
```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8101/api';  // Android 模拟器
  } else {
    return 'http://<server-ip>:8101/api';  // iOS/桌面/真机改为你的后端 IP
  }
}
```

### 安装与运行
```bash
flutter pub get
flutter run
```

### 打包
```bash
# Android
flutter build apk

# iOS（需 macOS + Xcode）
flutter build ios
```

### 重要说明
- AI 请求走后端：`POST /api/ai/ask`（无需直连 AI 服务）
- 登录状态通过 Cookie 维持，`NetworkHelper` 已做 Cookie 处理

### 常见问题
- 模拟器访问主机失败：Android 用 `10.0.2.2`；iOS 可用 `127.0.0.1`
- 接口 404：确认 `baseUrl` 中包含 `/api` 前缀