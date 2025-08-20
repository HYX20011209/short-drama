package com.hyx.shortdrama.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hyx.shortdrama.mapper.WatchHistoryMapper;
import com.hyx.shortdrama.model.entity.Drama;
import com.hyx.shortdrama.model.entity.WatchHistory;
import com.hyx.shortdrama.model.vo.DramaVO;
import com.hyx.shortdrama.model.vo.WatchHistoryVO;
import com.hyx.shortdrama.service.DramaService;
import com.hyx.shortdrama.service.UserService;
import com.hyx.shortdrama.service.WatchHistoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class WatchHistoryServiceImpl extends ServiceImpl<WatchHistoryMapper, WatchHistory> implements WatchHistoryService {

    @Resource
    private UserService userService;

    @Resource
    private DramaService dramaService;

    @Override
    public boolean saveOrUpdateProgress(Long userId, Long videoId, Long dramaId, Integer episodeNumber, Integer progress) {
        if (userId == null || videoId == null || progress == null) {
            return false;
        }

        // 查询是否已存在记录
        QueryWrapper<WatchHistory> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userId", userId).eq("videoId", videoId);
        WatchHistory existingHistory = this.getOne(queryWrapper);

        Date now = new Date();
        if (existingHistory != null) {
            existingHistory.setProgress(progress);
            existingHistory.setLastWatchTime(now);
            existingHistory.setUpdateTime(now);
            if (dramaId != null) {
                existingHistory.setDramaId(dramaId);
            }
            if (episodeNumber != null) {
                existingHistory.setEpisodeNumber(episodeNumber);
            }
            return this.updateById(existingHistory);
        }else{
            WatchHistory watchHistory = new WatchHistory();
            watchHistory.setUserId(userId);
            watchHistory.setVideoId(videoId);
            watchHistory.setDramaId(dramaId);
            watchHistory.setEpisodeNumber(episodeNumber);
            watchHistory.setProgress(progress);
            watchHistory.setLastWatchTime(now);
            watchHistory.setCreateTime(now);
            watchHistory.setUpdateTime(now);
            return this.save(watchHistory);
        }
    }

    @Override
    public Page<WatchHistoryVO> getUserWatchHistory(Long userId, long pageNum, long pageSize) {
        // 构建分页对象
        Page<WatchHistory> page = new Page<>(pageNum, pageSize);
        // 构建查询条件
        QueryWrapper<WatchHistory> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userId", userId)
                .orderByDesc("lastWatchTime");
        // 执行分页查询
        Page<WatchHistory> historyPage = this.page(page, queryWrapper);
        // 转换为VO对象并填充关联信息
        Page<WatchHistoryVO> watchHistoryVOPage = new Page<>();
        List<WatchHistoryVO> voList = historyPage.getRecords().stream()
                .map(this::convertToVOWithRelatedInfo)
                .collect(Collectors.toList());

        watchHistoryVOPage.setRecords(voList);
        watchHistoryVOPage.setCurrent(historyPage.getCurrent());
        watchHistoryVOPage.setSize(historyPage.getSize());
        watchHistoryVOPage.setTotal(historyPage.getTotal());

        return watchHistoryVOPage;
    }

    @Override
    public boolean deleteWatchHistory(Long userId, Long videoId) {
        if (userId == null || videoId == null) {
            return false;
        }

        QueryWrapper<WatchHistory> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userId", userId).eq("videoId", videoId);
        return this.remove(queryWrapper);
    }

    @Override
    public boolean clearWatchHistory(Long userId) {
        if (userId == null) {
            return false;
        }

        QueryWrapper<WatchHistory> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userId", userId);
        return this.remove(queryWrapper);
    }

    @Override
    public Integer getWatchProgress(Long userId, Long videoId) {
        if (userId == null || videoId == null) {
            return 0;
        }

        QueryWrapper<WatchHistory> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userId", userId).eq("videoId", videoId);
        WatchHistory watchHistory = this.getOne(queryWrapper);

        return watchHistory != null ? watchHistory.getProgress() : 0;
    }

    /**
     * 转换为VO并填充关联信息
     *
     * @param watchHistory 观看历史实体
     * @return 包含关联信息的VO
     */
    private WatchHistoryVO convertToVOWithRelatedInfo(WatchHistory watchHistory) {
        if (watchHistory == null) {
            return null;
        }

        WatchHistoryVO vo = WatchHistoryVO.objToVo(watchHistory);

        // 填充Drama信息
        if (watchHistory.getDramaId() != null) {
            try {
                Drama drama = dramaService.getById(watchHistory.getDramaId());
                if (drama != null) {
                    DramaVO dramaVO = dramaService.getDramaVO(drama);
                    vo.setDrama(dramaVO);
                }
            } catch (Exception e) {
                log.warn("获取剧集信息失败，dramaId: {}, error: {}",
                        watchHistory.getDramaId(), e.getMessage());
            }
        }

        // 可以在这里添加Video信息的填充（如果需要的话）
        // if (watchHistory.getVideoId() != null) {
        //     // 填充Video信息的逻辑
        // }

        return vo;
    }
}
