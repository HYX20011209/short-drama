import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 应用阴影系统
/// 定义了统一的阴影效果，创建层次感
class AppShadows {
  AppShadows._();

  // ==================== 基础阴影 ====================
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x19000000), // 10% opacity
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> extraLarge = [
    BoxShadow(
      color: Color(0x1F000000), // 12% opacity
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // ==================== 特殊效果阴影 ====================
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x28000000), // 16% opacity
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> pressed = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // ==================== 彩色阴影 ====================
  static List<BoxShadow> primaryGlow({double opacity = 0.3}) => [
    BoxShadow(
      color: AppColors.primary.withOpacity(opacity),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> secondaryGlow({double opacity = 0.3}) => [
    BoxShadow(
      color: AppColors.secondary.withOpacity(opacity),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> errorGlow({double opacity = 0.3}) => [
    BoxShadow(
      color: AppColors.error.withOpacity(opacity),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // ==================== 视频应用专用阴影 ====================
  static const List<BoxShadow> dramaCard = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> dramaCardHover = [
    BoxShadow(
      color: Color(0x1F000000), // 12% opacity
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Color(0x33000000), // 20% opacity
      offset: Offset(0, -4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
}
