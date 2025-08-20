package com.hyx.shortdrama.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hyx.shortdrama.model.entity.WatchHistory;
import com.hyx.shortdrama.model.vo.WatchHistoryVO;

/**
 * 观看历史服务
 */
public interface WatchHistoryService extends IService<WatchHistory> {
    /**
     * 保存或更新观看进度
     *
     * @param userId        用户ID
     * @param videoId       视频ID
     * @param dramaId       剧集ID（可为空）
     * @param episodeNumber 集数（可为空）
     * @param progress      观看进度（秒）
     * @return 是否成功
     */
    boolean saveOrUpdateProgress(Long userId, Long videoId, Long dramaId, Integer episodeNumber, Integer progress);

    /**
     * 获取用户观看历史列表（分页）
     *
     * @param userId   用户ID
     * @param pageNum  页码
     * @param pageSize 页大小
     * @return 观看历史列表
     */
    Page<WatchHistoryVO> getUserWatchHistory(Long userId, long pageNum, long pageSize);

    /**
     * 删除观看历史记录
     *
     * @param userId  用户ID
     * @param videoId 视频ID
     * @return 是否成功
     */
    boolean deleteWatchHistory(Long userId, Long videoId);

    /**
     * 清空用户观看历史
     *
     * @param userId 用户ID
     * @return 是否成功
     */
    boolean clearWatchHistory(Long userId);

    /**
     * 获取视频观看进度
     *
     * @param userId  用户ID
     * @param videoId 视频ID
     * @return 观看进度（秒）
     */
    Integer getWatchProgress(Long userId, Long videoId);
}
