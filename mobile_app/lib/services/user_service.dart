import '../models/user.dart';
import '../models/watch_history.dart';
import '../models/drama.dart';
import '../utils/network_helper.dart';
import '../utils/constants.dart';

class UserService {
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
      final response = await NetworkHelper.post(
        '/user/favorite/$dramaId',
        {},
      );
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
      final response = await NetworkHelper.post(
        '/user/progress',
        {
          'videoId': videoId,
          if (dramaId != null) 'dramaId': dramaId,
          if (episodeNumber != null) 'episodeNumber': episodeNumber,
          'progress': progress,
        },
      );
      return response != null;
    } catch (e) {
      print('更新观看进度失败: $e');
      return false;
    }
  }
}