import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'dart:ui';

// ================== 伪数据 ==================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'dart:ui';

final Map<String, dynamic> fakeTrainingInfo = {
  "name": "Projection Training",
  "type": "General",
  "level": "All Levels",
};

final List<Map<String, dynamic>> fakeTrainingRules = [
  {
    "icon": Icons.settings,
    "title": "Device Setup",
    "description": "Switch to P10 mode and P9 speed for optimal training experience",
    "color": const Color(0xFF10B981),
  },
  {
    "icon": Icons.timer,
    "title": "System Calibration",
    "description": "Wait 3 seconds after adjustment for system to respond",
    "color": const Color(0xFFF59E0B),
  },
  {
    "icon": Icons.check_circle,
    "title": "Ready Check",
    "description": "Ensure you are in a safe environment with proper space",
    "color": const Color(0xFFEF4444),
  },
];

final Map<String, dynamic> fakeVideoInfo = {
  "asset": "assets/video/video1.mp4",
  "duration": "2 min",
  "quality": "HD",
  "title": "Watch Video Tutorial",
  "subtitle": "Learn projection setup step by step",
};

final List<Map<String, dynamic>> fakeTutorialSteps = [
  {
    "number": 1,
    "title": "Find a Flat Surface",
    "description": "Choose a wall or flat surface that is at least 2 meters wide and 1.5 meters tall.",
    "icon": Icons.wallpaper,
  },
  {
    "number": 2,
    "title": "Position Your Device",
    "description": "Place your device on a stable surface, approximately 1-2 meters from the projection surface.",
    "icon": Icons.phone_android,
  },
  {
    "number": 3,
    "title": "Enable Projection",
    "description": "Tap the projection button in the training interface to start casting.",
    "icon": Icons.cast_connected,
  },
  {
    "number": 4,
    "title": "Adjust Position",
    "description": "Use the on-screen controls to adjust the projection size and position.",
    "icon": Icons.tune,
  },
  {
    "number": 5,
    "title": "Start Training",
    "description": "Once the projection is properly set up, you can begin your training session.",
    "icon": Icons.play_circle,
  },
];
// ================== 伪数据 END ==================

class TrainingRulePage extends StatefulWidget {
  final String? trainingId;
  final String? trainingName;
  final String? trainingType;
  final String? trainingLevel;
  
  const TrainingRulePage({
    Key? key,
    this.trainingId,
    this.trainingName,
    this.trainingType,
    this.trainingLevel,
  }) : super(key: key);

  @override
  State<TrainingRulePage> createState() => _TrainingRulePageState();

  // 从路由参数创建页面的静态方法
  static TrainingRulePage fromRoute(Map<String, dynamic> arguments) {
    return TrainingRulePage(
      trainingId: arguments['trainingId'] as String?,
      trainingName: arguments['trainingName'] as String?,
      trainingType: arguments['trainingType'] as String?,
      trainingLevel: arguments['trainingLevel'] as String?,
    );
  }
}

