package com.hyx.shortdrama.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hyx.shortdrama.model.dto.drama.DramaQueryRequest;
import com.hyx.shortdrama.model.entity.Drama;
import com.hyx.shortdrama.model.vo.DramaVO;

import javax.servlet.http.HttpServletRequest;

/**
 * 用户评论服务
 */
public interface DramaService extends IService<Drama> {
    // TODO 该文件为自动生成，在使用前需要修改

    /**
     * 校验数据
     */
    void validDrama(Drama drama, boolean add);

    /**
     * 获取查询条件
     */
    QueryWrapper<Drama> getQueryWrapper(DramaQueryRequest dramaQueryRequest);

    /**
     * 获取vo（用于Service层内部调用）
     */
    DramaVO getDramaVO(Drama drama);
    
    /**
     * 获取vo
     */
    DramaVO getDramaVO(Drama drama, HttpServletRequest request);

    /**
     * 分页获取vo
     */
    Page<DramaVO> getDramaVOPage(Page<Drama> dramaPage, HttpServletRequest request);
}
