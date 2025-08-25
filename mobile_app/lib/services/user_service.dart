import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/drama.dart';
import '../models/user.dart';
import '../models/watch_history.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'favorite_service.dart';
import 'watch_history_service.dart';

class UserService {
  /// 用户登录
  static Future<User?> login(String userAccount, String password) async {
    try {
      final response = await ApiService.login(
        userAccount: userAccount,
        userPassword: password,
      );

      if (response != null && response['data'] != null) {
        return User.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }

  /// 用户注册
  static Future<bool> register(
    String userAccount,
    String password,
    String checkPassword,
  ) async {
    try {
      final response = await ApiService.register(
        userAccount: userAccount,
        userPassword: password,
        checkPassword: checkPassword,
      );

      return response != null && response['code'] == 0;
    } catch (e) {
      throw Exception('Network request failed: $e');
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
      throw Exception('Failed to get user info: $e');
    }
  }

  /// 获取观看历史（代理方法）
  static Future<List<WatchHistory>> getWatchHistory({
    int current = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    return await WatchHistoryService.getWatchHistory(
      pageNum: current,
      pageSize: pageSize,
    );
  }

  /// 获取收藏列表（代理方法）
  static Future<List<Drama>> getFavorites({
    int current = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    return await FavoriteService.getFavorites(
      pageNum: current,
      pageSize: pageSize,
    );
  }

  /// 切换收藏状态（代理方法）
  static Future<bool?> toggleFavorite(String dramaId) async {
    return await FavoriteService.toggleFavorite(dramaId);
  }

  /// 更新观看进度（代理方法）
  static Future<bool> updateWatchProgress({
    required String videoId, // 改为String类型
    String? dramaId, // 改为String类型
    int? episodeNumber,
    required int progress,
  }) async {
    return await WatchHistoryService.updateWatchProgress(
      videoId: videoId,
      dramaId: dramaId,
      episodeNumber: episodeNumber,
      progress: progress,
    );
  }

  /// 更新个人信息
  static Future<bool> updateUserProfile({
    String? userName,
    String? userProfile,
    String? userPassword,
  }) async {
    try {
      final response = await ApiService.updateUserProfile(
        userName: userName,
        userProfile: userProfile,
        userPassword: userPassword,
      );

      return response != null && response['code'] == 0;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
