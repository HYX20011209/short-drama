package com.hyx.shortdrama.service.impl;

import cn.hutool.core.collection.CollUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hyx.shortdrama.mapper.DramaMapper;
import com.hyx.shortdrama.model.dto.drama.DramaQueryRequest;
import com.hyx.shortdrama.model.entity.Drama;
import com.hyx.shortdrama.model.vo.DramaVO;
import com.hyx.shortdrama.service.DramaService;
import com.hyx.shortdrama.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 用户评论服务实现
 */
@Service
@Slf4j
public class DramaServiceImpl extends ServiceImpl<DramaMapper, Drama> implements DramaService {
    // TODO 该文件为自动生成，在使用前需要修改

    @Resource
    private UserService userService;

    /**
     * 校验数据
     */
    @Override
    public void validDrama(Drama drama, boolean add) {
    }

    /**
     * 获取查询条件
     *
     * @param dramaQueryRequest
     * @return
     */
    @Override
    public QueryWrapper<Drama> getQueryWrapper(DramaQueryRequest dramaQueryRequest) {
        return null;
    }

    /**
     * 获取用户评论封装
     *
     * @param drama
     * @param request
     * @return
     */
    @Override
    public DramaVO getDramaVO(Drama drama, HttpServletRequest request) {
        // 对象转封装类
        return DramaVO.objToVo(drama);
    }

    /**
     * 分页获取用户评论封装
     *
     * @param dramaPage
     * @param request
     * @return
     */
    @Override
    public Page<DramaVO> getDramaVOPage(Page<Drama> dramaPage, HttpServletRequest request) {
        List<Drama> dramaList = dramaPage.getRecords();
        Page<DramaVO> dramaVOPage = new Page<>(dramaPage.getCurrent(), dramaPage.getSize(), dramaPage.getTotal());
        if (CollUtil.isEmpty(dramaList)) {
            return dramaVOPage;
        }
        // 对象列表 => 封装对象列表
        List<DramaVO> dramaVOList = dramaList.stream().map(DramaVO::objToVo).collect(Collectors.toList());

        dramaVOPage.setRecords(dramaVOList);
        return dramaVOPage;
    }

}
