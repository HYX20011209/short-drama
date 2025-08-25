package com.hyx.shortdrama.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hyx.shortdrama.annotation.AuthCheck;
import com.hyx.shortdrama.common.BaseResponse;
import com.hyx.shortdrama.common.DeleteRequest;
import com.hyx.shortdrama.common.ErrorCode;
import com.hyx.shortdrama.common.ResultUtils;
import com.hyx.shortdrama.config.WxOpenConfig;
import com.hyx.shortdrama.constant.UserConstant;
import com.hyx.shortdrama.exception.BusinessException;
import com.hyx.shortdrama.exception.ThrowUtils;
import com.hyx.shortdrama.model.dto.user.*;
import com.hyx.shortdrama.model.entity.User;
import com.hyx.shortdrama.model.vo.DramaVO;
import com.hyx.shortdrama.model.vo.LoginUserVO;
import com.hyx.shortdrama.model.vo.UserVO;
import com.hyx.shortdrama.model.vo.WatchHistoryVO;
import com.hyx.shortdrama.service.UserDramaFavoriteService;
import com.hyx.shortdrama.service.UserService;

import java.util.List;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.hyx.shortdrama.service.WatchHistoryService;
import lombok.extern.slf4j.Slf4j;
import me.chanjar.weixin.common.bean.WxOAuth2UserInfo;
import me.chanjar.weixin.common.bean.oauth2.WxOAuth2AccessToken;
import me.chanjar.weixin.mp.api.WxMpService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.util.DigestUtils;
import org.springframework.web.bind.annotation.*;

import static com.hyx.shortdrama.service.impl.UserServiceImpl.SALT;

/**
 * 用户接口
 */
@RestController
@RequestMapping("/user")
@Slf4j
public class UserController {

    @Resource
    private UserService userService;

    @Resource
    private WxOpenConfig wxOpenConfig;

    @Resource
    private WatchHistoryService watchHistoryService;

    @Resource
    private UserDramaFavoriteService userDramaFavoriteService;

    // region 登录相关

    /**
     * 用户注册
     *
     * @param userRegisterRequest
     * @return
     */
    @PostMapping("/register")
    public BaseResponse<Long> userRegister(@RequestBody UserRegisterRequest userRegisterRequest) {
        if (userRegisterRequest == null) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        String userAccount = userRegisterRequest.getUserAccount();
        String userPassword = userRegisterRequest.getUserPassword();
        String checkPassword = userRegisterRequest.getCheckPassword();
        if (StringUtils.isAnyBlank(userAccount, userPassword, checkPassword)) {
            return null;
        }
        long result = userService.userRegister(userAccount, userPassword, checkPassword);
        return ResultUtils.success(result);
    }

    /**
     * 用户登录
     *
     * @param userLoginRequest
     * @param request
     * @return
     */
    @PostMapping("/login")
    public BaseResponse<LoginUserVO> userLogin(@RequestBody UserLoginRequest userLoginRequest, HttpServletRequest request) {
        if (userLoginRequest == null) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        String userAccount = userLoginRequest.getUserAccount();
        String userPassword = userLoginRequest.getUserPassword();
        if (StringUtils.isAnyBlank(userAccount, userPassword)) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        LoginUserVO loginUserVO = userService.userLogin(userAccount, userPassword, request);
        return ResultUtils.success(loginUserVO);
    }

    /**
     * 用户登录（微信开放平台）
     */
    @GetMapping("/login/wx_open")
    public BaseResponse<LoginUserVO> userLoginByWxOpen(HttpServletRequest request, HttpServletResponse response,
            @RequestParam("code") String code) {
        WxOAuth2AccessToken accessToken;
        try {
            WxMpService wxService = wxOpenConfig.getWxMpService();
            accessToken = wxService.getOAuth2Service().getAccessToken(code);
            WxOAuth2UserInfo userInfo = wxService.getOAuth2Service().getUserInfo(accessToken, code);
            String unionId = userInfo.getUnionId();
            String mpOpenId = userInfo.getOpenid();
            if (StringUtils.isAnyBlank(unionId, mpOpenId)) {
                throw new BusinessException(ErrorCode.SYSTEM_ERROR, "登录失败，系统错误");
            }
            return ResultUtils.success(userService.userLoginByMpOpen(userInfo, request));
        } catch (Exception e) {
            log.error("userLoginByWxOpen error", e);
            throw new BusinessException(ErrorCode.SYSTEM_ERROR, "登录失败，系统错误");
        }
    }

