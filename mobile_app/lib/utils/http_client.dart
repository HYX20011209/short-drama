import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'constants.dart';

/// 支持Cookie管理的HTTP客户端
class HttpClient {
  static Dio? _dio;
  static CookieJar? _cookieJar;

  /// 获取Dio实例
  static Future<Dio> getInstance() async {
    if (_dio == null) {
      await _initializeClient();
    }
    return _dio!;
  }

  /// 初始化HTTP客户端
  static Future<void> _initializeClient() async {
    // 创建Dio实例
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 创建Cookie Jar（使用内存Cookie Jar，简化实现）
    _cookieJar = CookieJar();

    // 添加Cookie管理器
    _dio!.interceptors.add(CookieManager(_cookieJar!));

    // 添加请求/响应拦截器（用于调试）
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('发送请求: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('收到响应: ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('请求错误: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// GET请求
  static Future<Map<String, dynamic>?> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final dio = await getInstance();
      final response = await dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } catch (e) {
      print('GET请求失败: $e');
      rethrow;
    }
  }

  /// POST请求
  static Future<Map<String, dynamic>?> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final dio = await getInstance();
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      print('POST请求失败: $e');
      rethrow;
    }
  }

  /// DELETE请求
  static Future<Map<String, dynamic>?> delete(String path) async {
    try {
      final dio = await getInstance();
      final response = await dio.delete(path);
      return _handleResponse(response);
    } catch (e) {
      print('DELETE请求失败: $e');
      rethrow;
    }
  }

  /// 处理响应
  static Map<String, dynamic>? _handleResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['code'] == 0) {
          return data;
        } else {
          throw Exception(data['message'] ?? AppConstants.defaultErrorMessage);
        }
      }
    }
    throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
  }

  /// 清除所有Cookie（用于登出）
  static Future<void> clearCookies() async {
    if (_cookieJar != null) {
      await _cookieJar!.deleteAll();
    }
  }

  /// 获取指定URL的Cookie
  static Future<List<Cookie>> getCookies(String url) async {
    if (_cookieJar != null) {
      return await _cookieJar!.loadForRequest(Uri.parse(url));
    }
    return [];
  }
}
