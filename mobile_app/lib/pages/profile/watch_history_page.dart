import 'package:flutter/material.dart';
import '../../models/watch_history.dart';
import '../../services/user_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class WatchHistoryPage extends StatefulWidget {
  const WatchHistoryPage({Key? key}) : super(key: key);

  @override
  State<WatchHistoryPage> createState() => _WatchHistoryPageState();
}

class _WatchHistoryPageState extends State<WatchHistoryPage> {
  List<WatchHistory> histories = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await UserService.getWatchHistory();
      setState(() {
        histories = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = '加载失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('观看历史'),
        centerTitle: true,
        actions: [
          if (histories.isNotEmpty)
            TextButton(
              onPressed: () {
                // TODO: 实现清空历史功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('清空功能开发中...')),
                );
              },
              child: const Text('清空', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const LoadingWidget(message: '加载中...');
    }

    if (errorMessage != null) {
      return CustomErrorWidget(
        message: errorMessage!,
        onRetry: _loadHistory,
      );
    }

    if (histories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无观看历史',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: histories.length,
        itemBuilder: (context, index) {
          final history = histories[index];
          return _buildHistoryItem(history);
        },
      ),
    );
  }

  Widget _buildHistoryItem(WatchHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // 封面缩略图
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: history.drama?.coverUrl != null
                  ? Image.network(
                      history.drama!.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.movie, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.movie, color: Colors.grey),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 剧集信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.drama?.title ?? '未知剧集',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (history.episodeNumber != null)
                  Text(
                    '观看到第${history.episodeNumber}集',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(history.lastWatchTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // 继续观看按钮
          ElevatedButton(
            onPressed: () {
              // TODO: 跳转到播放页面继续观看
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('继续观看功能开发中...')),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('继续观看', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}