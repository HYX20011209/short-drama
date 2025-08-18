import '../models/enhanced_video.dart';
import '../utils/network_helper.dart';
import '../utils/constants.dart';

class VideoService {
  /// 获取视频流（支持剧集筛选）
  static Future<List<VideoItem>> getVideoFeed({
    int current = 1,
    int pageSize = ApiConstants.defaultPageSize,
    int? dramaId,
  }) async {
    try {
      final queryParams = {
        'current': current.toString(),
        'pageSize': pageSize.toString(),
        if (dramaId != null) 'dramaId': dramaId.toString(),
      };

      final response = await NetworkHelper.get(
        ApiConstants.videoFeed,
        queryParams: queryParams,
      );

      if (response != null) {
        final List records = response['data']['records'] ?? [];
        return records.map((json) => VideoItem.fromJson(json)).toList();
      }
    } catch (e) {
      print('获取视频流失败: $e');
    }
    return [];
  }

  /// 获取单个视频详情
  static Future<EnhancedVideo?> getVideoDetail(int videoId) async {
    try {
      final response = await NetworkHelper.get('/video/get?id=$videoId');
      
      if (response != null) {
        return EnhancedVideo.fromJson(response['data']);
      }
    } catch (e) {
      print('获取视频详情失败: $e');
    }
    return null;
  }
}