    /**
     * 用户注销
     *
     * @param request
     * @return
     */
    @PostMapping("/logout")
    public BaseResponse<Boolean> userLogout(HttpServletRequest request) {
        if (request == null) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        boolean result = userService.userLogout(request);
        return ResultUtils.success(result);
    }

    /**
     * 获取当前登录用户
     *
     * @param request
     * @return
     */
    @GetMapping("/get/login")
    public BaseResponse<LoginUserVO> getLoginUser(HttpServletRequest request) {
        User user = userService.getLoginUser(request);
        return ResultUtils.success(userService.getLoginUserVO(user));
    }

    // endregion

    // region 增删改查

    /**
     * 创建用户
     *
     * @param userAddRequest
     * @param request
     * @return
     */
    @PostMapping("/add")
    @AuthCheck(mustRole = UserConstant.ADMIN_ROLE)
    public BaseResponse<Long> addUser(@RequestBody UserAddRequest userAddRequest, HttpServletRequest request) {
        if (userAddRequest == null) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User user = new User();
        BeanUtils.copyProperties(userAddRequest, user);
        // 默认密码 12345678
        String defaultPassword = "12345678";
        String encryptPassword = DigestUtils.md5DigestAsHex((SALT + defaultPassword).getBytes());
        user.setUserPassword(encryptPassword);
        boolean result = userService.save(user);
        ThrowUtils.throwIf(!result, ErrorCode.OPERATION_ERROR);
        return ResultUtils.success(user.getId());
    }

    /**
     * 删除用户
     *
     * @param deleteRequest
     * @param request
     * @return
     */
    @PostMapping("/delete")
    @AuthCheck(mustRole = UserConstant.ADMIN_ROLE)
    public BaseResponse<Boolean> deleteUser(@RequestBody DeleteRequest deleteRequest, HttpServletRequest request) {
        if (deleteRequest == null || deleteRequest.getId() <= 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        boolean b = userService.removeById(deleteRequest.getId());
        return ResultUtils.success(b);
    }

    /**
     * 更新用户
     *
     * @param userUpdateRequest
     * @param request
     * @return
     */
    @PostMapping("/update")
    @AuthCheck(mustRole = UserConstant.ADMIN_ROLE)
    public BaseResponse<Boolean> updateUser(@RequestBody UserUpdateRequest userUpdateRequest,
            HttpServletRequest request) {
        if (userUpdateRequest == null || userUpdateRequest.getId() == null) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User user = new User();
        BeanUtils.copyProperties(userUpdateRequest, user);
        boolean result = userService.updateById(user);
        ThrowUtils.throwIf(!result, ErrorCode.OPERATION_ERROR);
        return ResultUtils.success(true);
    }

    /**
     * 根据 id 获取用户（仅管理员）
     *
     * @param id
     * @param request
     * @return
     */
    @GetMapping("/get")
    @AuthCheck(mustRole = UserConstant.ADMIN_ROLE)
    public BaseResponse<User> getUserById(long id, HttpServletRequest request) {
        if (id <= 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User user = userService.getById(id);
        ThrowUtils.throwIf(user == null, ErrorCode.NOT_FOUND_ERROR);
        return ResultUtils.success(user);
    }

    /**
     * 根据 id 获取包装类
     *
     * @param id
     * @param request
     * @return
     */
    @GetMapping("/get/vo")
    public BaseResponse<UserVO> getUserVOById(long id, HttpServletRequest request) {
        BaseResponse<User> response = getUserById(id, request);
        User user = response.getData();
        return ResultUtils.success(userService.getUserVO(user));
    }

    /**
     * 分页获取用户列表（仅管理员）
     *
     * @param userQueryRequest
     * @param request
     * @return
     */
    @PostMapping("/list/page")
    @AuthCheck(mustRole = UserConstant.ADMIN_ROLE)
    public BaseResponse<Page<User>> listUserByPage(@RequestBody UserQueryRequest userQueryRequest,
            HttpServletRequest request) {
        long current = userQueryRequest.getCurrent();
        long size = userQueryRequest.getPageSize();
        Page<User> userPage = userService.page(new Page<>(current, size),
                userService.getQueryWrapper(userQueryRequest));
        return ResultUtils.success(userPage);
    }

    /**
     * 分页获取用户封装列表
     *
     * @param userQueryRequest
     * @param request
     * @return
     */
    @PostMapping("/list/page/vo")
    public BaseResponse<Page<UserVO>> listUserVOByPage(@RequestBody UserQueryRequest userQueryRequest,
            HttpServletRequest request) {
        if (userQueryRequest == null) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        long current = userQueryRequest.getCurrent();
        long size = userQueryRequest.getPageSize();
        // 限制爬虫
        ThrowUtils.throwIf(size > 20, ErrorCode.PARAMS_ERROR);
        Page<User> userPage = userService.page(new Page<>(current, size),
                userService.getQueryWrapper(userQueryRequest));
        Page<UserVO> userVOPage = new Page<>(current, size, userPage.getTotal());
        List<UserVO> userVO = userService.getUserVO(userPage.getRecords());
        userVOPage.setRecords(userVO);
        return ResultUtils.success(userVOPage);
    }

    // endregion

    /**
     * 更新个人信息
     *
     * @param userUpdateMyRequest
     * @param request
     * @return
     */
    @PostMapping("/update/my")
    public BaseResponse<Boolean> updateMyUser(@RequestBody UserUpdateMyRequest userUpdateMyRequest,
            HttpServletRequest request) {
        if (userUpdateMyRequest == null) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        
        // 验证昵称不能为空
        if (StringUtils.isBlank(userUpdateMyRequest.getUserName())) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR, "昵称不能为空");
        }
        
        User loginUser = userService.getLoginUser(request);
        User user = new User();
        BeanUtils.copyProperties(userUpdateMyRequest, user);
        
        // 如果提供了新密码，进行加密处理
        if (StringUtils.isNotBlank(userUpdateMyRequest.getUserPassword())) {
            if (userUpdateMyRequest.getUserPassword().length() < 8) {
                throw new BusinessException(ErrorCode.PARAMS_ERROR, "密码长度不能少于8位");
            }
            String encryptPassword = DigestUtils.md5DigestAsHex((SALT + userUpdateMyRequest.getUserPassword()).getBytes());
            user.setUserPassword(encryptPassword);
        } else {
            // 如果没有提供新密码，则不更新密码字段
            user.setUserPassword(null);
        }
        
        // 处理个人简介默认值
        if (StringUtils.isBlank(userUpdateMyRequest.getUserProfile())) {
            user.setUserProfile("这个人很懒，什么都没留下");
        }
        
        user.setId(loginUser.getId());
        boolean result = userService.updateById(user);
        ThrowUtils.throwIf(!result, ErrorCode.OPERATION_ERROR);
        return ResultUtils.success(true);
    }

