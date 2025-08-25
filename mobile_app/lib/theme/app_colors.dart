import 'package:flutter/material.dart';

/// 应用颜色系统
/// 定义了浅色和深色主题下的所有颜色
class AppColors {
  AppColors._();

  // ==================== 主要颜色 ====================
  // 主色调 - 渐变蓝紫色系
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400

  // 次要色调 - 粉紫色系
  static const Color secondary = Color(0xFFEC4899); // Pink-500
  static const Color secondaryDark = Color(0xFFDB2777); // Pink-600
  static const Color secondaryLight = Color(0xFFF472B6); // Pink-400

  // 强调色
  static const Color accent = Color(0xFF06B6D4); // Cyan-500
  static const Color accentDark = Color(0xFF0891B2); // Cyan-600

  // ==================== 语义化颜色 ====================
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  // ==================== 中性色 ====================
  // 浅色主题
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC); // Slate-50
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate-100
  static const Color lightOnBackground = Color(0xFF0F172A); // Slate-900
  static const Color lightOnSurface = Color(0xFF334155); // Slate-700
  static const Color lightOnSurfaceVariant = Color(0xFF64748B); // Slate-500

  // 深色主题
  static const Color darkBackground = Color(0xFF0F172A); // Slate-900
  static const Color darkSurface = Color(0xFF1E293B); // Slate-800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate-700
  static const Color darkOnBackground = Color(0xFFF8FAFC); // Slate-50
  static const Color darkOnSurface = Color(0xFFE2E8F0); // Slate-200
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8); // Slate-400

  // ==================== 渐变色 ====================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC), // Slate-50
      Color(0xFFE2E8F0), // Slate-200
    ],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A), // Slate-900
      Color(0xFF1E293B), // Slate-800
    ],
  );

  // ==================== 视频应用专用颜色 ====================
  static const Color playerBackground = Color(0xFF000000);
  static const Color playerOverlay = Color(0x80000000);
  static const Color favoriteColor = Color(0xFFEF4444); // Red-500
  static const Color ratingColor = Color(0xFFFBBF24); // Amber-400

  // ==================== 透明度变体 ====================
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);
  static Color surfaceWithOpacity(double opacity) =>
      lightSurface.withOpacity(opacity);
  static Color overlayColor(double opacity) =>
      const Color(0xFF000000).withOpacity(opacity);
}
