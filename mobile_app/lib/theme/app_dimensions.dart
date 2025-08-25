/// 应用尺寸和间距系统
/// 定义了统一的尺寸标准，确保视觉一致性
class AppDimensions {
  AppDimensions._();

  // ==================== 间距系统 ====================
  static const double spacingXXS = 2.0;   // 极小间距
  static const double spacingXS = 4.0;    // 很小间距
  static const double spacingSM = 8.0;    // 小间距
  static const double spacingMD = 12.0;   // 中等间距
  static const double spacingLG = 16.0;   // 大间距
  static const double spacingXL = 20.0;   // 很大间距
  static const double spacingXXL = 24.0;  // 极大间距
  static const double spacing3XL = 32.0;  // 超大间距
  static const double spacing4XL = 40.0;  // 超超大间距

  // ==================== 圆角系统 ====================
  static const double radiusXS = 4.0;     // 极小圆角
  static const double radiusSM = 6.0;     // 小圆角
  static const double radiusMD = 8.0;     // 中等圆角
  static const double radiusLG = 12.0;    // 大圆角
  static const double radiusXL = 16.0;    // 很大圆角
  static const double radiusXXL = 20.0;   // 极大圆角
  static const double radiusFull = 999.0; // 完全圆角

  // ==================== 组件尺寸 ====================
  // 按钮
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  static const double buttonMinWidth = 64.0;

  // 图标
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;

  // 头像
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 56.0;
  static const double avatarSizeXLarge = 72.0;

  // 卡片
  static const double cardElevation = 2.0;
  static const double cardMaxElevation = 8.0;

  // ==================== 视频应用专用尺寸 ====================
  // 剧集卡片
  static const double dramaCardAspectRatio = 0.75; // 3:4 比例
  static const double dramaCardHeight = 200.0;
  static const double dramaCardGridSpacing = 12.0;

  // 播放器
  static const double playerControlsHeight = 60.0;
  static const double playerProgressBarHeight = 4.0;
  static const double playerButtonSize = 48.0;

  // 底部导航
  static const double bottomNavHeight = 60.0;
  static const double bottomNavIconSize = 24.0;

  // AppBar
  static const double appBarHeight = 56.0;
  static const double searchBarHeight = 48.0;

  // ==================== 边框和线条 ====================
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;

  // 分割线
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;
}