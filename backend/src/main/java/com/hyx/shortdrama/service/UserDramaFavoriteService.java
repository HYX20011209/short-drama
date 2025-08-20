package com.hyx.shortdrama.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hyx.shortdrama.model.entity.UserDramaFavorite;
import com.hyx.shortdrama.model.vo.DramaVO;

/**
 * 用户剧集收藏服务
 */
public interface UserDramaFavoriteService extends IService<UserDramaFavorite> {
    /**
     * 添加收藏
     *
     * @param userId  用户ID
     * @param dramaId 剧集ID
     * @return 是否成功
     */
    boolean addFavorite(Long userId, Long dramaId);

    /**
     * 取消收藏
     *
     * @param userId  用户ID
     * @param dramaId 剧集ID
     * @return 是否成功
     */
    boolean removeFavorite(Long userId, Long dramaId);

    /**
     * 检查是否已收藏
     *
     * @param userId  用户ID
     * @param dramaId 剧集ID
     * @return 是否已收藏
     */
    boolean isFavorited(Long userId, Long dramaId);

    /**
     * 获取用户收藏列表（分页）
     *
     * @param userId   用户ID
     * @param pageNum  页码
     * @param pageSize 页大小
     * @return 收藏的剧集列表
     */
    Page<DramaVO> getUserFavorites(Long userId, long pageNum, long pageSize);

    /**
     * 切换收藏状态
     *
     * @param userId  用户ID
     * @param dramaId 剧集ID
     * @return 切换后的收藏状态（true-已收藏，false-未收藏）
     */
    boolean toggleFavorite(Long userId, Long dramaId);
}
