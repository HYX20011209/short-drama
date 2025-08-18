import 'drama.dart';

// 扩展现有的VideoItem，但保持兼容
class EnhancedVideo {
  final int id;
  final String url;
  final String? title;
  final String? cover;
  final int? duration;
  
  // 新增剧集相关字段
  final int? dramaId;
  final int? episodeNumber;
  final Drama? drama;

  EnhancedVideo({
    required this.id,
    required this.url,
    this.title,
    this.cover,
    this.duration,
    this.dramaId,
    this.episodeNumber,
    this.drama,
  });

  factory EnhancedVideo.fromJson(Map<String, dynamic> json) {
    return EnhancedVideo(
      id: json['id'] ?? 0,
      url: json['videoUrl'] ?? '',
      title: json['title'],
      cover: json['coverUrl'],
      duration: json['durationSec'],
      dramaId: json['dramaId'],
      episodeNumber: json['episodeNumber'],
      drama: json['drama'] != null ? Drama.fromJson(json['drama']) : null,
    );
  }
}

// 为了兼容现有代码，保留原始的VideoItem类
class VideoItem {
  final int id;
  final String url;
  final String? title;
  final String? cover;
  final int? duration;

  VideoItem({
    required this.id,
    required this.url,
    this.title,
    this.cover,
    this.duration,
  });

  factory VideoItem.fromJson(Map<String, dynamic> j) {
    int? parseIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      final s = v.toString();
      return s.isEmpty ? null : int.tryParse(s);
    }

    return VideoItem(
      id: parseIntOrNull(j['id']) ?? 0,
      url: j['videoUrl'] ?? '',
      title: j['title'],
      cover: j['coverUrl'],
      duration: parseIntOrNull(j['durationSec']),
    );
  }

  // 从EnhancedVideo转换
  factory VideoItem.fromEnhancedVideo(EnhancedVideo enhanced) {
    return VideoItem(
      id: enhanced.id,
      url: enhanced.url,
      title: enhanced.title,
      cover: enhanced.cover,
      duration: enhanced.duration,
    );
  }
}