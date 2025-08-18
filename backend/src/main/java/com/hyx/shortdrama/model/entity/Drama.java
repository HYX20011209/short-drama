package com.hyx.shortdrama.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

@TableName(value = "drama")
@Data
public class Drama implements Serializable {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private String title;
    private String description;
    private String coverUrl;
    private String category;
    private Integer totalEpisodes;
    private Integer status; // 0-下线 1-上线
    private Integer orderNum;

    private Long userId;

    private Date createTime;
    private Date updateTime;

    @TableLogic
    private Integer isDelete;

    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}