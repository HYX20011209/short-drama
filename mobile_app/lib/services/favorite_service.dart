import '../models/drama.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// 收藏服务类
class FavoriteService {
  /// 获取收藏列表
  static Future<List<Drama>> getFavorites({
    int pageNum = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    try {
      final response = await ApiService.getFavorites(
        pageNum: pageNum,
        pageSize: pageSize,
      );

      if (response != null) {
        final List records = response['data']['records'] ?? [];
        return records.map((json) => Drama.fromJson(json)).toList();
      }
    } catch (e) {
      print('获取收藏列表失败: $e');
      rethrow;
    }
    return [];
  }

  /// 添加收藏
  static Future<bool> addFavorite(String dramaId) async {
    try {
      final response = await ApiService.addFavorite(dramaId);
      return response != null && response['data'] == true;
    } catch (e) {
      print('添加收藏失败: $e');
      return false;
    }
  }

  /// 取消收藏
  static Future<bool> removeFavorite(String dramaId) async {
    try {
      final response = await ApiService.removeFavorite(dramaId);
      return response != null && response['data'] == true;
    } catch (e) {
      print('取消收藏失败: $e');
      return false;
    }
  }

  /// 切换收藏状态
  /// 返回切换后的状态：true表示已收藏，false表示未收藏
  static Future<bool?> toggleFavorite(String dramaId) async {
    try {
      final response = await ApiService.toggleFavorite(dramaId);
      if (response != null) {
        return response['data'] as bool?;
      }
    } catch (e) {
      print('切换收藏状态失败: $e');
    }
    return null;
  }

  /// 检查收藏状态
  static Future<bool> checkFavorite(String dramaId) async {
    try {
      final response = await ApiService.checkFavorite(dramaId);
      if (response != null) {
        return response['data'] as bool? ?? false;
      }
    } catch (e) {
      print('检查收藏状态失败: $e');
    }
    return false;
  }
}
