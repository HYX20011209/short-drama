import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 应用字体样式系统
/// 定义了统一的文字样式，确保排版一致性
class AppTextStyles {
  AppTextStyles._();

  // ==================== 字体家族 ====================
  static const String primaryFontFamily = 'SF Pro Display'; // iOS风格
  static const String secondaryFontFamily = 'Roboto'; // Android风格

  // ==================== 标题样式 ====================
  static const TextStyle headingXL = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700, // Bold
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headingLG = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle headingMD = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const TextStyle headingSM = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500, // Medium
    height: 1.35,
    letterSpacing: -0.1,
  );

  static const TextStyle headingXS = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500, // Medium
    height: 1.4,
  );

  // ==================== 正文样式 ====================
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    letterSpacing: 0.0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    letterSpacing: 0.0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
    letterSpacing: 0.2,
  );

  // ==================== 标签和说明文字 ====================
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500, // Medium
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500, // Medium
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500, // Medium
    height: 1.4,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w400, // Regular
    height: 1.3,
    letterSpacing: 0.4,
  );

  // ==================== 按钮样式 ====================
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
    letterSpacing: 0.3,
  );

  // ==================== 应用专用样式 ====================
  // 剧集标题
  static const TextStyle dramaTitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.3,
    letterSpacing: -0.1,
  );

  // 剧集副标题
  static const TextStyle dramaSubtitle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400, // Regular
    height: 1.4,
    letterSpacing: 0.1,
  );

  // 分类标签
  static const TextStyle categoryTag = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2,
    letterSpacing: 0.5,
  );

  // 播放器标题
  static const TextStyle playerTitle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2,
    color: Colors.white,
    shadows: [
      Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black45),
    ],
  );

  // ==================== 颜色变体方法 ====================
  /// 返回带有指定颜色的文本样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 返回带有主色调的文本样式
  static TextStyle withPrimary(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }

  /// 返回带有次要色调的文本样式
  static TextStyle withSecondary(TextStyle style) {
    return style.copyWith(color: AppColors.secondary);
  }

  /// 返回带有错误颜色的文本样式
  static TextStyle withError(TextStyle style) {
    return style.copyWith(color: AppColors.error);
  }

  /// 返回带有成功颜色的文本样式
  static TextStyle withSuccess(TextStyle style) {
    return style.copyWith(color: AppColors.success);
  }
}
