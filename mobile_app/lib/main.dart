import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

// 根据运行环境修改为你的后端地址：模拟器可用 http://127.0.0.1:8101
// 真机需改为你电脑的局域网 IP，例如 http://192.168.1.10:8101
const String kApiBase = 'http://127.0.0.1:8101/api';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VerticalFeedPage(),
    ),
  );
}

class VideoItem {
  final int id;
  final String url;
  final String? title;
  final String? cover;
  final int? duration;
  VideoItem({
    required this.id,
    required this.url,
    this.title,
    this.cover,
    this.duration,
  });
  // factory VideoItem.fromJson(Map<String, dynamic> j) =>
  //     VideoItem(id: j['id'], url: j['videoUrl'], title: j['title'], cover: j['coverUrl'], duration: j['durationSec']);
  factory VideoItem.fromJson(Map<String, dynamic> j) {
    int? parseIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      final s = v.toString();
      return s.isEmpty ? null : int.tryParse(s);
    }

    return VideoItem(
      id: parseIntOrNull(j['id']) ?? 0,
      url: j['videoUrl'] ?? '',
      title: j['title'],
      cover: j['coverUrl'],
      duration: parseIntOrNull(j['durationSec']),
    );
  }
}

class VerticalFeedPage extends StatefulWidget {
  const VerticalFeedPage({super.key});
  @override
  State<VerticalFeedPage> createState() => _VerticalFeedPageState();
}

class _VerticalFeedPageState extends State<VerticalFeedPage> {
  final PageController _pageController = PageController();
  final List<VideoItem> _items = [];
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _userPausedVideos = {};
  int _currentIndex = 0;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore().then((_) => _playAt(0));
  }

  void _togglePlay(int index) {
    // 确保操作的是当前页面的视频
    if (index != _currentIndex || index < 0 || index >= _items.length) return;

    final key = _items[index].id;
    final c = _controllers[key];

    if (c == null || !c.value.isInitialized) return;

    if (c.value.isPlaying) {
      // 用户主动暂停
      c.pause();
      _userPausedVideos.add(key);
    } else {
      // 用户主动播放
      c.play();
      _userPausedVideos.remove(key);
    }
    setState(() {}); // 刷新UI
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    _loading = true;
    try {
      final uri = Uri.parse(
        '$kApiBase/video/feed?current=$_currentPage&pageSize=$_pageSize',
      );
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final page = data['data'];
        final List list = page['records'] ?? [];
        final items = list
            .map((e) => VideoItem.fromJson(e))
            .cast<VideoItem>()
            .toList();
        setState(() {
          _items.addAll(items);
          _currentPage++;
          _hasMore = items.length >= _pageSize;
        });
        _preload(_currentIndex);
        _preload(_currentIndex + 1);
      } else {
        debugPrint('feed error: ${res.statusCode} ${res.body}');
      }
    } finally {
      _loading = false;
    }
  }

  void _preload(int index) {
    if (index < 0 || index >= _items.length) return;
    final key = _items[index].id;
    if (_controllers.containsKey(key)) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(_items[index].url));
    c.initialize().then((_) {
      c.setLooping(true);
      setState(() {});
    });
    _controllers[key] = c;
  }

  void _disposeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    final key = _items[index].id;
    _controllers.remove(key)?.dispose();
  }

  void _waitForInitAndPlay(int videoId) async {
    // 等待视频初始化完成
    int attempts = 0;
    const maxAttempts = 50; // 最多等待5秒

    while (attempts < maxAttempts) {
      final c = _controllers[videoId];
      if (c != null && c.value.isInitialized) {
        // 检查这个视频是否仍然是当前视频，且用户没有主动暂停
        if (_currentIndex < _items.length &&
            _items[_currentIndex].id == videoId &&
            !_userPausedVideos.contains(videoId)) {
          c.play();
          // 确保UI更新
          setState(() {});
        }
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  void _playAt(int index) {
    if (index < 0 || index >= _items.length) return;

    // 暂停上一条
    if (_currentIndex != index && _currentIndex < _items.length) {
      final prevKey = _items[_currentIndex].id;
      _controllers[prevKey]?.pause();
    }

    _currentIndex = index;
    final key = _items[index].id;

    // 切换到新视频时，清除暂停状态（自动播放）
    bool wasUserPaused = _userPausedVideos.contains(key);
    _userPausedVideos.remove(key);

    // 如果之前是用户暂停的，需要更新UI
    if (wasUserPaused) {
      setState(() {});
    }

    final c = _controllers[key];
    if (c != null && c.value.isInitialized) {
      c.play();
    } else {
      _preload(index);
      _waitForInitAndPlay(key);
    }

    _preload(index + 1);
    _disposeAt(index - 2);
    if (index >= _items.length - 3) _loadMore();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (i) => _playAt(i),
        itemCount: _items.length == 0 ? 1 : _items.length,
        itemBuilder: (context, index) {
          if (_items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final item = _items[index];
          final c = _controllers[item.id];
          final isUserPaused = _userPausedVideos.contains(item.id);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _togglePlay(index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (c != null && c.value.isInitialized)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: c.value.size.width,
                      height: c.value.size.height,
                      child: VideoPlayer(c),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                // 只在用户主动暂停时显示播放按钮
                if (c != null && c.value.isInitialized && isUserPaused)
                  const Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 72,
                      color: Colors.white70,
                    ),
                  ),

                Positioned(
                  left: 16,
                  bottom: 40,
                  right: 16,
                  child: Text(
                    item.title ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
