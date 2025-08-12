package com.hyx.shortdrama.controller;


import com.hyx.shortdrama.common.BaseResponse;
import com.hyx.shortdrama.common.ResultUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/")
public class DemoController {
    @GetMapping("/ping")
    public BaseResponse<Map<String, Object>> ping() {
        Map<String, Object> data = new HashMap<>();
        data.put("message", "pong");
        data.put("time", Instant.now().toString());
        return ResultUtils.success(data);
    }

    @GetMapping("/demo/dramas")
    public BaseResponse<List<Map<String, Object>>> dramas() {
        List<Map<String, Object>> list = Arrays.asList(
                mapOf(1L, "drama-1", "season-1"),
                mapOf(2L, "drama-2", "season-2"),
                mapOf(3L, "drama-3", "season-3")
        );
        return ResultUtils.success(list);
    }

    private Map<String, Object> mapOf(Long id, String title, String season) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", id);
        m.put("title", title);
        m.put("season", season);
        return m;
    }
}
