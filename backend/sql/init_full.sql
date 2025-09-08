-- init_full.sql
-- 一体化初始化脚本：等价于
-- 1) create_table.sql
-- 2) upgrade_drama_schema.sql
-- 3) generate-test-data.sql 的数据插入

-- ========================
-- 0) 创建库并切换
-- ========================
CREATE DATABASE IF NOT EXISTS short_drama
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE short_drama;

-- ========================
-- 1) 基础表
-- ========================

-- 短剧视频表（基础字段）
CREATE TABLE IF NOT EXISTS video
(
    id          BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'id',
    title       VARCHAR(512)        NULL COMMENT '标题',
    description VARCHAR(1024)       NULL COMMENT '简介',
    videoUrl    VARCHAR(1024)       NOT NULL COMMENT '视频直链/播放地址',
    coverUrl    VARCHAR(1024)       NULL COMMENT '封面图',
    durationSec INT                 NULL COMMENT '时长（秒）',
    orderNum    INT      DEFAULT 0  NOT NULL COMMENT '排序权重（越大越靠前）',
    status      TINYINT  DEFAULT 1  NOT NULL COMMENT '状态：0-下线 1-上线',
    userId      BIGINT              NOT NULL COMMENT '创建用户 id',
    createTime  DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    updateTime  DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    isDelete    TINYINT  DEFAULT 0  NOT NULL COMMENT '是否删除',
    INDEX idx_status_order (status, orderNum DESC, id DESC),
    INDEX idx_userId (userId)
) COMMENT '短剧视频' COLLATE = utf8mb4_unicode_ci;

-- 用户表
CREATE TABLE IF NOT EXISTS user
(
    id           BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'id',
    userAccount  VARCHAR(256)                           NOT NULL COMMENT '账号',
    userPassword VARCHAR(512)                           NOT NULL COMMENT '密码',
    unionId      VARCHAR(256)                           NULL COMMENT '微信开放平台id',
    mpOpenId     VARCHAR(256)                           NULL COMMENT '公众号openId',
    userName     VARCHAR(256)                           NULL COMMENT '用户昵称',
    userAvatar   VARCHAR(1024)                          NULL COMMENT '用户头像',
    userProfile  VARCHAR(512)                           NULL COMMENT '用户简介',
    userRole     VARCHAR(256) DEFAULT 'user'            NOT NULL COMMENT '用户角色：user/admin/ban',
    createTime   DATETIME     DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    updateTime   DATETIME     DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    isDelete     TINYINT      DEFAULT 0                 NOT NULL COMMENT '是否删除',
    UNIQUE INDEX uk_userAccount (userAccount),
    INDEX idx_unionId (unionId),
    INDEX idx_mpOpenId (mpOpenId)
) COMMENT '用户' COLLATE = utf8mb4_unicode_ci;

-- ========================
-- 2) 架构升级（等价于 upgrade_drama_schema.sql 的 DDL）
-- ========================

-- 2.1 扩展 video 表，添加剧集相关字段与索引
ALTER TABLE video
    ADD COLUMN IF NOT EXISTS dramaId BIGINT NULL COMMENT '所属剧集id' AFTER userId,
    ADD COLUMN IF NOT EXISTS episodeNumber INT NULL COMMENT '集数（第几集）' AFTER dramaId;

-- 为避免重复索引错误，先判断后创建（MySQL 8.0+ 可用 IF NOT EXISTS；若版本较低，可忽略重复报错或手工检查）
CREATE INDEX IF NOT EXISTS idx_drama_episode ON video (dramaId, episodeNumber);

-- 2.2 新增剧集表
CREATE TABLE IF NOT EXISTS drama
(
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'id',
    title VARCHAR(512) NOT NULL COMMENT '剧集名称',
    description VARCHAR(1024) NULL COMMENT '剧集简介',
    coverUrl VARCHAR(1024) NULL COMMENT '剧集封面',
    category VARCHAR(128) NULL COMMENT '分类（都市、古装、悬疑等）',
    totalEpisodes INT DEFAULT 0 COMMENT '总集数',
    status TINYINT DEFAULT 1 NOT NULL COMMENT '状态：0-下线 1-上线',
    orderNum INT DEFAULT 0 NOT NULL COMMENT '排序权重（越大越靠前）',
    userId BIGINT NOT NULL COMMENT '创建用户id',
    createTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    updateTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    isDelete TINYINT DEFAULT 0 NOT NULL COMMENT '是否删除',
    INDEX idx_status_order (status, orderNum DESC, id DESC),
    INDEX idx_category (category),
    INDEX idx_userId (userId)
) COMMENT '短剧剧集' COLLATE = utf8mb4_unicode_ci;

-- 2.3 观看历史表
CREATE TABLE IF NOT EXISTS watch_history
(
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'id',
    userId BIGINT NOT NULL COMMENT '用户id',
    dramaId BIGINT NULL COMMENT '剧集id（可为空，兼容单独视频）',
    videoId BIGINT NOT NULL COMMENT '视频id',
    episodeNumber INT NULL COMMENT '看到第几集',
    progress INT DEFAULT 0 COMMENT '观看进度（秒）',
    lastWatchTime DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后观看时间',
    createTime DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updateTime DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_user_video (userId, videoId),
    INDEX idx_user_time (userId, lastWatchTime DESC),
    INDEX idx_drama (dramaId)
) COMMENT '观看历史' COLLATE = utf8mb4_unicode_ci;

