-- 短剧架构升级脚本
-- 在现有基础上添加剧集功能，保持向后兼容

USE short_drama;

-- 1. 扩展video表，添加剧集相关字段（可为空，保持向后兼容）
ALTER TABLE video
    ADD COLUMN dramaId BIGINT NULL COMMENT '所属剧集id' AFTER userId,
    ADD COLUMN episodeNumber INT NULL COMMENT '集数（第几集）' AFTER dramaId,
    ADD INDEX idx_drama_episode (dramaId, episodeNumber);

-- 2. 新增剧集表
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

-- 3. 观看历史表
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

-- 4. 收藏表
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

-- 5. 插入一些测试数据（可选）
INSERT INTO drama (title, description, coverUrl, category, totalEpisodes, userId) VALUES
                                                                                      ('title-1', 'desc-1', 'https://example.com/cover1.jpg', '都市', 2, 1),
                                                                                      ('title-2', 'desc-2', 'https://example.com/cover2.jpg', '古装', 2, 1),
                                                                                      ('title-3', 'desc-3', 'https://example.com/cover3.jpg', '悬疑', 2, 1);