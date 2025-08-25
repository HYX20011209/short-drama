import 'package:flutter/material.dart';

import '../../models/drama.dart';
import '../../services/drama_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/drama_card.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../drama_detail/drama_detail_page.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // 为动画提供支持
  List<Drama> dramas = [];
  bool loading = true;
  String? errorMessage;
  String? selectedCategory;
  List<String> categories = [];

  // 动画控制器
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _loadInitialData();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadCategories(), _loadDramas()]);

    // 启动动画
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
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
      // 移除默认AppBar，使用自定义渐变背景
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        // 添加渐变背景
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.light
              ? AppColors.backgroundGradient
              : AppColors.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 分类选择器
              if (categories.isNotEmpty) _buildCategorySelector(),

              // 主要内容区域
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  // 自定义AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), Colors.transparent],
          ),
        ),
      ),
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          '短剧',
          style: AppTextStyles.withPrimary(AppTextStyles.headingSM),
        ),
      ),
      centerTitle: true,
      actions: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.only(right: AppDimensions.spacingLG),
            decoration: BoxDecoration(
              color: AppColors.surfaceWithOpacity(0.9),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: AppDimensions.iconSizeLarge,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // 分类选择器
  Widget _buildCategorySelector() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: AppDimensions.spacing4XL + AppDimensions.spacingLG,
          margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSM),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLG,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected =
                  selectedCategory == category ||
                  (selectedCategory == null && category == '全部');

              return Container(
                margin: const EdgeInsets.only(right: AppDimensions.spacingMD),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _onCategoryChanged(category == '全部' ? null : category),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingXL,
                        vertical: AppDimensions.spacingMD,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected
                            ? null
                            : AppColors.surfaceWithOpacity(0.8),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        category,
                        style: isSelected
                            ? AppTextStyles.withColor(
                                AppTextStyles.labelLarge,
                                Colors.white,
                              )
                            : AppTextStyles.withColor(
                                AppTextStyles.labelLarge,
                                AppColors.primary,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 64,
                color: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: AppDimensions.spacingLG),
              Text(
                '暂无剧集',
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyLarge,
                  AppColors.primary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _loadDramas,
          color: AppColors.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacingLG),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: AppDimensions.dramaCardAspectRatio,
              crossAxisSpacing: AppDimensions.dramaCardGridSpacing,
              mainAxisSpacing: AppDimensions.dramaCardGridSpacing,
            ),
            itemCount: dramas.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 50)), // 错开动画
                child: DramaCard(
                  drama: dramas[index],
                  onTap: () => _playDrama(dramas[index]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
