import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// 应用主题配置
/// 统一管理浅色和深色主题
class AppTheme {
  AppTheme._();

  // ==================== 浅色主题 ====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 颜色方案
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.accent,
        surface: AppColors.lightSurface,
        surfaceVariant: AppColors.lightSurfaceVariant,
        background: AppColors.lightBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        onBackground: AppColors.lightOnBackground,
        onError: Colors.white,
        outline: AppColors.lightOnSurfaceVariant,
      ),

      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingXS,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // 底部导航主题 - 修正：使用 BottomNavigationBarThemeData
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // 卡片主题 - 修正：使用 CardThemeData
      cardTheme: CardThemeData(
        color: AppColors.lightBackground,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        margin: const EdgeInsets.all(AppDimensions.spacingSM),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLG,
          vertical: AppDimensions.spacingMD,
        ),
        hintStyle: AppTextStyles.withColor(
          AppTextStyles.bodyMedium,
          AppColors.lightOnSurfaceVariant,
        ),
      ),

      // 文本主题
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headingXL,
        displayMedium: AppTextStyles.headingLG,
        displaySmall: AppTextStyles.headingMD,
        headlineLarge: AppTextStyles.headingMD,
        headlineMedium: AppTextStyles.headingSM,
        headlineSmall: AppTextStyles.headingXS,
        titleLarge: AppTextStyles.headingXS,
        titleMedium: AppTextStyles.bodyLarge,
        titleSmall: AppTextStyles.bodyMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // 其他组件主题
      dividerTheme: const DividerThemeData(
        color: AppColors.lightSurfaceVariant,
        thickness: AppDimensions.dividerThickness,
        indent: AppDimensions.dividerIndent,
        endIndent: AppDimensions.dividerIndent,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMD,
          vertical: AppDimensions.spacingXS,
        ),
      ),
    );
  }

  // ==================== 深色主题 ====================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 颜色方案
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.darkSurface,
        surfaceVariant: AppColors.darkSurfaceVariant,
        background: AppColors.darkBackground,
        error: AppColors.error,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkBackground,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        onBackground: AppColors.darkOnBackground,
        onError: AppColors.darkBackground,
        outline: AppColors.darkOnSurfaceVariant,
      ),

      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingXS,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // 底部导航主题 - 修正：使用 BottomNavigationBarThemeData
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // 卡片主题 - 修正：使用 CardThemeData
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        margin: const EdgeInsets.all(AppDimensions.spacingSM),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.darkBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMedium,
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLG,
          vertical: AppDimensions.spacingMD,
        ),
        hintStyle: AppTextStyles.withColor(
          AppTextStyles.bodyMedium,
          AppColors.darkOnSurfaceVariant,
        ),
      ),

      // 文本主题
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headingXL,
        displayMedium: AppTextStyles.headingLG,
        displaySmall: AppTextStyles.headingMD,
        headlineLarge: AppTextStyles.headingMD,
        headlineMedium: AppTextStyles.headingSM,
        headlineSmall: AppTextStyles.headingXS,
        titleLarge: AppTextStyles.headingXS,
        titleMedium: AppTextStyles.bodyLarge,
        titleSmall: AppTextStyles.bodyMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // 其他组件主题
      dividerTheme: const DividerThemeData(
        color: AppColors.darkSurfaceVariant,
        thickness: AppDimensions.dividerThickness,
        indent: AppDimensions.dividerIndent,
        endIndent: AppDimensions.dividerIndent,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryLight,
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMD,
          vertical: AppDimensions.spacingXS,
        ),
      ),
    );
  }
}
