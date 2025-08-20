import '../models/watch_history.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// 观看历史服务类
class WatchHistoryService {
  /// 获取观看历史列表
  static Future<List<WatchHistory>> getWatchHistory({
    int pageNum = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    try {
      final response = await ApiService.getWatchHistory(
        pageNum: pageNum,
        pageSize: pageSize,
      );

      if (response != null) {
        final List records = response['data']['records'] ?? [];
        return records.map((json) => WatchHistory.fromJson(json)).toList();
      }
    } catch (e) {
      print('获取观看历史失败: $e');
      rethrow;
    }
    return [];
  }

  /// 更新观看进度
  static Future<bool> updateWatchProgress({
    required String videoId,
    String? dramaId,
    int? episodeNumber,
    required int progress,
  }) async {
    try {
      final response = await ApiService.updateWatchProgress(
        videoId: videoId,
        dramaId: dramaId,
        episodeNumber: episodeNumber,
        progress: progress,
      );
      return response != null && response['data'] == true;
    } catch (e) {
      print('更新观看进度失败: $e');
      return false;
    }
  }

  /// 删除观看历史记录
  static Future<bool> deleteWatchHistory(String videoId) async {
    try {
      final response = await ApiService.deleteWatchHistory(videoId);
      return response != null && response['data'] == true;
    } catch (e) {
      print('删除观看历史失败: $e');
      return false;
    }
  }

  /// 清空观看历史
  static Future<bool> clearWatchHistory() async {
    try {
      final response = await ApiService.clearWatchHistory();
      return response != null && response['data'] == true;
    } catch (e) {
      print('清空观看历史失败: $e');
      return false;
    }
  }

  /// 获取视频观看进度
  static Future<int> getWatchProgress(String videoId) async {
    try {
      final response = await ApiService.getWatchProgress(videoId);
      if (response != null) {
        return response['data'] as int? ?? 0;
      }
    } catch (e) {
      print('获取观看进度失败: $e');
    }
    return 0;
  }
}
