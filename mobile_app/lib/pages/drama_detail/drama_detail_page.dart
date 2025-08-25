import 'package:flutter/material.dart';

import '../../models/drama.dart';
import '../../services/favorite_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_page_transitions.dart';
import '../player/video_player_page.dart';

class DramaDetailPage extends StatefulWidget {
  final Drama drama;

  const DramaDetailPage({Key? key, required this.drama}) : super(key: key);

  @override
  State<DramaDetailPage> createState() => _DramaDetailPageState();
}

class _DramaDetailPageState extends State<DramaDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 简化动画
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playEpisode(int episode) {
    try {
      final dramaId = int.parse(widget.drama.id);
      Navigator.of(
        context,
      ).pushWithScale(VideoPlayerPage(dramaId: dramaId, startEpisode: episode));
    } catch (e) {
      _showSnackBar('无效的剧集ID: ${widget.drama.id}');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await FavoriteService.toggleFavorite(widget.drama.id);
      if (result != null) {
        setState(() => _isFavorite = result);
        _showSnackBar(
          result ? 'Added to Favorites' : 'Removed from Favorites',
          isSuccess: true,
        );
      }
    } catch (e) {
      _showSnackBar('Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drama Info', style: AppTextStyles.headingSM),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部封面
              _buildCoverSection(),

              // 基本信息
              _buildInfoSection(),

              // 操作按钮
              _buildActionButtons(),

              // 选集 - 关键：这里直接紧跟按钮，没有额外间距
              _buildEpisodeSection(),

              // 底部间距
              const SizedBox(height: AppDimensions.spacing3XL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child:
            widget.drama.coverUrl != null && widget.drama.coverUrl!.isNotEmpty
            ? Image.network(
                widget.drama.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildCoverPlaceholder();
                },
              )
            : _buildCoverPlaceholder(),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            widget.drama.title,
            style: AppTextStyles.headingMD,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppDimensions.spacingSM),

          // 标签和集数
          Row(
            children: [
              if (widget.drama.category != null &&
                  widget.drama.category!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMD,
                    vertical: AppDimensions.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    widget.drama.category!,
                    style: AppTextStyles.withColor(
                      AppTextStyles.labelMedium,
                      AppColors.primary,
                    ),
                  ),
                ),

              const SizedBox(width: AppDimensions.spacingMD),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${widget.drama.totalEpisodes} Episodes',
                  style: AppTextStyles.labelMedium,
                ),
              ),
            ],
          ),

          // 描述
          if (widget.drama.description != null &&
              widget.drama.description!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            Text(
              widget.drama.description!,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLG),
      child: Row(
        children: [
          // 播放按钮
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                boxShadow: AppShadows.primaryGlow(opacity: 0.3),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _playEpisode(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'Watch Now',
                  style: AppTextStyles.withColor(
                    AppTextStyles.buttonMedium,
                    Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppDimensions.spacingMD),

          // 收藏按钮
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _toggleFavorite,
            style: OutlinedButton.styleFrom(
              foregroundColor: _isFavorite
                  ? AppColors.error
                  : AppColors.primary,
              side: BorderSide(
                color: _isFavorite ? AppColors.error : AppColors.primary,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLG,
                vertical: AppDimensions.spacingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 16,
                  ),
            label: Text(
              _isFavorite ? 'Favorited' : 'Favorite',
              style: AppTextStyles.labelMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeSection() {
    return Padding(
      // 关键修改：减少顶部padding，让"选集"更靠近按钮
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLG,
        AppDimensions.spacingSM, // 只有8px的顶部间距
        AppDimensions.spacingLG,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('选集', style: AppTextStyles.headingXS),

          // 关键修改：选集标题和按钮之间只有4px间距
          const SizedBox(height: 4.0),

          // 选集网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.5,
              crossAxisSpacing: AppDimensions.spacingMD,
              mainAxisSpacing: AppDimensions.spacingMD,
            ),
            itemCount: widget.drama.totalEpisodes.clamp(0, 24),
            itemBuilder: (context, index) {
              final episode = index + 1;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _playEpisode(episode),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMD,
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Episode $episode',
                        style: AppTextStyles.labelMedium,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              '短剧封面',
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
