import 'package:flutter/material.dart';

/// 自定义页面转场动画集合
class CustomPageTransitions {
  CustomPageTransitions._();

  /// 滑动淡入转场动画
  static PageRouteBuilder<T> slideAndFadeTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 400),
    Offset beginOffset = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;

        // 滑动动画
        final slideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        // 淡入动画
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: curve),
          ),
        );

        // 缩放动画（轻微）
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          ),
        );
      },
    );
  }

  /// 底部滑入转场动画（适用于详情页）
  static PageRouteBuilder<T> bottomSlideTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: curve),
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  /// 缩放淡入转场动画（适用于播放器页面）
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutBack;

        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  /// 搜索页面专用转场动画
  static PageRouteBuilder<T> searchTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutQuart;

        // 从右上角滑入
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.3, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: curve),
          ),
        );

        final scaleAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          ),
        );
      },
    );
  }
}

/// 扩展Navigator，添加自定义转场方法
extension NavigatorExtensions on NavigatorState {
  /// 使用滑动淡入动画推送页面
  Future<T?> pushWithSlideAndFade<T extends Object?>(Widget page) {
    return push<T>(CustomPageTransitions.slideAndFadeTransition<T>(page: page));
  }

  /// 使用底部滑入动画推送页面
  Future<T?> pushWithBottomSlide<T extends Object?>(Widget page) {
    return push<T>(CustomPageTransitions.bottomSlideTransition<T>(page: page));
  }

  /// 使用缩放动画推送页面
  Future<T?> pushWithScale<T extends Object?>(Widget page) {
    return push<T>(CustomPageTransitions.scaleTransition<T>(page: page));
  }

  /// 使用搜索动画推送页面
  Future<T?> pushWithSearch<T extends Object?>(Widget page) {
    return push<T>(CustomPageTransitions.searchTransition<T>(page: page));
  }
}
