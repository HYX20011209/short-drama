import 'package:flutter/material.dart';
import '../../models/drama.dart';
import '../../services/drama_service.dart';
import '../../widgets/drama_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../drama_detail/drama_detail_page.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<Drama> searchResults = [];
  bool isLoading = false;
  String? errorMessage;
  bool hasSearched = false;
  
  // 搜索历史记录（简单的内存存储，后续可改为本地存储）
  List<String> searchHistory = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      hasSearched = true;
    });

    try {
      final results = await DramaService.searchDramas(query.trim());
      
      // 添加到搜索历史
      if (!searchHistory.contains(query.trim())) {
        searchHistory.insert(0, query.trim());
        if (searchHistory.length > 10) {
          searchHistory = searchHistory.take(10).toList();
        }
      }
      
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '搜索失败: $e';
      });
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _performSearch(query);
    }
  }

  void _onHistoryItemTap(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  void _clearHistory() {
    setState(() {
      searchHistory.clear();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '搜索剧集...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchResults.clear();
                            hasSearched = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: _onSearchSubmitted,
              onChanged: (value) {
                setState(() {}); // 更新UI以显示/隐藏清除按钮
              },
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              _onSearchSubmitted(_searchController.text);
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    if (searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '搜索历史',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                child: const Text('清空'),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searchHistory.map((query) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ActionChip(
                label: Text(query),
                onPressed: () => _onHistoryItemTap(query),
                backgroundColor: Colors.grey[100],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (isLoading) {
      return const Expanded(
        child: LoadingWidget(message: '搜索中...'),
      );
    }

    if (errorMessage != null) {
      return Expanded(
        child: CustomErrorWidget(
          message: errorMessage!,
          onRetry: () => _performSearch(_searchController.text),
        ),
      );
    }

    if (!hasSearched) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '输入关键词搜索剧集',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                '未找到相关剧集',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return DramaCard(
            drama: searchResults[index],
            onTap: () => _navigateToDramaDetail(searchResults[index]),
          );
        },
      ),
    );
  }

  void _navigateToDramaDetail(Drama drama) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DramaDetailPage(drama: drama),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (!hasSearched) _buildSearchHistory(),
          _buildSearchResults(),
        ],
      ),
    );
  }
}