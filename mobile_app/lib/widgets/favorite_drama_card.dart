import 'package:flutter/material.dart';

import '../models/drama.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class FavoriteDramaCard extends StatelessWidget {
  final Drama drama;
  final VoidCallback onTap;
  final VoidCallback onFavoriteRemove;

  const FavoriteDramaCard({
    Key? key,
    required this.drama,
    required this.onTap,
    required this.onFavoriteRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 封面图
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child:
                          drama.coverUrl != null && drama.coverUrl!.isNotEmpty
                          ? Image.network(
                              drama.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return _buildPlaceholder();
                                  },
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                ),

                // 剧集信息
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingSM), // 减少padding从12px到8px
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 改为spaceBetween确保布局稳定
                      children: [
                        Text(
                          drama.title,
                          style: AppTextStyles.dramaTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // 去掉SizedBox，使用spaceBetween自动分配空间
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingSM,
                                vertical: AppDimensions.spacingXXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusXS,
                                ),
                              ),
                              child: Text(
                                '${drama.totalEpisodes} EP',
                                style: AppTextStyles.withPrimary(
                                  AppTextStyles.labelSmall,
                                ),
                              ),
                            ),
                            if (drama.category != null &&
                                drama.category!.isNotEmpty) ...[
                              const SizedBox(width: AppDimensions.spacingSM),
                              Flexible( // 使用Flexible替代固定Container，防止溢出
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.spacingSM,
                                    vertical: AppDimensions.spacingXXS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusXS,
                                    ),
                                    border: Border.all(
                                      color: AppColors.secondary.withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    drama.category!,
                                    style: AppTextStyles.withColor(
                                      AppTextStyles.labelSmall,
                                      AppColors.secondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 收藏按钮
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _showRemoveFavoriteDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.movie, size: 40, color: Colors.grey),
      ),
    );
  }

  void _showRemoveFavoriteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Favorites'),
        content: Text('Remove "${drama.title}" from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onFavoriteRemove();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
