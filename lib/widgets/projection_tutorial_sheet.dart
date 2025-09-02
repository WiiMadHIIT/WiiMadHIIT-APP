import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';

class ProjectionTutorialSheet extends StatefulWidget {
  const ProjectionTutorialSheet({Key? key}) : super(key: key);

  @override
  State<ProjectionTutorialSheet> createState() => _ProjectionTutorialSheetState();
}

class _ProjectionTutorialSheetState extends State<ProjectionTutorialSheet> 
    with TickerProviderStateMixin {
  bool _isVideoPlaying = false;
  bool _isVideoExpanded = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoLoading = false;
  bool _isVideoReady = false;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // 内部伪数据
  final Map<String, dynamic> _videoInfo = {
    "videoUrl": "assets/video/projection_tutorials_mac.mp4",
    "title": "Watch Video Tutorial",
  };

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      "number": 1,
      "title": "Open Training/Challenge Module",
      "description": "Navigate to the training or challenge section in your app.",
      "icon": Icons.wallpaper,
    },
    {
      "number": 2,
      "title": "Enable Auto-Rotate",
      "description": "Activate screen rotation in Control Center.",
      "icon": Icons.phone_android,
    },
    {
      "number": 3,
      "title": "Start Mirroring",
      "description": "In Control Center, select your Mac under Screen Mirroring.",
      "icon": Icons.cast_connected,
    },
    {
      "number": 4,
      "title": "Rotate to Landscape",
      "description": "Turn iPhone sideways for landscape view on both screens.",
      "icon": Icons.tune,
    },
    {
      "number": 5,
      "title": "Return to Portrait",
      "description": "Rotate back vertically for portrait mode controls.",
      "icon": Icons.play_circle,
    },
    {
      "number": 6,
      "title": "Stop Mirroring",
      "description": "Disconnect via Control Center when finished.",
      "icon": Icons.play_circle,
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    // 🎯 正确释放视频控制器和监听器
    if (_videoController != null) {
      _videoController!.removeListener(_onVideoStateChanged);
      _videoController!.dispose();
      _videoController = null;
    }
    
    // 🎯 释放动画控制器
    _scaleController.dispose();
    _fadeController.dispose();
    
    super.dispose();
  }
  
  /// 🎯 视频状态变化监听器
  void _onVideoStateChanged() {
    if (mounted && _videoController != null) {
      setState(() {
        _isVideoPlaying = _videoController!.value.isPlaying;
      });
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // 创建本地视频控制器
      _videoController = VideoPlayerController.asset('assets/video/projection_tutorials_mac.mp4');
      await _videoController!.initialize();
      
      // 🎯 添加监听器来更新播放状态
      _videoController!.addListener(_onVideoStateChanged);
      
      // 设置循环播放
      _videoController!.setLooping(true);
      setState(() {
        _isVideoInitialized = true;
        _isVideoLoading = false;
        _isVideoReady = true;
      });
      
      // 启动淡入动画
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isVideoLoading = false;
      });
    }
  }



  double _getVideoProgress() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return 0.0;
    }
    final duration = _videoController!.value.duration;
    final position = _videoController!.value.position;
    return duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;
  }

  Map<String, double> _calculateVideoDimensions({
    required double maxWidth,
    required double maxHeight,
    double? customAspectRatio,
  }) {
    double videoAspectRatio = customAspectRatio ?? 16 / 9;
    if (_videoController != null && _videoController!.value.isInitialized) {
      videoAspectRatio = _videoController!.value.aspectRatio;
    }
    double videoWidth = maxWidth;
    double videoHeight = videoWidth / videoAspectRatio;
    if (videoHeight > maxHeight) {
      videoHeight = maxHeight;
      videoWidth = videoHeight * videoAspectRatio;
    }
    return {
      'width': videoWidth,
      'height': videoHeight,
    };
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // 共享的播放/暂停控制方法
  void _togglePlayPause() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }
    
    HapticFeedback.selectionClick();
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    // 状态会通过监听器自动更新
  }

  void _showFullscreenVideo() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenVideoPage(
          videoController: _videoController!,
          videoInfo: _videoInfo,
          getVideoProgress: _getVideoProgress,
          formatDuration: _formatDuration,
          togglePlayPause: _togglePlayPause,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cast,
                    color: const Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Projection Tutorial',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 内容区：视频卡片+教程步骤一起滚动
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoTutorialSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._tutorialSteps.map((step) => _buildTutorialStep(
                          number: step["number"],
                          title: step["title"],
                          description: step["description"],
                          icon: step["icon"],
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // 关闭按钮
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Got it',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTutorialSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _scaleController.reverse(),
            onTapCancel: () => _scaleController.reverse(),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isVideoExpanded = !_isVideoExpanded;
              });
            },
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.97),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black.withOpacity(0.03),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _videoInfo["title"] ?? 'Watch Video Tutorial',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                          fontSize: 16,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isVideoExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFFB0B0B0),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            height: _isVideoExpanded ? 180 : 0,
            margin: EdgeInsets.only(top: _isVideoExpanded ? 10 : 0),
            child: _isVideoExpanded
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildVideoPlayer(),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double maxHeight = 180.0;
        bool isSmallScreen = maxWidth < 350;
        Map<String, double> dimensions = _calculateVideoDimensions(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
        double videoWidth = dimensions['width']!;
        double videoHeight = dimensions['height']!;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (_isVideoInitialized && _videoController != null)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: SizedBox(
                        width: videoWidth,
                        height: videoHeight,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF2D2D2D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isVideoLoading)
                          Container(
                            width: isSmallScreen ? 40 : 48,
                            height: isSmallScreen ? 40 : 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: isSmallScreen ? 20 : 24,
                                height: isSmallScreen ? 20 : 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: isSmallScreen ? 40 : 48,
                            height: isSmallScreen ? 40 : 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.white.withOpacity(0.6),
                              size: isSmallScreen ? 20 : 24,
                            ),
                          ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          _isVideoLoading ? 'Preparing video...' : 'Video unavailable',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                        if (_isVideoReady && !_isVideoLoading)
                          Padding(
                            padding: EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                            child: Text(
                              'Tap to play',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                                fontSize: isSmallScreen ? 10 : 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (_isVideoInitialized)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_isVideoPlaying ? 0.2 : 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                        color: _isVideoPlaying ? Colors.white : Colors.black,
                        size: isSmallScreen ? 28 : 36,
                      ),
                    ),
                  ),
                ),
              if (_isVideoInitialized && _videoController != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: isSmallScreen ? 2 : 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 1 : 1.5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _getVideoProgress(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isSmallScreen ? 1 : 1.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 8, 
                                vertical: isSmallScreen ? 3 : 4
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 6),
                              ),
                              child: Text(
                                _formatDuration(_videoController!.value.position),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: isSmallScreen ? 10 : 11,
                                ),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Text(
                              '/',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: isSmallScreen ? 10 : 11,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Text(
                              _formatDuration(_videoController!.value.duration),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: isSmallScreen ? 10 : 11,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                _showFullscreenVideo();
                              },
                              child: Container(
                                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 6),
                                ),
                                child: Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: isSmallScreen ? 16 : 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTutorialStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 全屏视频播放页面
