import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../player/video_player_page.dart';

class RecommendPage extends StatelessWidget {
  final ValueListenable<bool> isActiveListenable;
  const RecommendPage({Key? key, required this.isActiveListenable})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 复用现有的播放页作为发现流承载，增加可见性控制
    return VideoPlayerPage(isActiveListenable: isActiveListenable);
  }
}
