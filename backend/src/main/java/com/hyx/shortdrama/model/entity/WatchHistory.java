package com.hyx.shortdrama.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

@TableName(value = "watch_history")
@Data
public class WatchHistory implements Serializable {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;
    private Long dramaId;        // 可为空，兼容单独视频
    private Long videoId;
    private Integer episodeNumber; // 可为空
    private Integer progress;    // 观看进度（秒）

    private Date lastWatchTime;
    private Date createTime;
    private Date updateTime;

    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}