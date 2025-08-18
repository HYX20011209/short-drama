import 'drama.dart';
import 'enhanced_video.dart';

class WatchHistory {
  final int id;
  final int userId;
  final int? dramaId;
  final int videoId;
  final int? episodeNumber;
  final int progress; // 观看进度（秒）
  final DateTime lastWatchTime;
  
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
    this.drama,
    this.video,
  });

  factory WatchHistory.fromJson(Map<String, dynamic> json) {
    return WatchHistory(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      dramaId: json['dramaId'],
      videoId: json['videoId'] ?? 0,
      episodeNumber: json['episodeNumber'],
      progress: json['progress'] ?? 0,
      lastWatchTime: DateTime.parse(
        json['lastWatchTime'] ?? DateTime.now().toIso8601String(),
      ),
      drama: json['drama'] != null ? Drama.fromJson(json['drama']) : null,
      video: json['video'] != null ? EnhancedVideo.fromJson(json['video']) : null,
    );
  }
}