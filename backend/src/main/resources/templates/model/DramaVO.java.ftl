package ${packageName}.model.vo;

import ${packageName}.model.entity.${upperDataKey};
import lombok.Data;
import org.springframework.beans.BeanUtils;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
* ${dataName}视图
*/
@Data
public class ${upperDataKey}VO implements Serializable {

/**
* id
*/
private Long id;

/**
* 剧集名称
*/
private String title;

/**
* 剧集简介
*/
private String description;

/**
* 剧集封面
*/
private String coverUrl;

/**
* 分类
*/
private String category;

/**
* 总集数
*/
private Integer totalEpisodes;

/**
* 创建时间
*/
private Date createTime;

/**
* 更新时间
*/
private Date updateTime;

// 扩展字段
/**
* 剧集包含的所有集数
*/
private List<VideoVO> episodes;

    /**
    * 当前用户是否收藏
    */
    private Boolean isFavorited;

    /**
    * 已观看集数
    */
    private Integer watchedEpisodes;

    /**
    * 对象转封装类
    *
    * @param ${dataKey}
    * @return
    */
    public static ${upperDataKey}VO objToVo(${upperDataKey} ${dataKey}) {
    if (${dataKey} == null) {
    return null;
    }
    ${upperDataKey}VO ${dataKey}VO = new ${upperDataKey}VO();
    BeanUtils.copyProperties(${dataKey}, ${dataKey}VO);
    return ${dataKey}VO;
    }

    private static final long serialVersionUID = 1L;
    }