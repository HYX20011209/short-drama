package com.hyx.shortdrama.service;

import com.hyx.shortdrama.model.dto.ai.AiAskRequest;
import com.hyx.shortdrama.model.dto.ai.AiAskResponse;

import javax.servlet.http.HttpServletRequest;

public interface AiService {
    AiAskResponse ask(AiAskRequest req, HttpServletRequest request);
}