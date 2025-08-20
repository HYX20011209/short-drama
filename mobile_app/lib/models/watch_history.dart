import 'drama.dart';
import 'enhanced_video.dart';

class WatchHistory {
  final String id;
  final String userId;
  final String? dramaId;
  final String videoId;
  final int? episodeNumber;
  final int progress; // 观看进度（秒）
  final DateTime lastWatchTime;
  final DateTime createTime;
  final DateTime updateTime;

  // 关联对象
  final Drama? drama;
  final EnhancedVideo? video;

  WatchHistory({
    required this.id,
    required this.userId,
    this.dramaId,
    required this.videoId,
    this.episodeNumber,
    required this.progress,
    required this.lastWatchTime,
    required this.createTime,
    required this.updateTime,
    this.drama,
    this.video,
  });

  factory WatchHistory.fromJson(Map<String, dynamic> json) {
    return WatchHistory(
      id: json['id']?.toString() ?? '0',
      userId: json['userId']?.toString() ?? '0',
      dramaId: json['dramaId']?.toString(),
      videoId: json['videoId']?.toString() ?? '0',
      episodeNumber: json['episodeNumber'] as int?,
      progress: json['progress'] as int? ?? 0,
      lastWatchTime: DateTime.parse(
        json['lastWatchTime'] ?? DateTime.now().toIso8601String(),
      ),
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      updateTime: DateTime.parse(
        json['updateTime'] ?? DateTime.now().toIso8601String(),
      ),
      drama: json['drama'] != null ? Drama.fromJson(json['drama']) : null,
      video: json['video'] != null
          ? EnhancedVideo.fromJson(json['video'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dramaId': dramaId,
      'videoId': videoId,
      'episodeNumber': episodeNumber,
      'progress': progress,
      'lastWatchTime': lastWatchTime.toIso8601String(),
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }

  /// 格式化观看进度
  String get formattedProgress {
    final hours = progress ~/ 3600;
    final minutes = (progress % 3600) ~/ 60;
    final seconds = progress % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
