package com.hyx.shortdrama.model.vo;

import com.hyx.shortdrama.model.entity.Video;
import lombok.Data;
import org.springframework.beans.BeanUtils;

import java.io.Serializable;
import java.util.Date;

@Data
public class VideoVO implements Serializable {
    private Long id;
    private String title;
    private String description;
    private String videoUrl;
    private String coverUrl;
    private Integer durationSec;
    private Date createTime;
    private Date updateTime;

    // 新增字段（剧集相关）
    private Long dramaId;
    private Integer episodeNumber;
    private DramaVO drama;  // 所属剧集信息

    public static VideoVO objToVo(Video v) {
        if (v == null) return null;
        VideoVO vo = new VideoVO();
        BeanUtils.copyProperties(v, vo);
        return vo;
    }

    private static final long serialVersionUID = 1L;
}
