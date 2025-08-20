import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class NetworkHelper {
  // 简单的Cookie存储
  static Map<String, String> _cookies = {};

  static Future<Map<String, dynamic>?> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ..._getCookieHeaders(),
          ...?headers,
        },
      );

      _saveCookiesFromResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0) {
          return data;
        } else {
          throw Exception(data['message'] ?? AppConstants.defaultErrorMessage);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('网络请求错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ..._getCookieHeaders(),
          ...?headers,
        },
        body: json.encode(body),
      );

      _saveCookiesFromResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0) {
          return data;
        } else {
          throw Exception(data['message'] ?? AppConstants.defaultErrorMessage);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('网络请求错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ..._getCookieHeaders(),
          ...?headers,
        },
      );

      _saveCookiesFromResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0) {
          return data;
        } else {
          throw Exception(data['message'] ?? AppConstants.defaultErrorMessage);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('网络请求错误: $e');
      rethrow;
    }
  }

  /// 获取Cookie头
  static Map<String, String> _getCookieHeaders() {
    if (_cookies.isNotEmpty) {
      final cookieString = _cookies.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; ');
      return {'Cookie': cookieString};
    }
    return {};
  }

  /// 保存响应中的Cookie
  static void _saveCookiesFromResponse(http.Response response) {
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null) {
      _parseCookies(setCookieHeaders);
    }
  }

  /// 解析Cookie字符串
  static void _parseCookies(String cookieString) {
    final cookies = cookieString.split(',');
    for (String cookie in cookies) {
      final parts = cookie.split(';')[0].split('=');
      if (parts.length == 2) {
        final name = parts[0].trim();
        final value = parts[1].trim();
        _cookies[name] = value;
        print('保存Cookie: $name=$value');
      }
    }
  }

  /// 清除所有Cookie
  static void clearCookies() {
    _cookies.clear();
    print('已清除所有Cookie');
  }
}