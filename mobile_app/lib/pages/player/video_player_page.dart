import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/enhanced_video.dart';
import '../../providers/app_state.dart';
import '../../services/video_service.dart';
import '../../services/watch_history_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text_styles.dart';

class VideoPlayerPage extends StatefulWidget {
  final int? dramaId; // 可选的剧集ID
  final int? startEpisode; // 起始集数

  const VideoPlayerPage({Key? key, this.dramaId, this.startEpisode})
    : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final PageController _pageController = PageController();
  final List<VideoItem> _items = [];
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _userPausedVideos = {};
  int _currentIndex = 0;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _loading = false;
  bool _hasMore = true;

  // ==================== 播放控制常量 ====================
  // 播放速度相关
  static const double _normalSpeed = 1.0;
  static const double _fastSpeed = 3.0;

  // 分页相关
  static const int _defaultPageSize = 10;
  static const int _loadMoreThreshold = 3; // 剩余3条时加载更多

  // 预加载相关
  static const int _preloadNextCount = 1; // 预加载下1条
  static const int _disposeBeforeCount = 2; // 提前2条释放资源

  // 进度保存相关
  static const int _progressSaveInterval = 5; // 每5秒保存一次进度
  static const int _minProgressDiff = 3; // 进度变化超过3秒才保存
  static const int _minVideoDurationForSave = 10; // 视频太短不保存（秒）
  static const int _startSaveThreshold = 3; // 开始3秒内不保存（秒）
  static const int _endSaveThreshold = 10; // 结束前10秒不保存（秒）
  static const int _minPositionForSave = 3; // 播放超过3秒才保存（秒）

  // 进度恢复相关
  static const int _defaultMinResumeSeconds = 10; // 默认最小恢复阈值（秒）
  static const int _defaultTailGuardSeconds = 30; // 默认尾部保护（秒）
  static const int _aggressiveMinResumeSeconds = 1; // 激进恢复阈值（秒）
  static const int _aggressiveTailGuardSeconds = 5; // 激进尾部保护（秒）

  // 视频初始化相关
  static const int _maxInitAttempts = 50; // 最多等待初始化次数
  static const int _initCheckIntervalMs = 100; // 初始化检查间隔（毫秒）

  // UI相关
  static const double _playButtonSize = 72.0;
  static const double _backButtonSize = 28.0;
  static const double _titleFontSize = 16.0;
  static const double _titleBottomMargin = 40.0;
  static const double _titleLeftMargin = 16.0;
  static const double _titleRightMargin = 16.0;
  static const double _backButtonTopMargin = 10.0;
  static const double _backButtonLeftMargin = 16.0;
  static const double _backButtonOpacity = 0.5;
  static const double _backButtonRadius = 20.0;

  // 每个视频期望的速度（默认 1.0），以及当前长按的视频 id
  final Map<int, double> _desiredSpeed = {};
  int? _longPressVideoId;

  // 观看进度相关
  Timer? _progressTimer;
  final Map<int, int> _lastSavedProgress = {}; // 记录每个视频上次保存的进度

  @override
  void initState() {
    super.initState();
    _loadMore().then((_) {
      // 根据入口参数定位初始页
      int initialIndex = 0;
      if (widget.dramaId != null && widget.startEpisode != null) {
        final idx = widget.startEpisode! - 1;
        if (idx >= 0 && idx < _items.length) {
          initialIndex = idx;
        }
      }
      if (initialIndex > 0) {
        _pageController.jumpToPage(initialIndex);
      }
      _playAt(initialIndex);
    });
    _startProgressTimer(); // 启动进度保存定时器
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    _loading = true;

    try {
      final items = await VideoService.getVideoFeed(
        current: _currentPage,
        pageSize: _defaultPageSize,
        dramaId: widget.dramaId,
      );

      setState(() {
        _items.addAll(items);
        _currentPage++;
        _hasMore = items.length >= _defaultPageSize;
      });

      _preload(_currentIndex);
      _preload(_currentIndex + _preloadNextCount);
    } catch (e) {
      print('加载视频失败: $e');
    } finally {
      _loading = false;
    }
  }

