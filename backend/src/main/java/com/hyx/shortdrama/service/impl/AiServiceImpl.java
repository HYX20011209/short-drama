package com.hyx.shortdrama.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hyx.shortdrama.config.AiServiceProperties;
import com.hyx.shortdrama.model.dto.ai.AiAskRequest;
import com.hyx.shortdrama.model.dto.ai.AiAskResponse;
import com.hyx.shortdrama.model.entity.Drama;
import com.hyx.shortdrama.model.vo.DramaVO;
import com.hyx.shortdrama.service.AiService;
import com.hyx.shortdrama.service.DramaService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.net.URI;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
public class AiServiceImpl implements AiService {

    @Resource
    private AiServiceProperties properties;

    @Resource
    private DramaService dramaService;

    private RestTemplate buildRestTemplate() {
        // Simple timeout-based RestTemplate
        java.net.Proxy proxy = java.net.Proxy.NO_PROXY;
        org.springframework.http.client.SimpleClientHttpRequestFactory f = new org.springframework.http.client.SimpleClientHttpRequestFactory();
        f.setConnectTimeout(properties.getTimeoutMs());
        f.setReadTimeout(properties.getTimeoutMs());
        f.setProxy(proxy);
        return new RestTemplate(f);
    }

    private String buildAskUrl() {
        String base = properties.getBaseUrl();
        if (base.endsWith("/")) {
            base = base.substring(0, base.length() - 1);
        }
        return base + "/rag/ask";
    }

    @Override
    public AiAskResponse ask(AiAskRequest req, HttpServletRequest request) {
        int topK = (req.getTopK() == null || req.getTopK() <= 0 || req.getTopK() > 50) ? 6 : req.getTopK();
        String scene = (req.getScene() == null || req.getScene().trim().isEmpty()) ? "search" : req.getScene().trim();

        // 1) Call Python AI service
        try {
            RestTemplate rt = buildRestTemplate();
            ObjectMapper om = new ObjectMapper();

            Map<String, Object> body = new HashMap<>();
            body.put("question", req.getQuestion());
            body.put("topK", topK);
            body.put("scene", scene);
            if (req.getDramaId() != null && req.getDramaId() > 0) {
                body.put("dramaId", req.getDramaId());
            }

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<String> httpEntity = new HttpEntity<>(om.writeValueAsString(body), headers);

            ResponseEntity<String> resp = rt.exchange(URI.create(buildAskUrl()), HttpMethod.POST, httpEntity, String.class);
            if (resp.getStatusCode().is2xxSuccessful() && resp.getBody() != null) {
                PyAskResponse py = om.readValue(resp.getBody(), PyAskResponse.class);
                AiAskResponse out = new AiAskResponse();
                out.setAnswer(py.getAnswer() != null ? py.getAnswer() : "");

                // Map hits -> DramaVO (enrich via service to keep consistent with app)
                List<DramaVO> vos = mapHitsToDramaVO(py.getRelatedDramas(), request, topK);
                out.setRelatedDramas(vos);
                // if AI empty, fallback to search
                if (CollectionUtils.isEmpty(vos)) {
                    return fallbackSearch(req.getQuestion(), topK, request, "No AI results, showing keyword search.");
                }
                return out;
            }
        } catch (ResourceAccessException e) {
            log.warn("AI service timeout: {}", e.getMessage());
            return fallbackSearch(req.getQuestion(), topK, request, "AI service timeout, showing keyword search.");
        } catch (Exception e) {
            log.warn("AI service error: {}", e.getMessage(), e);
            return fallbackSearch(req.getQuestion(), topK, request, "AI service error, showing keyword search.");
        }

        // Unexpected case
        return fallbackSearch(req.getQuestion(), topK, request, "AI service unavailable, showing keyword search.");
    }

    private AiAskResponse fallbackSearch(String question, int topK, HttpServletRequest request, String msg) {
        Page<DramaVO> page = dramaService.search(
                question != null ? question : "",
                1, topK, null, request
        );
        List<DramaVO> list = page != null ? page.getRecords() : Collections.emptyList();
        AiAskResponse out = new AiAskResponse();
        out.setAnswer(msg);
        out.setRelatedDramas(list);
        return out;
    }

    private List<DramaVO> mapHitsToDramaVO(List<PyDramaHit> hits, HttpServletRequest request, int limit) {
        if (CollectionUtils.isEmpty(hits)) return Collections.emptyList();

        // Dedup dramaId, keep original order
        LinkedHashMap<Long, PyDramaHit> uniq = new LinkedHashMap<>();
        for (PyDramaHit h : hits) {
            if (h.getDramaId() != null && !uniq.containsKey(h.getDramaId())) {
                uniq.put(h.getDramaId(), h);
            }
        }
        List<Long> ids = uniq.keySet().stream().limit(limit).collect(Collectors.toList());
        List<DramaVO> result = new ArrayList<>(ids.size());

        for (Long id : ids) {
            try {
                // Prefer service method to enrich (favorite, watchedEpisodes, etc.)
                DramaVO vo = dramaService.getDramaDetail(id, request);
                if (vo != null) {
                    result.add(vo);
                } else {
                    // Fallback minimal mapping from entity
                    Drama entity = dramaService.getById(id);
                    if (entity != null) {
                        result.add(DramaVO.objToVo(entity));
                    }
                }
            } catch (Exception e) {
                log.debug("Map hit error for dramaId={}: {}", id, e.getMessage());
            }
        }
        return result;
    }

    // ---------- Inner DTO for Python response ----------
    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class PyAskResponse {
        private String answer;
        private List<PyDramaHit> relatedDramas;

        public String getAnswer() { return answer; }
        public void setAnswer(String answer) { this.answer = answer; }
        public List<PyDramaHit> getRelatedDramas() { return relatedDramas; }
        public void setRelatedDramas(List<PyDramaHit> relatedDramas) { this.relatedDramas = relatedDramas; }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class PyDramaHit {
        private Long dramaId;
        private String title;
        private String category;
        private String description;
        private String snippet;
        private Double score;

        public Long getDramaId() { return dramaId; }
        public void setDramaId(Long dramaId) { this.dramaId = dramaId; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public String getSnippet() { return snippet; }
        public void setSnippet(String snippet) { this.snippet = snippet; }
        public Double getScore() { return score; }
        public void setScore(Double score) { this.score = score; }
    }
}