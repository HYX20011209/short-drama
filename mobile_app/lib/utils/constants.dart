import 'dart:io';

class ApiConstants {
  // 根据平台动态选择API地址
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android模拟器访问主机的特殊地址
      return 'http://10.0.2.2:8101/api';
    } else {
      // iOS模拟器和其他平台
      return 'http://127.0.0.1:8101/api';
      // return 'http://172.20.10.14:8101/api';
    }
  }

  // API端点
  static const String videoFeed = '/video/feed';
  static const String dramaList = '/drama/list';
  static const String dramaSearch = '/drama/search';
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