    @GetMapping("/test")
    public BaseResponse<Integer>  test() {
        return ResultUtils.success(1);
    }

    // ==================== 观看历史相关接口 ====================

    /**
     * 获取用户观看历史
     *
     * @param pageNum  页码
     * @param pageSize 页大小
     * @param request  请求
     * @return 观看历史列表
     */
    @GetMapping("/history")
    public BaseResponse<Page<WatchHistoryVO>> getUserWatchHistory(
            @RequestParam(defaultValue = "1") long pageNum,
            @RequestParam(defaultValue = "10") long pageSize,
            HttpServletRequest request) {
        User loginUser = userService.getLoginUser(request);
        Page<WatchHistoryVO> historyPage = watchHistoryService.getUserWatchHistory(loginUser.getId(), pageNum, pageSize);
        return ResultUtils.success(historyPage);
    }

    /**
     * 更新观看进度
     *
     * @param updateProgressRequest 更新进度请求
     * @param request              请求
     * @return 是否成功
     */
    @PostMapping("/history/progress")
    public BaseResponse<Boolean> updateWatchProgress(@RequestBody UpdateProgressRequest updateProgressRequest,
                                                     HttpServletRequest request) {
        if (updateProgressRequest == null) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User loginUser = userService.getLoginUser(request);

        boolean success = watchHistoryService.saveOrUpdateProgress(
                loginUser.getId(),
                updateProgressRequest.getVideoId(),
                updateProgressRequest.getDramaId(),
                updateProgressRequest.getEpisodeNumber(),
                updateProgressRequest.getProgress()
        );

        return ResultUtils.success(success);
    }

