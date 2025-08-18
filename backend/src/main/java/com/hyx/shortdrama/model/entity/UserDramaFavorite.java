package com.hyx.shortdrama.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

@TableName(value = "user_drama_favorite")
@Data
public class UserDramaFavorite implements Serializable {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;
    private Long dramaId;

    private Date createTime;
    private Date updateTime;

    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}