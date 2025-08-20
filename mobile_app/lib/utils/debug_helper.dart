import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class DebugHelper {
  /// 测试登录状态
  static Future<void> testLoginStatus() async {
    if (kDebugMode) {
      try {
        final response = await ApiService.getCurrentUser();
        if (response != null) {
          print('登录状态正常，用户信息: ${response['data']}');
        } else {
          print('未登录或登录已过期');
        }
      } catch (e) {
        print('检查登录状态失败: $e');
      }
    }
  }
}
