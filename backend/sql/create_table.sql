# 数据库初始化

-- 创建库
create database if not exists short_drama;

-- 切换库
use short_drama;

-- 短剧视频表
create table if not exists video
(
    id          bigint auto_increment primary key comment 'id',
    title       varchar(512)        null comment '标题',
    description varchar(1024)       null comment '简介',
    videoUrl    varchar(1024)       not null comment '视频直链/播放地址',
    coverUrl    varchar(1024)       null comment '封面图',
    durationSec int                 null comment '时长（秒）',
    orderNum    int      default 0  not null comment '排序权重（越大越靠前）',
    status      tinyint  default 1  not null comment '状态：0-下线 1-上线',
    userId      bigint              not null comment '创建用户 id',
    createTime  datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    updateTime  datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete    tinyint  default 0  not null comment '是否删除',
    index idx_status_order (status, orderNum desc, id desc),
    index idx_userId (userId)
    ) comment '短剧视频' collate = utf8mb4_unicode_ci;


-- 用户表
create table if not exists user
(
    id           bigint auto_increment comment 'id' primary key,
    userAccount  varchar(256)                           not null comment '账号',
    userPassword varchar(512)                           not null comment '密码',
    unionId      varchar(256)                           null comment '微信开放平台id',
    mpOpenId     varchar(256)                           null comment '公众号openId',
    userName     varchar(256)                           null comment '用户昵称',
    userAvatar   varchar(1024)                          null comment '用户头像',
    userProfile  varchar(512)                           null comment '用户简介',
    userRole     varchar(256) default 'user'            not null comment '用户角色：user/admin/ban',
    createTime   datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    updateTime   datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete     tinyint      default 0                 not null comment '是否删除',
    unique index uk_userAccount (userAccount),
    index idx_unionId (unionId),
    index idx_mpOpenId (mpOpenId)
    ) comment '用户' collate = utf8mb4_unicode_ci;