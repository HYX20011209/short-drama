import 'package:flutter/material.dart';

import '../models/drama.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

class DramaCard extends StatefulWidget {
  final Drama drama;
  final VoidCallback onTap;

  const DramaCard({Key? key, required this.drama, required this.onTap})
    : super(key: key);

  @override
  State<DramaCard> createState() => _DramaCardState();
}

class _DramaCardState extends State<DramaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: _isPressed ? AppShadows.pressed : AppShadows.dramaCard,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            child: Container(
              color: Theme.of(context).cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 封面图区域
                  Expanded(flex: 4, child: _buildCoverImage()),

                  // 信息区域
                  Expanded(flex: 2, child: _buildInfoSection()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withOpacity(0.1), Colors.transparent],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL),
            ),
            child:
                widget.drama.coverUrl != null &&
                    widget.drama.coverUrl!.isNotEmpty
                ? Image.network(
                    widget.drama.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),

          // 渐变蒙层
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusXL),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),

          // 播放按钮
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.overlayColor(0.7),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标题
          Text(
            widget.drama.title,
            style: AppTextStyles.dramaTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppDimensions.spacingXS),

          // 底部信息行
          // 底部信息行
          Row(
            children: [
              // 集数信息
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSM,
                  vertical: AppDimensions.spacingXXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                ),
                child: Text(
                  '${widget.drama.totalEpisodes} Episodes',
                  style: AppTextStyles.withPrimary(AppTextStyles.labelSmall),
                ),
              ),

              // 分类标签 - 修改：使用更优雅的小标签设计
              if (widget.drama.category != null &&
                  widget.drama.category!.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.spacingSM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSM,
                    vertical: AppDimensions.spacingXXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    widget.drama.category!,
                    style: AppTextStyles.withColor(
                      AppTextStyles.labelSmall,
                      AppColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // 添加弹性空间，让标签靠左对齐
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: AppDimensions.iconSizeXLarge,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              'Drama',
              style: AppTextStyles.withColor(
                AppTextStyles.labelSmall,
                AppColors.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
