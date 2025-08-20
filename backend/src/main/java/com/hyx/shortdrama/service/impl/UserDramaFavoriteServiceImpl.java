package com.hyx.shortdrama.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hyx.shortdrama.mapper.UserDramaFavoriteMapper;
import com.hyx.shortdrama.model.entity.Drama;
import com.hyx.shortdrama.model.entity.UserDramaFavorite;
import com.hyx.shortdrama.model.vo.DramaVO;
import com.hyx.shortdrama.service.DramaService;
import com.hyx.shortdrama.service.UserDramaFavoriteService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@Slf4j
public class UserDramaFavoriteServiceImpl extends ServiceImpl<UserDramaFavoriteMapper, UserDramaFavorite>
        implements UserDramaFavoriteService {

    @Resource
    private DramaService dramaService;

    @Override
    public boolean addFavorite(Long userId, Long dramaId) {
        if (userId == null || dramaId == null) {
            return false;
        }
        // 检查是否已被收藏
        if (isFavorited(userId, dramaId)) {
            return true;
        }
        // 检查剧集是否存在
        Drama drama = dramaService.getById(dramaId);
        if (drama == null) {
            return false;
        }

        UserDramaFavorite userDramaFavorite = new UserDramaFavorite();
        userDramaFavorite.setUserId(userId);
        userDramaFavorite.setDramaId(dramaId);
        userDramaFavorite.setCreateTime(new Date());
        userDramaFavorite.setUpdateTime(new Date());

        return this.save(userDramaFavorite);
    }

    @Override
    public boolean removeFavorite(Long userId, Long dramaId) {
        if (userId == null || dramaId == null) {
            return false;
        }
        QueryWrapper<UserDramaFavorite> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userId", userId).eq("dramaId", dramaId);
        return this.remove(queryWrapper);
    }

    @Override
    public boolean isFavorited(Long userId, Long dramaId) {
        if (userId == null || dramaId == null) {
            return false;
        }
        QueryWrapper<UserDramaFavorite> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userId", userId).eq("dramaId", dramaId);
        return this.count(queryWrapper) > 0;
    }

    @Override
    public Page<DramaVO> getUserFavorites(Long userId, long pageNum, long pageSize) {
        // 构建分页对象
        Page<UserDramaFavorite> page = new Page<>(pageNum, pageSize);
        // 查询用户收藏记录
        QueryWrapper<UserDramaFavorite> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("userId", userId)
                .orderByDesc("createTime");

        Page<UserDramaFavorite> favoritePage = this.page(page, queryWrapper);

        // 构建返回的分页对象
        Page<DramaVO> dramaVOPage = new Page<>(pageNum, pageSize,  favoritePage.getTotal());

        // 获取剧集详情并转换为VO
        List<DramaVO> dramaVOList = favoritePage.getRecords().stream()
                .map(favorite -> {
                    Drama drama = dramaService.getById(favorite.getDramaId());
                    return drama != null ? dramaService.getDramaVO(drama) : null;
                })
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        dramaVOPage.setRecords(dramaVOList);
        return dramaVOPage;

    }

    @Override
    public boolean toggleFavorite(Long userId, Long dramaId) {
        if (isFavorited(userId, dramaId)) {
            // 已收藏，则取消收藏
            removeFavorite(userId, dramaId);
            return false;
        } else {
            // 未收藏，则添加收藏
            addFavorite(userId, dramaId);
            return true;
        }
    }
}
