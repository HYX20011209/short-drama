import 'package:flutter/material.dart';

import '../../models/watch_history.dart';
import '../../services/watch_history_service.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../player/video_player_page.dart';

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
      final result = await WatchHistoryService.getWatchHistory();
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
        title: const Text('Watch History'),
        centerTitle: true,
        actions: [
          if (histories.isNotEmpty)
            TextButton(
              onPressed: () => _showClearHistoryDialog(),
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const LoadingWidget(message: 'Loading...');
    }

    if (errorMessage != null) {
      return CustomErrorWidget(message: errorMessage!, onRetry: _loadHistory);
    }

    if (histories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No watch history yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
    return Dismissible(
      key: Key(history.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Delete this watch history item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteHistoryItem(history),
      child: Container(
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
                    history.drama?.title ?? 'Unknown Drama',
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
                      'Watched Episode ${history.episodeNumber}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    'Progress: ${history.formattedProgress}',
                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(history.lastWatchTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // 继续观看按钮
            ElevatedButton(
              onPressed: () => _continueWatching(history),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// 显示清空历史对话框
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Clear all watch history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// 清空观看历史
  Future<void> _clearHistory() async {
    try {
      final success = await WatchHistoryService.clearWatchHistory();
      if (success) {
        setState(() {
          histories.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('History cleared')));
        }
      } else {
        throw Exception('History clear failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Clear history failed: $e')));
      }
    }
  }

  /// 删除单条历史记录
  Future<void> _deleteHistoryItem(WatchHistory history) async {
    try {
      final success = await WatchHistoryService.deleteWatchHistory(
        history.videoId, // 直接传递String类型的videoId
      );
      if (success) {
        setState(() {
          histories.remove(history);
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Item deleted')));
        }
      } else {
        throw Exception('Delete failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  /// 继续观看功能
  void _continueWatching(WatchHistory history) {
    try {
      if (history.dramaId != null) {
        // 如果是剧集，跳转到剧集播放器
        final dramaId = int.parse(history.dramaId!);
        final episodeNumber = history.episodeNumber ?? 1;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VideoPlayerPage(dramaId: dramaId, startEpisode: episodeNumber),
          ),
        );
      } else {
        // 如果是单独视频，这里需要根据实际情况处理
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon...')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot Play $e')));
    }
  }
}
