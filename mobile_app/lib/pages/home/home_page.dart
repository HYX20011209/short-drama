import 'package:flutter/material.dart';
import '../../models/drama.dart';
import '../../services/drama_service.dart';
import '../../widgets/drama_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../player/video_player_page.dart';
import '../drama_detail/drama_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Drama> dramas = [];
  bool loading = true;
  String? errorMessage;
  String? selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadCategories(), _loadDramas()]);
  }

  Future<void> _loadCategories() async {
    try {
      final result = await DramaService.getCategories();
      setState(() {
        categories = ['全部', ...result];
      });
    } catch (e) {
      print('加载分类失败: $e');
    }
  }

  Future<void> _loadDramas() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await DramaService.getDramaList(
        category: selectedCategory == '全部' ? null : selectedCategory,
      );
      setState(() {
        dramas = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = '加载失败: $e';
      });
    }
  }

  void _onCategoryChanged(String? category) {
    if (category != selectedCategory) {
      setState(() {
        selectedCategory = category;
      });
      _loadDramas();
    }
  }

  void _playDrama(Drama drama) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DramaDetailPage(drama: drama)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('短剧'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('搜索功能开发中...')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类选择器
          if (categories.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      selectedCategory == category ||
                      (selectedCategory == null && category == '全部');

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _onCategoryChanged(
                        category == '全部' ? null : category,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 主要内容区域
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const LoadingWidget(message: '加载中...');
    }

    if (errorMessage != null) {
      return CustomErrorWidget(message: errorMessage!, onRetry: _loadDramas);
    }

    if (dramas.isEmpty) {
      return const Center(
        child: Text('暂无剧集', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDramas,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: dramas.length,
        itemBuilder: (context, index) {
          return DramaCard(
            drama: dramas[index],
            onTap: () => _playDrama(dramas[index]),
          );
        },
      ),
    );
  }
}
