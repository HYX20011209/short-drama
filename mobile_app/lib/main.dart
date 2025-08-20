import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/main_tab_page.dart';
import 'providers/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: '短剧',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AppInitializer(),
      ),
    );
  }
}

/// 应用初始化器
/// 负责在应用启动时初始化用户状态
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // 初始化应用状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // 显示加载状态
        if (appState.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在初始化...'),
                ],
              ),
            ),
          );
        }

        // 初始化完成，进入主页面
        return const MainTabPage();
      },
    );
  }
}
