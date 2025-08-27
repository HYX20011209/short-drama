package com.hyx.shortdrama.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "ai.service")
public class AiServiceProperties {
    private String baseUrl;
    private Integer timeoutMs = 5000;
}