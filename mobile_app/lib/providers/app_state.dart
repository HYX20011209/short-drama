import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../utils/network_helper.dart';

/// 用户状态管理类
/// 负责管理用户登录状态、用户信息存储和持久化
class AppState extends ChangeNotifier {
  // 私有变量
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  // 常量定义
  static const String _userKey = 'current_user';
  static const String _loginStatusKey = 'is_logged_in';

  // Getter方法
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 初始化应用状态
  /// 从本地存储中恢复用户登录状态
  Future<void> initializeApp() async {
    _setLoading(true);
    try {
      await _loadUserFromStorage();

      // 验证登录状态是否有效
      if (_isLoggedIn && _currentUser != null) {
        final isValid = await _validateStoredLoginStatus();
        if (!isValid) {
          // 如果登录状态无效，清除本地存储
          await _clearLoginState();
        }
      }
    } catch (e) {
      _setError('初始化失败: $e');
      // 初始化失败时清除可能损坏的状态
      await _clearLoginState();
    } finally {
      _setLoading(false);
    }
  }

  /// 用户登录
  /// [userAccount] 用户账号
  /// [password] 用户密码
  /// 返回登录是否成功
  Future<bool> login(String userAccount, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // 调用登录服务
      final user = await UserService.login(userAccount, password);

      if (user != null) {
        await _setUser(user, true);
        return true;
      } else {
        _setError('登录失败，请检查账号密码');
        return false;
      }
    } catch (e) {
      _setError('登录失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 用户注册
  /// [userAccount] 用户账号
  /// [password] 用户密码
  /// [confirmPassword] 确认密码
  /// 返回注册是否成功
  Future<bool> register(
    String userAccount,
    String password,
    String confirmPassword,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // 基础验证
      if (password != confirmPassword) {
        _setError('两次输入的密码不一致');
        return false;
      }

      // 调用注册服务
      final success = await UserService.register(
        userAccount,
        password,
        confirmPassword,
      );

      if (success) {
        // 注册成功后自动登录
        return await login(userAccount, password);
      } else {
        _setError('注册失败，请稍后重试');
        return false;
      }
    } catch (e) {
      _setError('注册失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 用户登出
  Future<void> logout() async {
    _setLoading(true);
    try {
      // 清除本地用户信息和存储
      await _setUser(null, false);
      await _clearStorage();

      // 清除Cookie
      NetworkHelper.clearCookies();
    } catch (e) {
      _setError('登出失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新用户信息
  /// [user] 新的用户信息
  Future<void> updateUserInfo(User user) async {
    if (_currentUser?.id == user.id) {
      await _setUser(user, true);
    }
  }

  /// 检查登录状态是否有效
  /// 可用于页面切换时验证token有效性
  Future<bool> validateLoginStatus() async {
    if (!_isLoggedIn || _currentUser == null) {
      return false;
    }

    try {
      // 这里可以调用后端验证token的接口
      // 目前先返回true，后续可以扩展
      return true;
    } catch (e) {
      // 验证失败，清除登录状态
      await logout();
      return false;
    }
  }

  // ==================== 私有方法 ====================

  /// 设置用户信息和登录状态
  Future<void> _setUser(User? user, bool isLoggedIn) async {
    _currentUser = user;
    _isLoggedIn = isLoggedIn;

    // 保存到本地存储
    if (user != null && isLoggedIn) {
      await _saveUserToStorage(user);
    }

    notifyListeners();
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误信息
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 从本地存储加载用户信息
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 检查登录状态
      final isLoggedIn = prefs.getBool(_loginStatusKey) ?? false;
      if (!isLoggedIn) {
        return;
      }

      // 加载用户信息
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);

        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载用户信息失败: $e');
      // 如果加载失败，清除可能损坏的数据
      await _clearStorage();
    }
  }

  /// 保存用户信息到本地存储
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());

      await prefs.setString(_userKey, userJson);
      await prefs.setBool(_loginStatusKey, true);
    } catch (e) {
      debugPrint('保存用户信息失败: $e');
    }
  }

  /// 清除本地存储
  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_loginStatusKey);
    } catch (e) {
      debugPrint('清除本地存储失败: $e');
    }
  }

  /// 验证存储的登录状态是否有效
  Future<bool> _validateStoredLoginStatus() async {
    try {
      // 尝试调用需要登录的接口验证状态
      final response = await ApiService.getCurrentUser();
      return response != null && response['data'] != null;
    } catch (e) {
      print('验证登录状态失败: $e');
      return false;
    }
  }

  /// 清除登录状态
  Future<void> _clearLoginState() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _clearStorage();
    notifyListeners();
  }
}
