package com.hyx.shortdrama.model.dto.user;

import lombok.Data;

import java.io.Serializable;

@Data
public class UpdateProgressRequest implements Serializable {
    /**
     * 视频ID
     */
    private Long videoId;

    /**
     * 剧集ID（可为空）
     */
    private Long dramaId;

    /**
     * 集数（可为空）
     */
    private Integer episodeNumber;

    /**
     * 观看进度（秒）
     */
    private Integer progress;

    private static final long serialVersionUID = 1L;
}
