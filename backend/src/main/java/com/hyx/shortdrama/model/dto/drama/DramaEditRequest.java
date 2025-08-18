package com.hyx.shortdrama.model.dto.drama;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 编辑剧集请求
 */
@Data
public class DramaEditRequest implements Serializable {
    // TODO 该文件为自动生成，在使用前需要修改

    /**
     * id
     */
    private Long id;

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

    private static final long serialVersionUID = 1L;
}