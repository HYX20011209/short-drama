import 'package:flutter/material.dart';

import '../../models/drama.dart';
import '../../services/favorite_service.dart';
import '../player/video_player_page.dart';

class DramaDetailPage extends StatelessWidget {
  final Drama drama;

  const DramaDetailPage({Key? key, required this.drama}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cover = drama.coverUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('剧集详情'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部封面
            AspectRatio(
              aspectRatio: 16 / 9,
              child: cover != null && cover.isNotEmpty
                  ? Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _coverPlaceholder();
                      },
                    )
                  : _coverPlaceholder(),
            ),

            // 基本信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drama.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (drama.category != null && drama.category!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            drama.category!,
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        '共${drama.totalEpisodes}集',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (drama.description != null &&
                      drama.description!.isNotEmpty)
                    Text(
                      drama.description!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                ],
              ),
            ),

            // 操作区
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('立即播放'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        try {
                          final dramaId = int.parse(drama.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoPlayerPage(
                                dramaId: dramaId,
                                startEpisode: 1,
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('无效的剧集ID: ${drama.id}')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('收藏'),
                    onPressed: () async {
                      try {
                        // TODO: 根据当前收藏状态显示不同图标
                        final result = await FavoriteService.toggleFavorite(
                          drama.id,
                        );
                        if (result != null) {
                          final message = result ? '已添加到收藏' : '已取消收藏';
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 选集（占位，待后端完成 /drama/{id}/episodes 后接入）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '选集（待接入）',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  drama.totalEpisodes.clamp(0, 12), // 占位最多12个
                  (i) => OutlinedButton(
                    onPressed: () {
                      try {
                        final dramaId = int.parse(drama.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(
                              dramaId: dramaId,
                              startEpisode: i + 1,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('无效的剧集ID: ${drama.id}')),
                        );
                      }
                    },
                    child: Text('第${i + 1}集'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.movie, size: 48, color: Colors.grey),
      ),
    );
  }
}
