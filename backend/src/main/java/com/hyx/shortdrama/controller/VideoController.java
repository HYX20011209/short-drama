package com.hyx.shortdrama.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hyx.shortdrama.annotation.AuthCheck;
import com.hyx.shortdrama.common.BaseResponse;
import com.hyx.shortdrama.common.ErrorCode;
import com.hyx.shortdrama.common.ResultUtils;
import com.hyx.shortdrama.constant.UserConstant;
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
                                            HttpServletRequest request) {
        ThrowUtils.throwIf(pageSize > 20, ErrorCode.PARAMS_ERROR);
        QueryWrapper<Video> qw = new QueryWrapper<Video>()
                .eq("status", 1)
                .orderByDesc("orderNum")
                .orderByDesc("id");
        Page<Video> page = videoService.page(new Page<>(current, pageSize), qw);
        return ResultUtils.success(videoService.getVideoVOPage(page, request));
    }
}