class _FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController videoController;
  final Map<String, dynamic> videoInfo;
  final double Function() getVideoProgress;
  final String Function(Duration) formatDuration;
  final VoidCallback togglePlayPause;

  const _FullscreenVideoPage({
    Key? key,
    required this.videoController,
    required this.videoInfo,
    required this.getVideoProgress,
    required this.formatDuration,
    required this.togglePlayPause,
  }) : super(key: key);

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    // 🎯 初始化播放状态
    _isVideoPlaying = widget.videoController.value.isPlaying;
    // 🎯 添加监听器来更新播放状态
    widget.videoController.addListener(_onVideoStateChanged);
  }

  @override
  void dispose() {
    // 🎯 确保移除监听器，避免内存泄漏
    try {
      widget.videoController.removeListener(_onVideoStateChanged);
    } catch (e) {
      // 忽略可能的错误，确保 dispose 正常完成
      print('Warning: Error removing video listener: $e');
    }
    super.dispose();
  }

  void _onVideoStateChanged() {
    if (mounted) {
      setState(() {
        _isVideoPlaying = widget.videoController.value.isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 全屏视频播放器
            Center(
              child: AspectRatio(
                aspectRatio: widget.videoController.value.aspectRatio,
                child: VideoPlayer(widget.videoController),
              ),
            ),
            // 顶部控制栏
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.videoInfo['title'] ?? 'Video Tutorial',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 中间播放/暂停按钮（模仿小屏幕风格）
            Center(
              child: GestureDetector(
                onTap: widget.togglePlayPause,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_isVideoPlaying ? 0.2 : 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                    color: _isVideoPlaying ? Colors.white : Colors.black,
                    size: 36,
                  ),
                ),
              ),
            ),
            // 底部控制栏
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 进度条
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.getVideoProgress(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 时间显示
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.formatDuration(widget.videoController.value.position)} / ${widget.formatDuration(widget.videoController.value.duration)}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // 退出全屏按钮
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.fullscreen_exit,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 