class _TrainingRulePageState extends State<TrainingRulePage> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isProjectionTutorialVisible = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // 顶部渐变背景和标题
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: _buildBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderBackground(),
            ),
          ),
          
          // 主要内容
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 训练信息卡片
                      _buildTrainingInfoCard(),
                      const SizedBox(height: 24),
                      
                      // 训练规则卡片
                      _buildTrainingRulesCard(),
                      const SizedBox(height: 24),
                      
                      // 投影教程入口
                      _buildProjectionTutorialCard(),
                      const SizedBox(height: 32),
                      
                      // 开始训练按钮
                      _buildStartTrainingButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 装饰性背景图案
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // 标题内容
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Rules',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get ready for your workout',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fakeTrainingInfo["name"] ?? 'Training',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${fakeTrainingInfo["type"] ?? 'General'} • ${fakeTrainingInfo["level"] ?? 'All Levels'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingRulesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.rule,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Training Rules',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fakeTrainingRules.map((rule) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRuleItem(
              icon: rule["icon"],
              title: rule["title"],
              description: rule["description"],
              color: rule["color"],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
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
    );
  }

  Widget _buildProjectionTutorialCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _showProjectionTutorial,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.cast,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projection Tutorial',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Learn how to project your training to a flat surface',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartTrainingButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _startTraining,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Start Training',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProjectionTutorial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProjectionTutorialSheet(),
    );
  }

  void _startTraining() {
    // TODO: 导航到实际的训练页面
    print('Starting training: ${widget.trainingName ?? 'Training'}');
    
    // 显示确认对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Ready to Start?',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Make sure you have completed all the setup steps and are ready to begin your training session.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 直接跳转到 CheckingTrainingPage 页面，无参数，无SnackBar
              Navigator.pushNamed(
                context,
                '/checking_training',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Start',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionTutorialSheet extends StatefulWidget {
  @override
  State<_ProjectionTutorialSheet> createState() => _ProjectionTutorialSheetState();
}

class _ProjectionTutorialSheetState extends State<_ProjectionTutorialSheet> 
    with TickerProviderStateMixin {
  bool _isVideoPlaying = false;
  bool _isVideoExpanded = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoLoading = true;
  bool _isVideoReady = false;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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
    _videoController?.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isVideoLoading = true;
      });
      
      _videoController = VideoPlayerController.asset('assets/video/video1.mp4');
      await _videoController!.initialize();
      
      // 添加监听器来更新播放状态
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {
            _isVideoPlaying = _videoController!.value.isPlaying;
          });
          
          // 检查视频是否播放完毕
          if (_videoController!.value.position >= _videoController!.value.duration) {
            // 视频播放完毕，可以在这里添加一些逻辑
            print('Video playback completed');
          }
        }
      });
      
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
      print('Error initializing video: $e');
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

  /// 计算视频的最佳显示尺寸
  Map<String, double> _calculateVideoDimensions({
    required double maxWidth,
    required double maxHeight,
    double? customAspectRatio,
  }) {
    // 获取视频的原始长宽比
    double videoAspectRatio = customAspectRatio ?? 16 / 9; // 默认16:9
    if (_videoController != null && _videoController!.value.isInitialized) {
      videoAspectRatio = _videoController!.value.aspectRatio;
    }
    
    // 计算视频在容器中的实际尺寸
    double videoWidth = maxWidth;
    double videoHeight = videoWidth / videoAspectRatio;
    
    // 如果视频高度超过容器高度，则按高度计算
    if (videoHeight > maxHeight) {
      videoHeight = maxHeight;
      videoWidth = videoHeight * videoAspectRatio;
    }
    
    return {
      'width': videoWidth,
      'height': videoHeight,
    };
  }

  /// 判断视频是否为竖屏
  bool _isVideoPortrait() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return false;
    }
    return _videoController!.value.aspectRatio < 1.0;
  }

  /// 获取视频方向描述
  String _getVideoOrientationText() {
    if (_isVideoPortrait()) {
      return 'Portrait';
    } else {
      return 'Landscape';
    }
  }

  /// 获取视频分辨率信息
  String _getVideoResolution() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return 'Unknown';
    }
    
    final size = _videoController!.value.size;
    return '${size.width.toInt()}x${size.height.toInt()}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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
                        ...fakeTutorialSteps.map((step) => _buildTutorialStep(
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
                        fakeVideoInfo["title"] ?? 'Watch Video Tutorial',
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
                    child: _buildVideoPlayer(
                      customMaxHeight: 180,
                      asset: fakeVideoInfo["asset"],
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer({double? customMaxHeight, String? asset}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算最佳视频尺寸
        double maxWidth = constraints.maxWidth;
        double maxHeight = customMaxHeight ?? 220.0; // 固定高度
        
        // 判断是否为小屏幕
        bool isSmallScreen = maxWidth < 350;
        
        Map<String, double> dimensions = _calculateVideoDimensions(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
        
        double videoWidth = dimensions['width']!;
        double videoHeight = dimensions['height']!;
        
        // 只在第一次初始化时设置视频源
        if (_videoController == null && asset != null) {
          _videoController = VideoPlayerController.asset(asset);
          _videoController!.initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
              _isVideoLoading = false;
              _isVideoReady = true;
            });
            _fadeController.forward();
          });
        }
        
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
              // 视频播放器
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
                        // 加载动画
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
                          _isVideoLoading ? 'Loading video...' : 'Video unavailable',
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
              
              // 播放/暂停按钮 - 苹果风格
              if (_isVideoInitialized)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                          _isVideoPlaying = false;
                        } else {
                          _videoController!.play();
                          _isVideoPlaying = true;
                        }
                      });
                    },
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
              
              // 视频信息栏 - 底部
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
                        // 进度条
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
                            // 播放时间
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
                            // 全屏按钮
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                _showVideoPlayer();
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

  void _showVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;
            Map<String, double> dimensions = _calculateVideoDimensions(
              maxWidth: screenWidth,
              maxHeight: screenHeight,
            );
            double videoWidth = dimensions['width']!;
            double videoHeight = dimensions['height']!;

            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // 全屏视频播放器
                      Center(
                        child: SizedBox(
                          width: videoWidth,
                          height: videoHeight,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                      // 播放/暂停按钮
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                                _isVideoPlaying = false;
                              } else {
                                _videoController!.play();
                                _isVideoPlaying = true;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(_isVideoPlaying ? 0.2 : 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                              color: _isVideoPlaying ? Colors.white : Colors.black,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      // 顶部控制栏
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 16,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              // 返回按钮
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Projection Setup Tutorial',
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Learn how to set up projection for optimal training experience',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // 底部控制栏
                      if (_videoController != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 32,
                              top: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 进度条
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _getVideoProgress(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    // 播放时间
                                    Text(
                                      _formatDuration(_videoController!.value.position),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '/',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDuration(_videoController!.value.duration),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                    const Spacer(),
                                    // 画中画按钮
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('画中画功能敬请期待！')),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.picture_in_picture,
                                          color: Colors.white,
                                          size: 20,
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
          },
        ),
      ),
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
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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

  // Apple风格信息chip
  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.85), size: 15),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
