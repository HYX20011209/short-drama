import 'package:flutter/material.dart';

import '../../models/drama.dart';
import '../../services/ai_service.dart';
import '../../services/drama_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_page_transitions.dart';
import '../../widgets/drama_card.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
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
  bool useSemantic = false;

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
      if (useSemantic) {
        final ai = await AiService.ask(
          question: query.trim(),
          scene: 'search',
          topK: ApiConstants.defaultPageSize,
        );
        // 记录历史
        if (!searchHistory.contains(query.trim())) {
          searchHistory.insert(0, query.trim());
          if (searchHistory.length > 10) {
            searchHistory = searchHistory.take(10).toList();
          }
        }
        setState(() {
          searchResults = ai.dramas;
          isLoading = false;
        });
      } else {
        final results = await DramaService.searchDramas(query.trim());
        // 记录历史
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
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Search failed: $e';
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLG,
        vertical: AppDimensions.spacingSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search dramas...',
                      hintStyle: AppTextStyles.withColor(
                        AppTextStyles.bodyMedium,
                        Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: AppDimensions.iconSizeLarge,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    searchResults.clear();
                                    hasSearched = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppDimensions.spacingSM,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                    size: AppDimensions.iconSizeLarge,
                                  ),
                                ),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMD,
                        vertical: AppDimensions.spacingSM,
                      ),
                    ),
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Semantic', style: AppTextStyles.bodySmall),
              Switch(
                value: useSemantic,
                onChanged: (v) {
                  setState(() => useSemantic = v);
                  // 可选：如果已经有关键词，切换时自动触发一次搜索
                  // if (_searchController.text.trim().isNotEmpty) {
                  //   _performSearch(_searchController.text.trim());
                  // }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 在搜索结果的剧集卡片点击处添加转场动画
  void _playDrama(Drama drama) {
    Navigator.of(context).pushWithBottomSlide(DramaDetailPage(drama: drama));
  }

  Widget _buildSearchHistory() {
    if (searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLG,
            vertical: AppDimensions.spacingMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Search History', style: AppTextStyles.headingXS),
              TextButton(
                onPressed: _clearHistory,
                child: Text(
                  'Clear',
                  style: AppTextStyles.withColor(
                    AppTextStyles.labelLarge,
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLG,
          ),
          child: Wrap(
            spacing: AppDimensions.spacingSM,
            runSpacing: AppDimensions.spacingSM,
            children: searchHistory.map((query) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onHistoryItemTap(query),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMD,
                      vertical: AppDimensions.spacingSM,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: AppDimensions.iconSizeSmall,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: AppDimensions.spacingXS),
                        Text(
                          query,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLG),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (isLoading) {
      return const Expanded(child: LoadingWidget(message: 'Searching...'));
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
              Icon(Icons.search, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Enter keywords to search dramas',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No results found',
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
    Navigator.of(context).pushWithBottomSlide(DramaDetailPage(drama: drama));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索'), elevation: 0),
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
