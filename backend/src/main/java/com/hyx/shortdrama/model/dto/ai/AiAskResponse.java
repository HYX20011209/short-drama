package com.hyx.shortdrama.model.dto.ai;

import com.hyx.shortdrama.model.vo.DramaVO;
import lombok.Data;

import java.util.List;

@Data
public class AiAskResponse {
    private String answer;
    private List<DramaVO> relatedDramas;
}