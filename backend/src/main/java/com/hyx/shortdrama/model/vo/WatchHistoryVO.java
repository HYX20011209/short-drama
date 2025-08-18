package com.hyx.shortdrama.model.vo;

import cn.hutool.json.JSONUtil;
import com.hyx.shortdrama.model.entity.WatchHistory;
import lombok.Data;
import org.springframework.beans.BeanUtils;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * 观看历史视图
 */
@Data
public class WatchHistoryVO implements Serializable {

    private Long id;
    private Long userId;
    private Long dramaId;
    private Long videoId;
    private Integer episodeNumber;
    private Integer progress;
    private Date lastWatchTime;

    // 关联信息
    private DramaVO drama;
    private VideoVO video;


    /**
     * 封装类转对象
     *
     * @param watchHistoryVO
     * @return
     */
    public static WatchHistory voToObj(WatchHistoryVO watchHistoryVO) {
        if (watchHistoryVO == null) {
            return null;
        }
        WatchHistory watchHistory = new WatchHistory();
        BeanUtils.copyProperties(watchHistoryVO, watchHistory);
        return watchHistory;
    }

    /**
     * 对象转封装类
     *
     * @param watchHistory
     * @return
     */
    public static WatchHistoryVO objToVo(WatchHistory watchHistory) {
        if (watchHistory == null) {
            return null;
        }
        WatchHistoryVO watchHistoryVO = new WatchHistoryVO();
        BeanUtils.copyProperties(watchHistory, watchHistoryVO);
        return watchHistoryVO;
    }
}
