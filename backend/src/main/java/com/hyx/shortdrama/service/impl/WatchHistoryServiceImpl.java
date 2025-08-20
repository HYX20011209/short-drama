package com.hyx.shortdrama.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hyx.shortdrama.mapper.WatchHistoryMapper;
import com.hyx.shortdrama.model.entity.WatchHistory;
import com.hyx.shortdrama.model.vo.WatchHistoryVO;
import com.hyx.shortdrama.service.WatchHistoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.stream.Collectors;

@Service
@Slf4j
public class WatchHistoryServiceImpl extends ServiceImpl<WatchHistoryMapper, WatchHistory> implements WatchHistoryService {

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
        // 转换为VO对象
        Page<WatchHistoryVO> watchHistoryVOPage = new Page<>();
        watchHistoryVOPage.setRecords(historyPage.getRecords().stream()
                .map(WatchHistoryVO::objToVo)
                .collect(Collectors.toList()));
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
}
