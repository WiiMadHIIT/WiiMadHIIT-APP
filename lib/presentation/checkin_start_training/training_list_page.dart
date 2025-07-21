import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'dart:ui';
import 'dart:convert';

class TrainingListPage extends StatefulWidget {
  final String? configJson; // 可选的JSON配置字符串
  final String? configAssetPath; // 可选的配置文件路径
  final String? productId; // 产品ID，用于加载对应配置
  
  const TrainingListPage({
    Key? key,
    this.configJson,
    this.configAssetPath,
    this.productId,
  }) : super(key: key);

  @override
  State<TrainingListPage> createState() => _TrainingListPageState();
}

class _TrainingListPageState extends State<TrainingListPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;
  bool _isVideoInitialized = false;
  
  // 动态配置数据
  late TrainingPageConfig _config;
  bool _isConfigLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    
    // 加载配置
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      if (widget.configJson != null) {
        // 从传入的JSON字符串加载
        _config = TrainingPageConfig.fromJson(jsonDecode(widget.configJson!));
      } else if (widget.configAssetPath != null) {
        // 从资源文件加载
        final jsonString = await DefaultAssetBundle.of(context).loadString(widget.configAssetPath!);
        _config = TrainingPageConfig.fromJson(jsonDecode(jsonString));
      } else if (widget.productId != null) {
        // 根据产品ID加载对应配置
        _config = _getConfigByProductId(widget.productId!);
      } else {
        // 没有配置数据，抛出异常
        throw Exception('No configuration provided');
      }
      
      setState(() {
        _isConfigLoaded = true;
      });
      
      // 初始化视频
      _initializeVideo();
    } catch (e) {
      print('Error loading config: $e');
      // 不设置默认配置，保持加载状态
      setState(() {
        _isConfigLoaded = false;
      });
    }
  }

  // 根据产品ID获取对应配置（模拟数据，后续可替换为API调用）
  TrainingPageConfig _getConfigByProductId(String productId) {
    switch (productId) {
      case 'hiit_pro':
        return TrainingPageConfig(
          videoPath: 'assets/video/video1.mp4',
          fallbackImagePath: 'assets/images/player_cover.png',
          pageTitle: 'HIIT Pro Training',
          pageSubtitle: 'High-intensity interval training for maximum results',
          trainings: [
            PersonalTraining(
              id: '1',
              name: 'HIIT Beginner',
              type: 'Interval',
              intensity: '70 BPM',
              duration: '10 min',
              level: 'Beginner',
              description: 'Perfect introduction to HIIT training',
            ),
            PersonalTraining(
              id: '2',
              name: 'HIIT Intermediate',
              type: 'Tabata',
              intensity: '85 BPM',
              duration: '15 min',
              level: 'Intermediate',
              description: 'Classic Tabata protocol for maximum fat burn',
            ),
            PersonalTraining(
              id: '3',
              name: 'HIIT Advanced',
              type: 'Pyramid',
              intensity: '100 BPM',
              duration: '20 min',
              level: 'Advanced',
              description: 'Pyramid intervals for elite athletes',
            ),
          ],
        );
      
      case 'yoga_flex':
        return TrainingPageConfig(
          videoPath: 'assets/video/video2.mp4',
          fallbackImagePath: 'assets/images/player_cover.png',
          pageTitle: 'Yoga Flex Training',
          pageSubtitle: 'Find your inner peace and flexibility',
          trainings: [
            PersonalTraining(
              id: '4',
              name: 'Yoga Basics',
              type: 'Flow',
              intensity: '60 BPM',
              duration: '15 min',
              level: 'Beginner',
              description: 'Gentle yoga flow for beginners',
            ),
            PersonalTraining(
              id: '5',
              name: 'Power Yoga',
              type: 'Vinyasa',
              intensity: '75 BPM',
              duration: '25 min',
              level: 'Intermediate',
              description: 'Dynamic vinyasa flow for strength building',
            ),
            PersonalTraining(
              id: '6',
              name: 'Advanced Asanas',
              type: 'Hatha',
              intensity: '50 BPM',
              duration: '30 min',
              level: 'Advanced',
              description: 'Advanced poses for experienced practitioners',
            ),
          ],
        );
      
      case 'strength_training':
        return TrainingPageConfig(
          videoPath: 'assets/video/video3.mp4',
          fallbackImagePath: 'assets/images/player_cover.png',
          pageTitle: 'Strength Training',
          pageSubtitle: 'Transform your body with power training',
          trainings: [
            PersonalTraining(
              id: '7',
              name: 'Bodyweight Basics',
              type: 'Circuit',
              intensity: '65 BPM',
              duration: '12 min',
              level: 'Beginner',
              description: 'Bodyweight exercises for beginners',
            ),
            PersonalTraining(
              id: '8',
              name: 'Muscle Builder',
              type: 'Progressive',
              intensity: '80 BPM',
              duration: '18 min',
              level: 'Intermediate',
              description: 'Progressive overload for muscle growth',
            ),
            PersonalTraining(
              id: '9',
              name: 'Power Lifting',
              type: 'Heavy',
              intensity: '90 BPM',
              duration: '25 min',
              level: 'Advanced',
              description: 'Heavy compound movements for strength',
            ),
          ],
        );
      
      case 'cardio_blast':
        return TrainingPageConfig(
          videoPath: 'assets/video/video1.mp4',
          fallbackImagePath: 'assets/images/player_cover.png',
          pageTitle: 'Cardio Training',
          pageSubtitle: 'Boost your cardiovascular fitness',
          trainings: [
            PersonalTraining(
              id: '10',
              name: 'Cardio Warm-up',
              type: 'Steady',
              intensity: '70 BPM',
              duration: '8 min',
              level: 'Beginner',
              description: 'Gentle cardio warm-up session',
            ),
            PersonalTraining(
              id: '11',
              name: 'Cardio Burn',
              type: 'Interval',
              intensity: '95 BPM',
              duration: '15 min',
              level: 'Intermediate',
              description: 'High-intensity cardio intervals',
            ),
            PersonalTraining(
              id: '12',
              name: 'Cardio Extreme',
              type: 'Sprint',
              intensity: '110 BPM',
              duration: '20 min',
              level: 'Advanced',
              description: 'Extreme cardio challenge for endurance',
            ),
          ],
        );
      
      default:
        throw Exception('Unknown product ID: $productId');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConfigLoaded) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No training data available',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your configuration',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // 顶部视频介绍区域
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildVideoSection(),
            ),
          ),
          
          // 项目列表标题
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _config.pageTitle,
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _config.pageSubtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 训练项目列表
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _TrainingCard(
                    training: _config.trainings[index],
                    levelColor: _getLevelColor(_config.trainings[index].level),
                    onTap: () => _onTrainingTap(_config.trainings[index]),
                  );
                },
                childCount: _config.trainings.length,
              ),
            ),
          ),

          // 底部间距
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.4),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频背景
          _isVideoInitialized && _videoController != null
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                      image: _config.fallbackImagePath.startsWith('http://') || _config.fallbackImagePath.startsWith('https://')
                          ? NetworkImage(_config.fallbackImagePath)
                          : AssetImage(_config.fallbackImagePath) as ImageProvider,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
          
          // 视频渐变覆盖层
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: _isVideoPlaying && _isVideoInitialized
                ? GestureDetector(
                    onTap: _toggleVideo,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  )
                : null,
          ),
          
          // 播放按钮
          if (!_isVideoPlaying || !_isVideoInitialized)
            Center(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: _isVideoInitialized ? _toggleVideo : null,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _isVideoInitialized
                              ? Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // 视频标题
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Text(
              'Must-see before workout',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initializeVideo() {
    // 判断是本地资源还是远程链接
    if (_config.videoPath.startsWith('http://') || _config.videoPath.startsWith('https://')) {
      // 远程视频
      _videoController = VideoPlayerController.networkUrl(Uri.parse(_config.videoPath))
        ..setLooping(true)
        ..setVolume(0.0)
        ..addListener(() {
          if (mounted) {
            setState(() {
              // 同步视频播放状态
              _isVideoPlaying = _videoController!.value.isPlaying;
            });
          }
        })
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        });
    } else {
      // 本地视频
      _videoController = VideoPlayerController.asset(_config.videoPath)
        ..setLooping(true)
        ..setVolume(0.0)
        ..addListener(() {
          if (mounted) {
            setState(() {
              // 同步视频播放状态
              _isVideoPlaying = _videoController!.value.isPlaying;
            });
          }
        })
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        });
    }
  }

  void _toggleVideo() {
    if (_videoController == null || !_isVideoInitialized) return;
    
    setState(() {
      _isVideoPlaying = !_isVideoPlaying;
    });
    
    if (_isVideoPlaying) {
      _videoController!.play();
    } else {
      _videoController!.pause();
    }
  }

  void _onTrainingTap(PersonalTraining training) {
    // 导航到训练规则页面
    Navigator.pushNamed(
      context,
      '/training_rule',
      arguments: {
        'trainingId': training.id,
        'trainingName': training.name,
        'trainingType': training.type,
        'trainingLevel': training.level,
      },
    );
  }

  // 难度等级到颜色的映射
  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// 页面配置数据模型
