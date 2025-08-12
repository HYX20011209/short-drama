import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

String baseApi() {
  // Android 模拟器访问宿主机需用 10.0.2.2；iOS 模拟器 / 桌面可用 127.0.0.1
  final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  return 'http://$host:8101/api';
}

Future<String> ping() async {
  final resp = await http.get(Uri.parse('${baseApi()}/ping'));
  if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
  final json = jsonDecode(resp.body);
  if (json is Map && json['code'] == 0) {
    return json['data']['message'] ?? 'pong';
  }
  throw Exception('接口异常: $json');
}

Future<List<dynamic>> fetchDramas() async {
  final resp = await http.get(Uri.parse('${baseApi()}/demo/dramas'));
  if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
  final json = jsonDecode(resp.body);
  if (json is Map && json['code'] == 0) {
    return json['data'] as List<dynamic>;
  }
  throw Exception('接口异常: $json');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Short Drama', home: const DemoPage());
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late Future<String> _pong;
  late Future<List<dynamic>> _dramas;

  @override
  void initState() {
    super.initState();
    _pong = ping();
    _dramas = fetchDramas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('短剧列表')),
      body: Column(
        children: [
          FutureBuilder<String>(
            future: _pong,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('正在 Ping 后端...'),
                );
              }
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Ping 失败: ${snap.error}'),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Text('后端连通：${snap.data}'),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _dramas,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('加载失败: ${snap.error}'));
                }
                final list = snap.data ?? [];
                if (list.isEmpty) return const Center(child: Text('暂无短剧'));
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final m = list[i] as Map<String, dynamic>;
                    return ListTile(
                      title: Text(m['title']?.toString() ?? ''),
                      subtitle: Text(m['season']?.toString() ?? ''),
                      trailing: Text('#${m['id']}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}