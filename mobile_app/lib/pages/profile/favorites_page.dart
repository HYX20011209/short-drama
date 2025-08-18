import 'package:flutter/material.dart';
import '../../models/drama.dart';
import '../../services/user_service.dart';
import '../../widgets/drama_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../player/video_player_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Drama> favorites = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await UserService.getFavorites();
      setState(() {
        favorites = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = '加载失败: $e';
      });
    }
  }

  void _playDrama(Drama drama) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          dramaId: drama.id,
          startEpisode: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
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
        onRetry: _loadFavorites,
      );
    }

    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无收藏',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '快去收藏喜欢的剧集吧',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return DramaCard(
            drama: favorites[index],
            onTap: () => _playDrama(favorites[index]),
          );
        },
      ),
    );
  }
}