class TrainingPageConfig {
  final String videoPath;
  final String fallbackImagePath;
  final String pageTitle;
  final String pageSubtitle;
  final List<PersonalTraining> trainings;

  TrainingPageConfig({
    required this.videoPath,
    required this.fallbackImagePath,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.trainings,
  });

  factory TrainingPageConfig.fromJson(Map<String, dynamic> json) {
    return TrainingPageConfig(
      videoPath: json['videoPath'] ?? 'assets/video/video1.mp4',
      fallbackImagePath: json['fallbackImagePath'] ?? 'assets/images/beatx_bg.jpg',
      pageTitle: json['pageTitle'] ?? 'Personal Training',
      pageSubtitle: json['pageSubtitle'] ?? 'Choose your workout',
      trainings: (json['trainings'] as List?)
          ?.map((training) => PersonalTraining.fromJson(training))
          .toList() ?? [],
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'videoPath': videoPath,
      'fallbackImagePath': fallbackImagePath,
      'pageTitle': pageTitle,
      'pageSubtitle': pageSubtitle,
      'trainings': trainings.map((training) => training.toJson()).toList(),
    };
  }
}

// 个人训练数据模型
class PersonalTraining {
  final String id; // 训练ID
  final String name;
  final String type; // 训练类型
  final String intensity; // 强度
  final String duration;
  final String level; // 难度等级
  final String description;

