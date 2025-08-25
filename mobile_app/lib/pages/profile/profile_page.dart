import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_page_transitions.dart';
import '../auth/login_page.dart';
import 'edit_profile_page.dart';
import 'favorites_page.dart';
import 'watch_history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // 启动动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.light
              ? AppColors.backgroundGradient
              : AppColors.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingLG,
                    ),
                    children: [
                      const SizedBox(height: AppDimensions.spacingLG),

                      // 用户信息卡片
                      _buildUserInfoCard(appState),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // 功能菜单
                      _buildMenuSection(appState),

                      // 登出按钮
                      if (appState.isLoggedIn) ...[
                        const SizedBox(height: AppDimensions.spacing3XL),
                        _buildLogoutButton(appState),
                        const SizedBox(height: AppDimensions.spacingXL),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), Colors.transparent],
          ),
        ),
      ),
      title: Text(
        'Profile',
        style: AppTextStyles.withPrimary(AppTextStyles.headingSM),
      ),
      centerTitle: true,
    );
  }

  Widget _buildUserInfoCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      decoration: BoxDecoration(
        gradient: appState.isLoggedIn
            ? AppColors.primaryGradient
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFE2E8F0) // Slate-200
                      : const Color(0xFF334155), // Slate-700
                  Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFF1F5F9) // Slate-100
                      : const Color(0xFF475569), // Slate-600
                ],
              ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.large,
      ),
      child: InkWell(
        onTap: () => _handleUserInfoTap(context, appState),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: Row(
          children: [
            // 头像
            _buildAvatar(appState),

            const SizedBox(width: AppDimensions.spacingLG),

            // 用户信息
            Expanded(child: _buildUserInfo(appState)),

            // 箭头图标
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingSM),
              decoration: BoxDecoration(
                color: appState.isLoggedIn
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
              child: Icon(
                appState.isLoggedIn
                    ? Icons.edit_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: AppDimensions.iconSizeMedium,
                color: appState.isLoggedIn ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(AppState appState) {
    return Container(
      width: AppDimensions.avatarSizeXLarge,
      height: AppDimensions.avatarSizeXLarge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: AppShadows.medium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: appState.currentUser?.userAvatar != null
            ? Image.network(
                appState.currentUser!.userAvatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarPlaceholder(),
              )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
      child: const Icon(Icons.person_rounded, size: 36, color: Colors.white),
    );
  }

  Widget _buildUserInfo(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.isLoggedIn
              ? appState.currentUser!.displayName
              : 'Guest User',
          style: appState.isLoggedIn
              ? AppTextStyles.withColor(AppTextStyles.headingXS, Colors.white)
              : AppTextStyles.withColor(
                  AppTextStyles.headingXS.copyWith(fontWeight: FontWeight.w600),
                  Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF1E293B) // Slate-800
                      : Colors.white,
                ),
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(
          appState.isLoggedIn
              ? appState.currentUser!.userProfile ?? 'No bio available'
              : 'Sign in to enjoy more features',
          style: appState.isLoggedIn
              ? AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  Colors.white.withOpacity(0.8),
                )
              : AppTextStyles.withColor(
                  AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF64748B) // Slate-500
                      : const Color(0xFFCBD5E1), // Slate-300
                ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMenuSection(AppState appState) {
    final menuItems = [
      {
        'icon': Icons.history_rounded,
        'title': 'Watch History',
        'subtitle': 'View recently watched dramas',
        'action': () =>
            _navigateToPage(context, appState, const WatchHistoryPage()),
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'My Favorites',
        'subtitle': 'Your favorite drama collection',
        'action': () =>
            _navigateToPage(context, appState, const FavoritesPage()),
      },
      {
        'icon': Icons.download_rounded,
        'title': 'Downloads',
        'subtitle': 'Downloaded episodes',
        'action': () =>
            _showComingSoon(context, 'Download feature coming soon...'),
      },
      {
        'icon': Icons.settings_rounded,
        'title': 'Settings',
        'subtitle': 'App settings and preferences',
        'action': () =>
            _showComingSoon(context, 'Settings feature coming soon...'),
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help & Feedback',
        'subtitle': 'Get help and send feedback',
        'action': () => _showComingSoon(context, 'Help feature coming soon...'),
      },
    ];

    return Column(
      children: menuItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
          child: _buildMenuItem(
            context,
            icon: item['icon'] as IconData,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            onTap: item['action'] as VoidCallback,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.small,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLG),
            child: Row(
              children: [
                // 图标容器
                Container(
                  width: AppDimensions.avatarSizeMedium,
                  height: AppDimensions.avatarSizeMedium,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient.scale(0.3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: AppDimensions.iconSizeMedium,
                  ),
                ),

                const SizedBox(width: AppDimensions.spacingLG),

                // 文本信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXXS),
                      Text(
                        subtitle,
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodySmall,
                          Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // 箭头
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppDimensions.iconSizeSmall,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.color!.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AppState appState) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.errorGlow(opacity: 0.2),
      ),
      child: ElevatedButton(
        onPressed: appState.isLoading
            ? null
            : () => _handleLogout(context, appState),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withOpacity(0.1),
          foregroundColor: AppColors.error,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingLG,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            side: BorderSide(color: AppColors.error.withOpacity(0.3)),
          ),
        ),
        child: appState.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              )
            : Text(
                'Sign Out',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
      ),
    );
  }

  // 显示"功能开发中"提示
  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
      ),
    );
  }

  /// 处理用户信息区域点击
  void _handleUserInfoTap(BuildContext context, AppState appState) {
    if (!appState.isLoggedIn) {
      Navigator.of(context).pushWithSlideAndFade(const LoginPage());
    } else {
      _navigateToEditProfile(context);
    }
  }

  /// 导航到编辑个人信息页面
  Future<void> _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).pushWithSlideAndFade(const EditProfilePage());

    // 如果编辑成功，显示成功提示
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      );
    }
  }

  /// 导航到指定页面（需要登录）
  void _navigateToPage(BuildContext context, AppState appState, Widget page) {
    if (!appState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in first'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      );
      Navigator.of(context).pushWithSlideAndFade(const LoginPage());
      return;
    }

    Navigator.of(context).pushWithSlideAndFade(page);
  }

  /// 处理登出
  Future<void> _handleLogout(BuildContext context, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        title: Text('Confirm Sign Out', style: AppTextStyles.headingXS),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.withColor(
                AppTextStyles.buttonMedium,
                AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
            child: Text(
              'Confirm',
              style: AppTextStyles.withColor(
                AppTextStyles.buttonMedium,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await appState.logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed out'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        );
      }
    }
  }
}