    /**
     * 删除观看历史记录
     *
     * @param videoId 视频ID
     * @param request 请求
     * @return 是否成功
     */
    @DeleteMapping("/history/{videoId}")
    public BaseResponse<Boolean> deleteWatchHistory(@PathVariable Long videoId, HttpServletRequest request) {
        if (videoId == null || videoId <= 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User loginUser = userService.getLoginUser(request);
        boolean success = watchHistoryService.deleteWatchHistory(loginUser.getId(), videoId);
        return ResultUtils.success(success);
    }

    /**
     * 清空观看历史
     *
     * @param request 请求
     * @return 是否成功
     */
    @DeleteMapping("/history/clear")
    public BaseResponse<Boolean> clearWatchHistory(HttpServletRequest request) {
        User loginUser = userService.getLoginUser(request);
        boolean success = watchHistoryService.clearWatchHistory(loginUser.getId());
        return ResultUtils.success(success);
    }

    /**
     * 获取视频观看进度
     *
     * @param videoId 视频ID
     * @param request 请求
     * @return 观看进度
     */
    @GetMapping("/history/progress/{videoId}")
    public BaseResponse<Integer> getWatchProgress(@PathVariable Long videoId, HttpServletRequest request) {
        if (videoId == null || videoId <= 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User loginUser = userService.getLoginUser(request);
        Integer progress = watchHistoryService.getWatchProgress(loginUser.getId(), videoId);
        return ResultUtils.success(progress);
    }

    // ==================== 收藏相关接口 ====================

    /**
     * 获取用户收藏列表
     *
     * @param pageNum  页码
     * @param pageSize 页大小
     * @param request  请求
     * @return 收藏列表
     */
    @GetMapping("/favorites")
    public BaseResponse<Page<DramaVO>> getUserFavorites(
            @RequestParam(defaultValue = "1") long pageNum,
            @RequestParam(defaultValue = "10") long pageSize,
            HttpServletRequest request) {
        User loginUser = userService.getLoginUser(request);
        Page<DramaVO> favoritePage = userDramaFavoriteService.getUserFavorites(loginUser.getId(), pageNum, pageSize);
        return ResultUtils.success(favoritePage);
    }

    /**
     * 添加收藏
     *
     * @param dramaId 剧集ID
     * @param request 请求
     * @return 是否成功
     */
    @PostMapping("/favorites/{dramaId}")
    public BaseResponse<Boolean> addFavorite(@PathVariable Long dramaId, HttpServletRequest request) {
        if (dramaId == null || dramaId <= 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User loginUser = userService.getLoginUser(request);
        boolean success = userDramaFavoriteService.addFavorite(loginUser.getId(), dramaId);
        return ResultUtils.success(success);
    }

    /**
     * 取消收藏
     *
     * @param dramaId 剧集ID
     * @param request 请求
     * @return 是否成功
     */
    @DeleteMapping("/favorites/{dramaId}")
    public BaseResponse<Boolean> removeFavorite(@PathVariable Long dramaId, HttpServletRequest request) {
        if (dramaId == null || dramaId <= 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User loginUser = userService.getLoginUser(request);
        boolean success = userDramaFavoriteService.removeFavorite(loginUser.getId(), dramaId);
        return ResultUtils.success(success);
    }

    /**
     * 切换收藏状态
     *
     * @param dramaId 剧集ID
     * @param request 请求
     * @return 切换后的收藏状态
     */
    @PostMapping("/favorites/toggle/{dramaId}")
    public BaseResponse<Boolean> toggleFavorite(@PathVariable Long dramaId, HttpServletRequest request) {
        if (dramaId == null || dramaId <= 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User loginUser = userService.getLoginUser(request);
        boolean isFavorited = userDramaFavoriteService.toggleFavorite(loginUser.getId(), dramaId);
        return ResultUtils.success(isFavorited);
    }

    /**
     * 检查是否已收藏
     *
     * @param dramaId 剧集ID
     * @param request 请求
     * @return 是否已收藏
     */
    @GetMapping("/favorites/check/{dramaId}")
    public BaseResponse<Boolean> checkFavorite(@PathVariable Long dramaId, HttpServletRequest request) {
        if (dramaId == null || dramaId <= 0) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR);
        }
        User loginUser = userService.getLoginUser(request);
        boolean isFavorited = userDramaFavoriteService.isFavorited(loginUser.getId(), dramaId);
        return ResultUtils.success(isFavorited);
    }
}