-- 2.4 收藏表
CREATE TABLE IF NOT EXISTS user_drama_favorite
(
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'id',
    userId BIGINT NOT NULL COMMENT '用户id',
    dramaId BIGINT NOT NULL COMMENT '剧集id',
    createTime DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updateTime DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_user_drama (userId, dramaId),
    INDEX idx_user (userId),
    INDEX idx_drama (dramaId)
) COMMENT '用户剧集收藏' COLLATE = utf8mb4_unicode_ci;

-- 注意：此处“不会”插入 upgrade_drama_schema.sql 中“第5步（可选）”的3条样例数据
-- 这样可以与 generate-test-data.sql 的显式 id=1..5 插入避免冲突，复现你目前的最终数据集

-- ========================
-- 3) 测试数据（等价于 generate-test-data.sql，含其注释行仍为注释）
-- ========================

-- 3.1 插入测试用户（作为内容创建者）
INSERT INTO user (id, userAccount, userPassword, userName, userAvatar, userProfile, userRole, createTime, updateTime, isDelete) VALUES
    (2, 'creator1', '111111', '内容创作者1', '', '专业短剧制作团队', 'user', NOW(), NOW(), 0);

-- 3.2 插入剧集数据（显式 id，确保与现有数据一致）
INSERT INTO drama (id, title, description, coverUrl, category, totalEpisodes, status, orderNum, userId, createTime, updateTime, isDelete) VALUES
                                                                                                                                              -- 1
                                                                                                                                              (1, 'title-1', 'desc-1', '', 'urban', 2, 1, 100, 1, NOW(), NOW(), 0),

                                                                                                                                              -- 2
                                                                                                                                              (2, 'title-2', 'desc-2', '', 'costume', 1, 1, 90, 1, NOW(), NOW(), 0),

                                                                                                                                              -- 3
                                                                                                                                              (3, 'title-3', 'desc-3', '', 'mystery', 1, 1, 80, 2, NOW(), NOW(), 0),

                                                                                                                                              -- 4
                                                                                                                                              (4, 'title-4', 'desc-4', '', 'romance', 1, 1, 70, 2, NOW(), NOW(), 0),

                                                                                                                                              -- 5
                                                                                                                                              (5, 'title-5', 'desc-5', '', 'youth', 1, 1, 60, 1, NOW(), NOW(), 0);

-- 3.3 插入视频数据（每个剧集的前几集）

-- drama-1 (drama_id=1)
INSERT INTO video (title, description, videoUrl, coverUrl, durationSec, orderNum, status, userId, dramaId, episodeNumber, createTime, updateTime, isDelete) VALUES
  ('drama-1 ep-1', 'desc of drama-1 ep-1', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4', 'https://img.alicdn.com/imgextra/i1/6000000007738/O1CN01ep01_1wvLU1qY8tM_!!6000000007738-2-tps-300-200.png', 180, 100, 1, 1, 1, 1, NOW(), NOW(), 0),
  ('drama-1 ep-2', 'desc of drama-1 ep-2', 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4', 'https://img.alicdn.com/imgextra/i1/6000000007738/O1CN01ep02_1wvLU1qY8tM_!!6000000007738-2-tps-300-200.png', 175, 99, 1, 1, 1, 2, NOW(), NOW(), 0);

-- drama-2 (drama_id=2)
INSERT INTO video (title, description, videoUrl, coverUrl, durationSec, orderNum, status, userId, dramaId, episodeNumber, createTime, updateTime, isDelete) VALUES
    ('drama-2 ep-1', 'desc of drama-2 ep-1', 'https://drama-1325318408.cos.ap-beijing.myqcloud.com/vid1.mp4', '', 190, 90, 1, 1, 2, 1, NOW(), NOW(), 0);

-- drama-3 (drama_id=3)
INSERT INTO video (title, description, videoUrl, coverUrl, durationSec, orderNum, status, userId, dramaId, episodeNumber, createTime, updateTime, isDelete) VALUES
    ('drama-3 ep-1', 'desc of drama-3 ep-1', 'https://drama-1325318408.cos.ap-beijing.myqcloud.com/vid1.mp4', '', 200, 80, 1, 2, 3, 1, NOW(), NOW(), 0);

-- drama-4 (drama_id=4)
INSERT INTO video (title, description, videoUrl, coverUrl, durationSec, orderNum, status, userId, dramaId, episodeNumber, createTime, updateTime, isDelete) VALUES
    ('drama-4 ep-1', 'desc of drama-4 ep-1', 'https://drama-1325318408.cos.ap-beijing.myqcloud.com/vid1.mp4', '', 170, 70, 1, 2, 4, 1, NOW(), NOW(), 0);

-- drama-5 (drama_id=5)
INSERT INTO video (title, description, videoUrl, coverUrl, durationSec, orderNum, status, userId, dramaId, episodeNumber, createTime, updateTime, isDelete) VALUES
    ('drama-5 ep-1', 'desc of drama-3 ep-1', 'https://drama-1325318408.cos.ap-beijing.myqcloud.com/vid1.mp4', '', 165, 60, 1, 1, 5, 1, NOW(), NOW(), 0);

-- ========================
-- 4) 可选自检查询（与 generate-test-data.sql 保持一致）
-- ========================
# SELECT '=== 剧集数据 ===' AS info;
# SELECT id, title, category, totalEpisodes, status FROM drama WHERE isDelete = 0;
#
# SELECT '=== 视频数据（剧集相关） ===' AS info;
# SELECT v.id, v.title, v.dramaId, v.episodeNumber, d.title AS drama_title
# FROM video v
#          LEFT JOIN drama d ON v.dramaId = d.id
# WHERE v.isDelete = 0 AND v.dramaId IS NOT NULL
# ORDER BY v.dramaId, v.episodeNumber;