  void _togglePlay(int index) {
    // 确保操作的是当前页面的视频
    if (index != _currentIndex || index < 0 || index >= _items.length) return;

    final key = _items[index].id;
    final c = _controllers[key];

    if (c == null || !c.value.isInitialized) return;

    if (c.value.isPlaying) {
      // 用户主动暂停
      c.pause();
      _userPausedVideos.add(key);
    } else {
      // 用户主动播放
      c.play();
      _userPausedVideos.remove(key);
    }
    setState(() {}); // 刷新UI
  }

  void _applyDesiredSpeed(int videoId) {
    final c = _controllers[videoId];
    if (c != null && c.value.isInitialized) {
      final s = _desiredSpeed[videoId] ?? _normalSpeed;
      c.setPlaybackSpeed(s);
    }
  }

  // 长按开始：当前视频切倍速
  void _onLongPressStart(int index) {
    if (index != _currentIndex || index < 0 || index >= _items.length) return;
    final id = _items[index].id;
    _desiredSpeed[id] = _fastSpeed;
    _applyDesiredSpeed(id);
    _longPressVideoId = id;
  }

  // 长按结束：恢复 1 倍速
  void _onLongPressEnd(int index) {
    if (index < 0 || index >= _items.length) return;
    final id = _items[index].id;
    _desiredSpeed[id] = _normalSpeed;
    _applyDesiredSpeed(id);
    if (_longPressVideoId == id) _longPressVideoId = null;
  }

  void _preload(int index) {
    if (index < 0 || index >= _items.length) return;
    final key = _items[index].id;
    if (_controllers.containsKey(key)) return;

    final c = VideoPlayerController.networkUrl(Uri.parse(_items[index].url));
    c.initialize().then((_) {
      c.setLooping(true);
      _applyDesiredSpeed(key); // 初始化完成后设置速度
      setState(() {});
    });
    _controllers[key] = c;
  }

