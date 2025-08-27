package com.hyx.shortdrama.controller;

import com.hyx.shortdrama.common.BaseResponse;
import com.hyx.shortdrama.common.ErrorCode;
import com.hyx.shortdrama.common.ResultUtils;
import com.hyx.shortdrama.exception.BusinessException;
import com.hyx.shortdrama.model.dto.ai.AiAskRequest;
import com.hyx.shortdrama.model.dto.ai.AiAskResponse;
import com.hyx.shortdrama.service.AiService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/ai")
public class AiController {

    @Resource
    private AiService aiService;

    @PostMapping("/ask")
    public BaseResponse<AiAskResponse> ask(@RequestBody AiAskRequest req, HttpServletRequest request) {
        if (req == null || StringUtils.isBlank(req.getQuestion())) {
            throw new BusinessException(ErrorCode.PARAMS_ERROR, "question is required");
        }
        AiAskResponse resp = aiService.ask(req, request);
        return ResultUtils.success(resp);
    }
}