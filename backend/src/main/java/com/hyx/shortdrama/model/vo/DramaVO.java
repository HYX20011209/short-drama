package com.hyx.shortdrama.model.vo;

import cn.hutool.json.JSONUtil;
import com.hyx.shortdrama.model.entity.Drama;
import lombok.Data;
import org.springframework.beans.BeanUtils;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * 用户评论视图
 */
@Data
public class DramaVO implements Serializable {
    private Long id;
    private String title;
    private String description;
    private String coverUrl;
    private String category;
    private Integer totalEpisodes;
    private Date createTime;
    private Date updateTime;

    // 扩展字段
    private List<VideoVO> episodes;  // 剧集包含的所有集数
    private Boolean isFavorited;     // 当前用户是否收藏
    private Integer watchedEpisodes; // 已观看集数

    /**
     * 封装类转对象
     *
     * @param dramaVO
     * @return
     */
    public static Drama voToObj(DramaVO dramaVO) {
        if (dramaVO == null) {
            return null;
        }
        Drama drama = new Drama();
        BeanUtils.copyProperties(dramaVO, drama);
        return drama;
    }

    /**
     * 对象转封装类
     *
     * @param drama
     * @return
     */
    public static DramaVO objToVo(Drama drama) {
        if (drama == null) {
            return null;
        }
        DramaVO dramaVO = new DramaVO();
        BeanUtils.copyProperties(drama, dramaVO);
        return dramaVO;
    }
}
