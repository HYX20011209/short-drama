import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'home/home_page.dart';
import 'profile/profile_page.dart';
import 'recommend/recommend_page.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({Key? key}) : super(key: key);

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage>
    with TickerProviderStateMixin {
  // 新增：为动画提供支持
  int _currentIndex = 0;
  late final List<Widget> _pages;

  // 新增：动画控制器
  late AnimationController _bottomNavAnimationController;
  late Animation<double> _bottomNavAnimation;

  @override
  void initState() {
    super.initState();
    _pages = const [HomePage(), RecommendPage(), ProfilePage()];

    // 初始化底部导航动画
    _bottomNavAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bottomNavAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _bottomNavAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _bottomNavAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);

      // 触发底部导航动画
      _bottomNavAnimationController.reset();
      _bottomNavAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.1, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(
            context,
          ).bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightOnSurfaceVariant
              : AppColors.darkOnSurfaceVariant,
          selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall,
          items: [
            _buildBottomNavItem(
              icon: Icons.home_rounded,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
            ),
            _buildBottomNavItem(
              icon: Icons.play_circle_outline_rounded,
              activeIcon: Icons.play_circle_rounded,
              label: 'Explore',
              index: 1,
            ),
            _buildBottomNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _bottomNavAnimation,
        builder: (context, child) {
          return ScaleTransition(
            scale: isSelected
                ? _bottomNavAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingXS),
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMD,
                      ),
                    )
                  : null,
              child: Icon(
                isSelected ? activeIcon : icon,
                size: AppDimensions.iconSizeLarge,
              ),
            ),
          );
        },
      ),
      label: label,
    );
  }
}
