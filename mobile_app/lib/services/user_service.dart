import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/drama.dart';
import '../models/user.dart';
import '../models/watch_history.dart';
import '../utils/constants.dart';
import '../utils/network_helper.dart';

class UserService {
  /// 用户登录
  static Future<User?> login(String userAccount, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userLogin}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userAccount': userAccount,
          'userPassword': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0 && data['data'] != null) {
          return User.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// 用户注册
  static Future<bool> register(
    String userAccount,
    String password,
    String checkPassword,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userRegister}',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userAccount': userAccount,
          'userPassword': password,
          'checkPassword': checkPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['code'] == 0;
      }
      return false;
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// 获取当前用户信息
  static Future<User?> getCurrentUser() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/user/get/login');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0 && data['data'] != null) {
          return User.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }

  /// 获取观看历史
  static Future<List<WatchHistory>> getWatchHistory({
    int current = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    try {
      final queryParams = {
        'current': current.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await NetworkHelper.get(
        ApiConstants.userHistory,
        queryParams: queryParams,
      );

      if (response != null) {
        final List records = response['data']['records'] ?? [];
        return records.map((json) => WatchHistory.fromJson(json)).toList();
      }
    } catch (e) {
      print('获取观看历史失败: $e');
    }
    return [];
  }

  /// 获取收藏列表
  static Future<List<Drama>> getFavorites({
    int current = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    try {
      final queryParams = {
        'current': current.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await NetworkHelper.get(
        ApiConstants.userFavorites,
        queryParams: queryParams,
      );

      if (response != null) {
        final List records = response['data']['records'] ?? [];
        return records.map((json) => Drama.fromJson(json)).toList();
      }
    } catch (e) {
      print('获取收藏列表失败: $e');
    }
    return [];
  }

  /// 切换收藏状态
  static Future<bool> toggleFavorite(int dramaId) async {
    try {
      final response = await NetworkHelper.post('/user/favorite/$dramaId', {});
      return response != null;
    } catch (e) {
      print('切换收藏状态失败: $e');
      return false;
    }
  }

  /// 更新观看进度
  static Future<bool> updateWatchProgress({
    required int videoId,
    int? dramaId,
    int? episodeNumber,
    required int progress,
  }) async {
    try {
      final response = await NetworkHelper.post('/user/progress', {
        'videoId': videoId,
        if (dramaId != null) 'dramaId': dramaId,
        if (episodeNumber != null) 'episodeNumber': episodeNumber,
        'progress': progress,
      });
      return response != null;
    } catch (e) {
      print('更新观看进度失败: $e');
      return false;
    }
  }
}
