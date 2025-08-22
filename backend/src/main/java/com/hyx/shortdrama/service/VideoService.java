package com.hyx.shortdrama.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hyx.shortdrama.model.dto.video.VideoQueryRequest;
import com.hyx.shortdrama.model.entity.Video;
import com.hyx.shortdrama.model.vo.VideoVO;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

public interface VideoService extends IService<Video> {

    void validVideo(Video video, boolean add);

    QueryWrapper<Video> getQueryWrapper(VideoQueryRequest request);

    VideoVO getVideoVO(Video video, HttpServletRequest request);

    Page<VideoVO> getVideoVOPage(Page<Video> page, HttpServletRequest request);

    List<VideoVO> listEpisodes(long dramaId, HttpServletRequest request);

    Page<VideoVO> feed(long current, long pageSize, Long dramaId, HttpServletRequest request);
}