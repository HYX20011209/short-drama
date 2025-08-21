import '../models/drama.dart';
import '../models/enhanced_video.dart';
import '../utils/constants.dart';
import '../utils/network_helper.dart';

class DramaService {
  /// 获取剧集列表
  static Future<List<Drama>> getDramaList({
    int current = 1,
    int pageSize = ApiConstants.defaultPageSize,
    String? category,
  }) async {
    try {
      final queryParams = {
        'current': current.toString(),
        'pageSize': pageSize.toString(),
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final response = await NetworkHelper.get(
        ApiConstants.dramaList,
        queryParams: queryParams,
      );

      if (response != null) {
        final List records = response['data']['records'] ?? [];
        return records.map((json) => Drama.fromJson(json)).toList();
      }
    } catch (e) {
      print('获取剧集列表失败: $e');
    }
    return [];
  }

  /// 获取剧集详情
  static Future<Drama?> getDramaDetail(int dramaId) async {
    try {
      final response = await NetworkHelper.get(
        '${ApiConstants.dramaDetail}/$dramaId',
      );

      if (response != null) {
        return Drama.fromJson(response['data']);
      }
    } catch (e) {
      print('获取剧集详情失败: $e');
    }
    return null;
  }

  /// 获取剧集的所有视频
  static Future<List<EnhancedVideo>> getDramaEpisodes(int dramaId) async {
    try {
      final endpoint = ApiConstants.dramaEpisodes.replaceAll(
        '{id}',
        dramaId.toString(),
      );
      final response = await NetworkHelper.get(endpoint);

      if (response != null) {
        final List records = response['data'] ?? [];
        return records.map((json) => EnhancedVideo.fromJson(json)).toList();
      }
    } catch (e) {
      print('获取剧集视频失败: $e');
    }
    return [];
  }

  /// 获取分类列表
  static Future<List<String>> getCategories() async {
    // TODO: 实现获取分类列表的API
    return ['都市', '古装', '悬疑', '爱情', '喜剧'];
  }

  /// 搜索剧集
  static Future<List<Drama>> searchDramas(
    String searchText, {
    int current = 1,
    int pageSize = ApiConstants.defaultPageSize,
    String? category,
  }) async {
    try {
      final queryParams = {
        'searchText': searchText,
        'current': current.toString(),
        'pageSize': pageSize.toString(),
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final response = await NetworkHelper.get(
        ApiConstants.dramaSearch,
        queryParams: queryParams,
      );

      if (response != null) {
        final List records = response['data']['records'] ?? [];
        return records.map((json) => Drama.fromJson(json)).toList();
      }
    } catch (e) {
      print('搜索剧集失败: $e');
    }
    return [];
  }
}