  PersonalTraining({
    required this.id,
    required this.name,
    required this.type,
    required this.intensity,
    required this.duration,
    required this.level,
    required this.description,
  });

  factory PersonalTraining.fromJson(Map<String, dynamic> json) {
    return PersonalTraining(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      intensity: json['intensity'] ?? '',
      duration: json['duration'] ?? '',
      level: json['level'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'intensity': intensity,
      'duration': duration,
      'level': level,
      'description': description,
    };
  }
}

// 训练卡片组件
class _TrainingCard extends StatelessWidget {
  final PersonalTraining training;
  final Color levelColor;
  final VoidCallback onTap;

  const _TrainingCard({
    required this.training,
    required this.levelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
                          border: Border.all(
              color: levelColor.withOpacity(0.1),
              width: 1,
            ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题和难度
                      Row(
                        children: [
                          Expanded(
                            child:                             Text(
                              training.name,
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              training.level,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: levelColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 训练类型、强度和时长
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.fitness_center,
                            label: training.type,
                            color: levelColor,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.speed,
                            label: training.intensity,
                            color: levelColor,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.timer,
                            label: training.duration,
                            color: levelColor,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 描述
                      Text(
                        training.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 开始按钮
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              levelColor,
                              levelColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: levelColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Start Training',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 信息标签组件
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
