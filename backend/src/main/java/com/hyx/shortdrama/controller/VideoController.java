package com.hyx.shortdrama.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hyx.shortdrama.common.BaseResponse;
import com.hyx.shortdrama.common.ErrorCode;
import com.hyx.shortdrama.common.ResultUtils;
import com.hyx.shortdrama.constant.CacheConstant;
import com.hyx.shortdrama.constant.CommonConstant;
import com.hyx.shortdrama.exception.BusinessException;
import com.hyx.shortdrama.exception.ThrowUtils;
import com.hyx.shortdrama.model.dto.video.VideoAddRequest;
import com.hyx.shortdrama.model.entity.User;
import com.hyx.shortdrama.model.entity.Video;
import com.hyx.shortdrama.model.vo.VideoVO;
import com.hyx.shortdrama.service.UserService;
import com.hyx.shortdrama.service.VideoService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Caching;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/video")
@Slf4j
public class VideoController {

    @Resource
    private VideoService videoService;

    @Resource
    private UserService userService;

    @PostMapping("/add")
//    @AuthCheck(mustRole = UserConstant.ADMIN_ROLE) // 仅管理员新增
    @Caching(evict = {
            @CacheEvict(cacheNames = CacheConstant.VIDEO_FEED, allEntries = true),
            @CacheEvict(cacheNames = CacheConstant.VIDEO_EPISODES, key = "#addRequest.dramaId", condition = "#addRequest != null && #addRequest.dramaId != null")
    })
    public BaseResponse<Long> addVideo(@RequestBody VideoAddRequest addRequest, HttpServletRequest request) {
        if (addRequest == null) throw new BusinessException(ErrorCode.PARAMS_ERROR);
        Video v = new Video();
        BeanUtils.copyProperties(addRequest, v);
        videoService.validVideo(v, true);
        User loginUser = userService.getLoginUser(request);
        v.setUserId(loginUser.getId());
        if (v.getStatus() == null) v.setStatus(1);
        if (v.getOrderNum() == null) v.setOrderNum(0);
        if (v.getUserId() == null) v.setUserId(0L);
        boolean ok = videoService.save(v);
        ThrowUtils.throwIf(!ok, ErrorCode.OPERATION_ERROR);
        return ResultUtils.success(v.getId());
    }

    @GetMapping("/get")
    public BaseResponse<VideoVO> getById(@RequestParam long id, HttpServletRequest request) {
        if (id <= 0) throw new BusinessException(ErrorCode.PARAMS_ERROR);
        Video v = videoService.getById(id);
        if (v == null) throw new BusinessException(ErrorCode.NOT_FOUND_ERROR);
        return ResultUtils.success(videoService.getVideoVO(v, request));
    }

    // 公开 feed 接口：进入 App 即可请求
    @GetMapping("/feed")
    public BaseResponse<Page<VideoVO>> feed(@RequestParam(defaultValue = "1") long current,
                                            @RequestParam(defaultValue = "10") long pageSize,
                                            @RequestParam(required = false) Long dramaId,
                                            HttpServletRequest request) {
        ThrowUtils.throwIf(pageSize > CommonConstant.PAGE_SIZE_LIMIT, ErrorCode.PARAMS_ERROR);
        return ResultUtils.success(videoService.feed(current, pageSize, dramaId, request));
    }
}