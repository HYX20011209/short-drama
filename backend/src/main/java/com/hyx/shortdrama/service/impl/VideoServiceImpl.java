package com.hyx.shortdrama.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hyx.shortdrama.common.ErrorCode;
import com.hyx.shortdrama.constant.CommonConstant;
import com.hyx.shortdrama.exception.BusinessException;
import com.hyx.shortdrama.mapper.VideoMapper;
import com.hyx.shortdrama.model.dto.video.VideoQueryRequest;
import com.hyx.shortdrama.model.entity.Video;
import com.hyx.shortdrama.model.vo.VideoVO;
import com.hyx.shortdrama.service.VideoService;
import com.hyx.shortdrama.utils.SqlUtils;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import java.util.stream.Collectors;

@Service
public class VideoServiceImpl extends ServiceImpl<VideoMapper, Video> implements VideoService {

    @Override
    public void validVideo(Video video, boolean add) {
        if (video == null) throw new BusinessException(ErrorCode.PARAMS_ERROR);
        if (add) {
            if (StringUtils.isBlank(video.getVideoUrl())) {
                throw new BusinessException(ErrorCode.PARAMS_ERROR, "视频地址不能为空");
            }
        }
        if (StringUtils.isNotBlank(video.getTitle()) && video.getTitle().length() > 80) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR, "标题过长");
        }
        if (StringUtils.isNotBlank(video.getDescription()) && video.getDescription().length() > 1024) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR, "简介过长");
        }
    }

    @Override
    public QueryWrapper<Video> getQueryWrapper(VideoQueryRequest request) {
        QueryWrapper<Video> qw = new QueryWrapper<>();
        if (request == null) return qw;
        Long id = request.getId();
        Long notId = request.getNotId();
        String title = request.getTitle();
        Integer status = request.getStatus();
        Long userId = request.getUserId();

        qw.ne(ObjectUtils.isNotEmpty(notId), "id", notId);
        qw.eq(ObjectUtils.isNotEmpty(id), "id", id);
        qw.eq(ObjectUtils.isNotEmpty(status), "status", status);
        qw.eq(ObjectUtils.isNotEmpty(userId), "userId", userId);
        qw.like(StringUtils.isNotBlank(title), "title", title);

        String sortField = request.getSortField();
        String sortOrder = request.getSortOrder();
        qw.orderBy(SqlUtils.validSortField(sortField),
                CommonConstant.SORT_ORDER_ASC.equals(sortOrder), sortField);
        return qw;
    }

    @Override
    public VideoVO getVideoVO(Video video, HttpServletRequest request) {
        return VideoVO.objToVo(video);
    }

    @Override
    public Page<VideoVO> getVideoVOPage(Page<Video> page, HttpServletRequest request) {
        Page<VideoVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(page.getRecords().stream().map(VideoVO::objToVo).collect(Collectors.toList()));
        return voPage;
    }
}
