package com.hyx.shortdrama.model.dto.video;

import com.hyx.shortdrama.common.PageRequest;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;

@EqualsAndHashCode(callSuper = true)
@Data
public class VideoQueryRequest extends PageRequest implements Serializable {

    private Long id;
    private Long notId;
    private String title;
    private Integer status; // 0/1
    private Long userId;

    private Long dramaId;
    private Integer episodeNumber;

    private static final long serialVersionUID = 1L;
}
