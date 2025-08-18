package com.hyx.shortdrama.model.dto.drama;

import lombok.Data;

import java.io.Serializable;

/**
 * 创建剧集请求
 */
@Data
public class DramaAddRequest implements Serializable {
    // TODO 该文件为自动生成，在使用前需要修改

    /**
     * 剧集名称
     */
    private String title;

    /**
     * 剧集简介
     */
    private String description;

    /**
     * 剧集封面
     */
    private String coverUrl;

    /**
     * 分类
     */
    private String category;

    /**
     * 总集数
     */
    private Integer totalEpisodes;

    /**
     * 状态：0-下线 1-上线
     */
    private Integer status;

    /**
     * 排序权重
     */
    private Integer orderNum;

    private static final long serialVersionUID = 1L;
}