  void _disposeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    final key = _items[index].id;
    _controllers.remove(key)?.dispose();
  }

  void _waitForInitAndPlay(int videoId) async {
    // 等待视频初始化完成
    int attempts = 0;

    while (attempts < _maxInitAttempts) {
      final c = _controllers[videoId];
      if (c != null && c.value.isInitialized) {
        // 检查这个视频是否仍然是当前视频，且用户没有主动暂停
        if (_currentIndex < _items.length &&
            _items[_currentIndex].id == videoId &&
            !_userPausedVideos.contains(videoId)) {
          _applyDesiredSpeed(videoId);
          // 初始化完成后优先尝试从后台进度恢复
          final item = _items[_currentIndex];
          await _resumeFromLastPosition(item: item, controller: c);
          setState(() {});
        }
        return;
      }
      await Future.delayed(Duration(milliseconds: _initCheckIntervalMs));
      attempts++;
    }
  }

  void _playAt(int index) {
    if (index < 0 || index >= _items.length) return;

    // 保存上一个视频的进度
    _onVideoChanged(index);

    // 若存在长按中的视频，切页时视为结束：恢复 1 倍速
    if (_longPressVideoId != null) {
      final lp = _longPressVideoId!;
      _desiredSpeed[lp] = _normalSpeed;
      _applyDesiredSpeed(lp);
      _longPressVideoId = null;
    }

    // 暂停上一条
    if (_currentIndex != index && _currentIndex < _items.length) {
      final prevKey = _items[_currentIndex].id;
      _controllers[prevKey]?.pause();
    }

    _currentIndex = index;
    final key = _items[index].id;

    // 切换到新视频时，清除用户暂停状态（自动播放）
    bool wasUserPaused = _userPausedVideos.contains(key);
    _userPausedVideos.remove(key);
    if (wasUserPaused) setState(() {});

    final c = _controllers[key];
    if (c != null && c.value.isInitialized) {
      _applyDesiredSpeed(key); // 应用期望速度

      // 尝试从上次观看位置开始播放
      _resumeFromLastPosition(item: _items[index], controller: c);
    } else {
      _preload(index);
      _waitForInitAndPlay(key);
    }

    _preload(index + 1);
    _disposeAt(index - _disposeBeforeCount);
    if (index >= _items.length - _loadMoreThreshold) _loadMore();
  }

  @override
  void dispose() {
    _progressTimer?.cancel(); // 取消定时器
    _saveCurrentProgress(); // 保存当前进度
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.playerBackground,
      extendBodyBehindAppBar: true, // 沉浸式设计
      body: Stack(
        children: [
          // 主要播放器界面
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (i) => _playAt(i),
            itemCount: _items.length == 0 ? 1 : _items.length,
            itemBuilder: (context, index) {
              if (_items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingLG),
                        decoration: BoxDecoration(
                          color: AppColors.overlayColor(0.3),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryLight,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLG),
                      Text(
                        'loading...',
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodyMedium,
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final item = _items[index];
              final c = _controllers[item.id];
              final isUserPaused = _userPausedVideos.contains(item.id);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _togglePlay(index),
                onLongPressStart: (_) => _onLongPressStart(index),
                onLongPressEnd: (_) => _onLongPressEnd(index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 视频播放器
                    if (c != null && c.value.isInitialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: c.value.size.width,
                          height: c.value.size.height,
                          child: VideoPlayer(c),
                        ),
                      )
                    else
                      Container(
                        color: AppColors.playerBackground,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.spacingLG,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.overlayColor(0.3),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull,
                                  ),
                                ),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryLight,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingLG),
                              Text(
                                'Preparing...',
                                style: AppTextStyles.withColor(
                                  AppTextStyles.bodyMedium,
                                  Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 暂停时的播放按钮
                    if (c != null && c.value.isInitialized && isUserPaused)
                      Center(
                        child: Container(
                          width: _playButtonSize,
                          height: _playButtonSize,
                          decoration: BoxDecoration(
                            color: AppColors.overlayColor(0.8),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: AppShadows.large,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // 视频标题和信息
                    Positioned(
                      left: _titleLeftMargin,
                      bottom: _titleBottomMargin,
                      right: _titleRightMargin,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingMD),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.playerOverlay,
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.title != null && item.title!.isNotEmpty)
                              Text(
                                item.title!,
                                style: AppTextStyles.playerTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (widget.dramaId != null) ...[
                              const SizedBox(height: AppDimensions.spacingXS),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacingSM,
                                  vertical: AppDimensions.spacingXXS,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(
                                    0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusXS,
                                  ),
                                ),
                                child: Text(
                                  'Episode ${_getEpisodeNumber(item) ?? '?'}',
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.labelSmall,
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 返回按钮（仅在从剧集进入时显示）
          if (widget.dramaId != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + _backButtonTopMargin,
              left: _backButtonLeftMargin,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.overlayColor(0.7),
                  borderRadius: BorderRadius.circular(_backButtonRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: AppShadows.medium,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: _backButtonSize,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 启动观看进度保存定时器
  void _startProgressTimer() {
    _progressTimer = Timer.periodic(
      Duration(seconds: _progressSaveInterval),
      (timer) => _saveCurrentProgress(),
    );
  }

  /// 保存当前播放进度
  Future<void> _saveCurrentProgress() async {
    if (!mounted || _items.isEmpty || _currentIndex >= _items.length) return;

    final appState = context.read<AppState>();
    if (!appState.isLoggedIn) return; // 未登录不保存

    // 推荐流（无视频上下文）暂不保存进度，避免产生“无剧集信息”的历史
    if (widget.dramaId == null) return;

    final currentItem = _items[_currentIndex];
    final controller = _controllers[currentItem.id];

    if (controller == null || !controller.value.isInitialized) return;

    final currentPosition = controller.value.position.inSeconds;
    final duration = controller.value.duration.inSeconds;

    // 检查是否需要保存（进度变化足够大，且不是刚开始或快结束）
    if (_shouldSaveProgress(currentItem.id, currentPosition, duration)) {
      await _saveProgress(currentItem, currentPosition);
      _lastSavedProgress[currentItem.id] = currentPosition;
    }
  }

  /// 判断是否应该保存进度
  bool _shouldSaveProgress(int videoId, int currentPosition, int duration) {
    // 视频太短不保存
    if (duration < _minVideoDurationForSave) return false;

    // 刚开始的3秒和最后10秒不保存
    if (currentPosition < _startSaveThreshold ||
        currentPosition > duration - _endSaveThreshold)
      return false;

    // 检查进度变化是否足够大
    final lastSaved = _lastSavedProgress[videoId] ?? 0;
    return (currentPosition - lastSaved).abs() >= _minProgressDiff;
  }

  /// 保存观看进度到服务器
  Future<void> _saveProgress(VideoItem item, int progress) async {
    try {
      final dramaIdStr = widget.dramaId?.toString();
      final episodeNumber = _getEpisodeNumber(item);

      final success = await WatchHistoryService.updateWatchProgress(
        videoId: item.id.toString(),
        dramaId: dramaIdStr,
        episodeNumber: episodeNumber,
        progress: progress,
      );

      if (success) {
        print('保存观看进度成功: 视频${item.id}, 进度${progress}秒');
      }
    } catch (e) {
      print('保存观看进度失败: $e');
    }
  }

  /// 获取集数（如果是剧集播放）
  int? _getEpisodeNumber(VideoItem item) {
    if (widget.dramaId == null) return null;

    // 按在列表中的位置计算集数：从1开始
    final index = _items.indexOf(item);
    if (index >= 0) {
      return index + 1;
    }
    return null;
  }

  /// 视频切换时保存进度
  void _onVideoChanged(int newIndex) {
    // 推荐流（无视频上下文）暂不保存进度，避免产生“无剧集信息”的历史
    if (widget.dramaId == null) return;
    if (_currentIndex >= 0 && _currentIndex < _items.length) {
      // 保存上一个视频的进度
      final previousItem = _items[_currentIndex];
      final previousController = _controllers[previousItem.id];

      if (previousController != null &&
          previousController.value.isInitialized) {
        final position = previousController.value.position.inSeconds;
        if (position > _minPositionForSave) {
          // 播放超过3秒才保存
          _saveProgress(previousItem, position);
        }
      }
    }
  }

  /// 从上次观看位置恢复播放
  Future<void> _resumeFromLastPosition({
    required VideoItem item,
    required VideoPlayerController controller,
  }) async {
    try {
      final appState = context.read<AppState>();
      if (!appState.isLoggedIn) {
        // 未登录直接播放
        controller.play();
        return;
      }

      // 获取上次观看进度
      final lastProgress = await WatchHistoryService.getWatchProgress(
        item.id.toString(),
      );

      final aggressive = widget.dramaId != null && widget.startEpisode != null;
      final minResumeSec = aggressive
          ? _aggressiveMinResumeSeconds
          : _defaultMinResumeSeconds;
      final tailGuardSec = aggressive
          ? _aggressiveTailGuardSeconds
          : _defaultTailGuardSeconds;

      if (lastProgress > minResumeSec) {
        final duration = controller.value.duration.inSeconds;
        if (lastProgress < duration - tailGuardSec) {
          await controller.seekTo(Duration(seconds: lastProgress));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Resumed at ${_formatDuration(lastProgress)}'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.black54,
              ),
            );
          }
        }
      }

      controller.play();
    } catch (e) {
      print('恢复播放进度失败: $e');
      controller.play(); // 失败时正常播放
    }
  }

  /// 格式化时长显示
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
