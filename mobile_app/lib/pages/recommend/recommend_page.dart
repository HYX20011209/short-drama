import 'package:flutter/material.dart';
import '../player/video_player_page.dart';

class RecommendPage extends StatelessWidget {
  const RecommendPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 复用现有的播放页作为发现流承载（本步不改播放逻辑）
    return const VideoPlayerPage();
  }
}