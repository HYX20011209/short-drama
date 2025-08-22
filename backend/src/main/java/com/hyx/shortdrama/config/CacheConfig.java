package com.hyx.shortdrama.config;

import com.hyx.shortdrama.constant.CacheConstant;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.cache.RedisCacheWriter;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import java.util.HashMap;
import java.util.Map;

@Configuration
@EnableConfigurationProperties(CacheTtlProperties.class)
public class CacheConfig {

    @Bean
    public RedisCacheManager redisCacheManager(RedisConnectionFactory cf, CacheTtlProperties ttlProps) {
        GenericJackson2JsonRedisSerializer serializer = new GenericJackson2JsonRedisSerializer();

        RedisCacheConfiguration defaultCfg = RedisCacheConfiguration.defaultCacheConfig()
                .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(serializer))
                .disableCachingNullValues()
                .prefixCacheNameWith(CacheConstant.PREFIX);

        Map<String, RedisCacheConfiguration> map = new HashMap<>();
        map.put(CacheConstant.DRAMA_LIST,     defaultCfg.entryTtl(ttlProps.getDramaList()));
        map.put(CacheConstant.DRAMA_DETAIL,   defaultCfg.entryTtl(ttlProps.getDramaDetail()));
        map.put(CacheConstant.VIDEO_EPISODES, defaultCfg.entryTtl(ttlProps.getVideoEpisodes()));
        map.put(CacheConstant.VIDEO_FEED,     defaultCfg.entryTtl(ttlProps.getVideoFeed()));
        map.put(CacheConstant.DRAMA_SEARCH,   defaultCfg.entryTtl(ttlProps.getDramaSearch()));

        return new RedisCacheManager(
                RedisCacheWriter.nonLockingRedisCacheWriter(cf),
                defaultCfg, map
        );
    }

    // 全局开关（@Cacheable condition 使用）
    @Bean
    public CacheSwitch cacheSwitch(@Value("${shortdrama.cache.enabled:true}") boolean enabled){
        return new CacheSwitch(enabled);
    }

    public static class CacheSwitch {
        private  final boolean enabled;
        public CacheSwitch(boolean enabled) {
            this.enabled = enabled;
        }
        public boolean isEnabled() {
            return enabled;
        }
    }
}
