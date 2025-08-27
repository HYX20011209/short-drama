package com.hyx.shortdrama.model.dto.ai;

import lombok.Data;

@Data
public class AiAskRequest {
    private String question;
    private Integer topK;
    private String scene;   // search | recommend | qa
    private Long dramaId;   // for qa
}