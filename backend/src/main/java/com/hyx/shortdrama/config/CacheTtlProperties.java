package com.hyx.shortdrama.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

@Data
@ConfigurationProperties(prefix = "shortdrama.cache.ttl")
public class CacheTtlProperties {
    private Duration dramaList = Duration.ofMinutes(5);
    private Duration dramaDetail = Duration.ofMinutes(30);
    private Duration videoEpisodes = Duration.ofMinutes(30);
    private Duration videoFeed = Duration.ofSeconds(30);
    private Duration dramaSearch = Duration.ofSeconds(30);
}