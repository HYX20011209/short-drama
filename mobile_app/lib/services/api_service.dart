import '../utils/constants.dart';
import '../utils/network_helper.dart';

/// 统一API服务类
/// 负责所有与后端的接口调用
class ApiService {
  // ==================== 用户相关接口 ====================

  /// 用户登录
  static Future<Map<String, dynamic>?> login({
    required String userAccount,
    required String userPassword,
  }) async {
    return await NetworkHelper.post(ApiConstants.userLogin, {
      'userAccount': userAccount,
      'userPassword': userPassword,
    });
  }

  /// 用户注册
  static Future<Map<String, dynamic>?> register({
    required String userAccount,
    required String userPassword,
    required String checkPassword,
  }) async {
    return await NetworkHelper.post(ApiConstants.userRegister, {
      'userAccount': userAccount,
      'userPassword': userPassword,
      'checkPassword': checkPassword,
    });
  }

  /// 获取当前登录用户信息
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return await NetworkHelper.get('/user/get/login');
  }

  /// 更新个人信息
  static Future<Map<String, dynamic>?> updateUserProfile({
    String? userName,
    String? userProfile,
    String? userPassword,
  }) async {
    final Map<String, dynamic> body = {};
    if (userName != null) body['userName'] = userName;
    if (userProfile != null) body['userProfile'] = userProfile;
    if (userPassword != null) body['userPassword'] = userPassword;

    return await NetworkHelper.post('/user/update/my', body);
  }

  // ==================== 观看历史相关接口 ====================

  /// 获取观看历史列表
  static Future<Map<String, dynamic>?> getWatchHistory({
    int pageNum = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    return await NetworkHelper.get(
      ApiConstants.userHistory,
      queryParams: {
        'pageNum': pageNum.toString(),
        'pageSize': pageSize.toString(),
      },
    );
  }

  /// 更新观看进度
  static Future<Map<String, dynamic>?> updateWatchProgress({
    required String videoId,
    String? dramaId,
    int? episodeNumber,
    required int progress,
  }) async {
    final body = {'videoId': int.parse(videoId), 'progress': progress};

    if (dramaId != null) body['dramaId'] = int.parse(dramaId);
    if (episodeNumber != null) body['episodeNumber'] = episodeNumber;

    return await NetworkHelper.post('/user/history/progress', body);
  }

  /// 删除观看历史记录
  static Future<Map<String, dynamic>?> deleteWatchHistory(
    String videoId,
  ) async {
    final id = int.parse(videoId);
    return await NetworkHelper.delete('/user/history/$id');
  }

  /// 清空观看历史
  static Future<Map<String, dynamic>?> clearWatchHistory() async {
    return await NetworkHelper.delete('/user/history/clear');
  }

  /// 获取视频观看进度
  static Future<Map<String, dynamic>?> getWatchProgress(String videoId) async {
    final id = int.parse(videoId);
    return await NetworkHelper.get('/user/history/progress/$id');
  }

  // ==================== 收藏相关接口 ====================

  /// 获取收藏列表
  static Future<Map<String, dynamic>?> getFavorites({
    int pageNum = 1,
    int pageSize = ApiConstants.defaultPageSize,
  }) async {
    return await NetworkHelper.get(
      ApiConstants.userFavorites,
      queryParams: {
        'pageNum': pageNum.toString(),
        'pageSize': pageSize.toString(),
      },
    );
  }

  /// 添加收藏
  static Future<Map<String, dynamic>?> addFavorite(String dramaId) async {
    final id = int.parse(dramaId);
    return await NetworkHelper.post('/user/favorites/$id', {});
  }

  /// 取消收藏
  static Future<Map<String, dynamic>?> removeFavorite(String dramaId) async {
    final id = int.parse(dramaId);
    return await NetworkHelper.delete('/user/favorites/$id');
  }

  /// 切换收藏状态
  static Future<Map<String, dynamic>?> toggleFavorite(String dramaId) async {
    final id = int.parse(dramaId);
    return await NetworkHelper.post('/user/favorites/toggle/$id', {});
  }

  /// 检查收藏状态
  static Future<Map<String, dynamic>?> checkFavorite(String dramaId) async {
    final id = int.parse(dramaId);
    return await NetworkHelper.get('/user/favorites/check/$id');
  }
}
