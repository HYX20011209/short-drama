package com.hyx.shortdrama.utils;

public final class CacheKeyBuilders {
    public static String dramaList(String category, long current, long pageSize) {
        return "c=" + (category == null ? "" : category) + ":p=" + current + ":s=" + pageSize;
    }
    public static String dramaDetail(long id) { return String.valueOf(id); }
    public static String videoEpisodes(long dramaId) { return String.valueOf(dramaId); }
    public static String videoFeed(Long dramaId, long current, long pageSize) {
        return "d=" + (dramaId == null ? "" : dramaId) + ":p=" + current + ":s=" + pageSize;
    }
    public static String dramaSearch(String q, String category, long current, long pageSize) {
        return "q=" + (q == null ? "" : q) + ":c=" + (category == null ? "" : category)
                + ":p=" + current + ":s=" + pageSize;
    }
    private CacheKeyBuilders() {}
}