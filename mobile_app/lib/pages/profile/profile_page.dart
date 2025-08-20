import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../auth/login_page.dart';
import 'favorites_page.dart';
import 'watch_history_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的'), centerTitle: true, elevation: 0),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            children: [
              // 用户信息区域
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _handleUserInfoTap(context, appState),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      // 用户头像
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: appState.currentUser?.userAvatar != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  appState.currentUser!.userAvatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.isLoggedIn
                                  ? appState.currentUser!.displayName
                                  : '未登录用户',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.isLoggedIn
                                  ? appState.currentUser!.userProfile ??
                                        '这个人很懒，什么都没留下'
                                  : '点击登录享受更多功能',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        appState.isLoggedIn
                            ? Icons.edit
                            : Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 功能列表
              _buildMenuItem(
                context,
                icon: Icons.history,
                title: '观看历史',
                subtitle: '查看最近观看的剧集',
                onTap: () => _navigateToPage(
                  context,
                  appState,
                  const WatchHistoryPage(),
                ),
              ),

              _buildMenuItem(
                context,
                icon: Icons.favorite,
                title: '我的收藏',
                subtitle: '收藏的精彩剧集',
                onTap: () =>
                    _navigateToPage(context, appState, const FavoritesPage()),
              ),

              _buildMenuItem(
                context,
                icon: Icons.download,
                title: '离线下载',
                subtitle: '已下载的剧集',
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('下载功能开发中...')));
                },
              ),

              _buildMenuItem(
                context,
                icon: Icons.settings,
                title: '设置',
                subtitle: '应用设置和偏好',
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('设置功能开发中...')));
                },
              ),

              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: '帮助与反馈',
                subtitle: '使用帮助和问题反馈',
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('帮助功能开发中...')));
                },
              ),

              // 登出按钮（仅登录时显示）
              if (appState.isLoggedIn) ...[
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: appState.isLoading
                        ? null
                        : () => _handleLogout(context, appState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red[200]!),
                      ),
                    ),
                    child: appState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('登出', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 处理用户信息区域点击
  void _handleUserInfoTap(BuildContext context, AppState appState) {
    if (!appState.isLoggedIn) {
      // 未登录，跳转到登录页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // 已登录，跳转到用户信息编辑页面（待实现）
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('用户信息编辑功能开发中...')));
    }
  }

  /// 导航到指定页面（需要登录）
  void _navigateToPage(BuildContext context, AppState appState, Widget page) {
    if (!appState.isLoggedIn) {
      // 未登录，提示用户登录
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  /// 处理登出
  Future<void> _handleLogout(BuildContext context, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认登出'),
        content: const Text('确定要登出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await appState.logout();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已成功登出')));
      }
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
