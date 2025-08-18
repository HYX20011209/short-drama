package com.hyx.shortdrama.model.dto.drama;

import com.hyx.shortdrama.common.PageRequest;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;
import java.util.List;

/**
 * 查询剧集请求
 */
@EqualsAndHashCode(callSuper = true)
@Data
public class DramaQueryRequest extends PageRequest implements Serializable {
    // TODO 该文件为自动生成，在使用前需要修改

    /**
     * id
     */
    private Long id;

    /**
     * id
     */
    private Long notId;

    /**
     * 搜索词
     */
    private String searchText;

    /**
     * 标题
     */
    private String title;

    /**
     * 内容
     */
    private String content;

    /**
     * 标签列表
     */
    private List<String> tags;

    /**
     * 创建用户 id
     */
    private Long userId;

    private static final long serialVersionUID = 1L;
}