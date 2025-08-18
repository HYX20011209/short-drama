package com.hyx.shortdrama.model.dto.video;

import lombok.Data;

import java.io.Serializable;

@Data
public class VideoAddRequest implements Serializable {

    private String title;
    private String description;
    private String videoUrl;   // 必填：上传返回的地址
    private String coverUrl;
    private Integer durationSec;
    private Integer orderNum;  // 默认可为 0
    private Integer status;    // 0/1，默认 1

    private static final long serialVersionUID = 1L;
}