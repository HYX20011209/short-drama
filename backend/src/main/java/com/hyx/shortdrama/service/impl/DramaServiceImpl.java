package com.hyx.shortdrama.service.impl;

import cn.hutool.core.collection.CollUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hyx.shortdrama.common.ErrorCode;
import com.hyx.shortdrama.exception.BusinessException;
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
        if (drama == null) return;
        // 最基本的校验，按需扩展
        if (add) {
            // 标题可选非空策略，这里仅限制长度
        }
        if (drama.getTitle() != null && drama.getTitle().length() > 80) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR, "标题过长");
        }
        if (drama.getDescription() != null && drama.getDescription().length() > 1024) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR, "简介过长");
        }
        if (drama.getCategory() != null && drama.getCategory().length() > 128) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR, "分类过长");
        }
    }

    /**
     * 获取查询条件
     *
     * @param req
     * @return
     */
    @Override
    public QueryWrapper<Drama> getQueryWrapper(DramaQueryRequest req) {
        QueryWrapper<Drama> qw = new QueryWrapper<>();
        if (req == null) {
            return qw.orderByDesc("orderNum").orderByDesc("id");
        }
        Long id = req.getId();
        Long notId = req.getNotId();
        String title = req.getTitle();
        Long userId = req.getUserId();

        qw.ne(notId != null, "id", notId);
        qw.eq(id != null, "id", id);
        qw.eq(userId != null, "userId", userId);
        qw.like(title != null && !title.isEmpty(), "title", title);

        // 排序（默认）
        qw.orderByDesc("orderNum").orderByDesc("id");
        return qw;
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
