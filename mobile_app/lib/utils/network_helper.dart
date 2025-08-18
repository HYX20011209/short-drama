import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class NetworkHelper {
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
          ...?headers,
        },
      );

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
          ...?headers,
        },
        body: json.encode(body),
      );

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
}