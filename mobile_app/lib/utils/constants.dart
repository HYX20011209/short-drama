class ApiConstants {
  // 根据运行环境修改为你的后端地址
  static const String baseUrl = 'http://127.0.0.1:8101/api';
  
  // API端点
  static const String videoFeed = '/video/feed';
  static const String dramaList = '/drama/list';
  static const String dramaDetail = '/drama';
  static const String dramaEpisodes = '/drama/{id}/episodes';
  static const String userHistory = '/user/history';
  static const String userFavorites = '/user/favorites';
  static const String userLogin = '/user/login';
  static const String userRegister = '/user/register';
  
  // 分页配置
  static const int defaultPageSize = 10;
  static const int maxPageSize = 20;
}

class AppConstants {
  static const String appName = '短剧';
  static const String defaultErrorMessage = '网络请求失败，请稍后重试';
}