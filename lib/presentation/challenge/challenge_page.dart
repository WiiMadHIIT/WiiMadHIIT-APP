// 引入所需的包
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import '../../routes/app_routes.dart';

/// PK状态枚举
enum PKStatus {
  ongoing,    // 进行中
  ended,      // 已结束
  upcoming    // 即将开始
}

/// PK项数据模型
class PKItem {
  final String name;           // PK名称
  final String reward;         // PK奖励
  final DateTime endDate;      // 结束日期
  final PKStatus status;       // PK状态
  final String iconAsset;      // 图标资源路径
  final String routeName;      // 跳转路由
  final String? videoAsset;    // 视频资源路径，可选
  final int? participants;     // 参与人数（可选）
  final String? description;   // 描述（可选）

  PKItem({
    required this.name,
    required this.reward,
    required this.endDate,
    required this.status,
    required this.iconAsset,
    required this.routeName,
    this.videoAsset,
    this.participants,
    this.description,
  });
}

/// 挑战主页面，包含顶部LOGO、视频背景、底部滑动卡片等
class ChallengePage extends StatefulWidget {
  const ChallengePage({Key? key}) : super(key: key);

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> with SingleTickerProviderStateMixin {
  late InfiniteScrollController _carouselController; // 无限轮播控制器
  late final PageController _pageController = PageController(viewportFraction: 0.78); // 卡片滑动控制器
  int _currentIndex = 0; // 当前选中的卡片索引
  late final List<VideoPlayerController> _videoControllers; // 视频控制器列表

  /// PK列表（模拟数据，可根据实际需求扩展）
  final List<PKItem> pkList = [
    PKItem(
      name: "7-Day HIIT Challenge",
      reward: "🏆 冠军奖金 ¥1000",
      endDate: DateTime.now().add(const Duration(days: 3)),
      status: PKStatus.ongoing,
      iconAsset: "assets/icons/hiit.svg",
      routeName: AppRoutes.challengeDetails,
      videoAsset: "assets/video/video1.mp4",
      participants: 128,
      description: "高强度间歇训练挑战",
    ),
    PKItem(
      name: "Yoga Master Battle",
      reward: "🥇 金牌证书 + 专属徽章",
      endDate: DateTime.now().subtract(const Duration(days: 2)),
      status: PKStatus.ended,
      iconAsset: "assets/icons/yoga.svg",
      routeName: AppRoutes.challengeDetails,
      videoAsset: "assets/video/video2.mp4",
      participants: 89,
      description: "瑜伽大师对决",
    ),
    PKItem(
      name: "Strength Warriors",
      reward: "💪 力量之王称号",
      endDate: DateTime.now().add(const Duration(days: 7)),
      status: PKStatus.upcoming,
      iconAsset: "assets/icons/hiit.svg",
      routeName: AppRoutes.challengeDetails,
      videoAsset: "assets/video/video3.mp4",
      participants: 0,
      description: "力量训练挑战赛",
    ),
    PKItem(
      name: "Endurance Marathon",
      reward: "🏃 耐力之王 + 现金奖励",
      endDate: DateTime.now().add(const Duration(hours: 12)),
      status: PKStatus.ongoing,
      iconAsset: "assets/icons/hiit.svg",
      routeName: AppRoutes.challengeDetails,
      videoAsset: "assets/video/video1.mp4",
      participants: 256,
      description: "马拉松耐力挑战",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = InfiniteScrollController(initialItem: 0);
    // 初始化每个PK项的视频控制器
    _videoControllers = List.generate(pkList.length, (i) {
      final asset = (pkList[i].videoAsset == null || pkList[i].videoAsset!.isEmpty)
          ? 'assets/video/video1.mp4'
          : pkList[i].videoAsset!;
      final controller = VideoPlayerController.asset(asset)
        ..setLooping(true)
        ..setVolume(0);
      controller.initialize().then((_) {
        if (i == 0) {
          controller.play();
        }
        if (mounted) setState(() {});
      });
      return controller;
    });
  }

  @override
  void dispose() {
    // 释放所有视频控制器资源
    for (final c in _videoControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  /// 点击PK卡片时的跳转逻辑
  void _onPKTap(PKItem pk) {
    Navigator.pushNamed(context, pk.routeName);
  }

  /// 滑动卡片时切换视频播放
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    for (int i = 0; i < _videoControllers.length; i++) {
      if (i == index) {
        _videoControllers[i].play();
      } else {
        _videoControllers[i].pause();
      }
    }
  }

  /// 构建视频背景层，支持滑动切换时的动画和懒加载
  Widget _buildVideoStack() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final page = _pageController.hasClients && _pageController.page != null
            ? _pageController.page!
            : _currentIndex.toDouble();

        List<Widget> stack = [];
        bool hasInitialized = false;
        for (int i = 0; i < pkList.length; i++) {
          // 只渲染前后1页，提升性能
          if ((i - page).abs() > 1.2) continue;
          final offset = (i - page) * MediaQuery.of(context).size.height;
          final opacity = (1.0 - (i - page).abs()).clamp(0.0, 1.0);

          if (_videoControllers[i].value.isInitialized) hasInitialized = true;

          stack.add(
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Opacity(
                  opacity: opacity,
                  child: _videoControllers[i].value.isInitialized
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoControllers[i].value.size.width,
                            height: _videoControllers[i].value.size.height,
                            child: VideoPlayer(_videoControllers[i]),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          );
        }
        // 如果所有视频都没初始化，显示默认视频
        if (!hasInitialized) {
          stack.add(
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: VideoPlayer(
                    VideoPlayerController.asset('assets/video/video1.mp4')
                      ..setLooping(true)
                      ..setVolume(0)
                      ..initialize(),
                  ),
                ),
              ),
            ),
          );
        }
        return Stack(children: stack);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 全屏视频背景
          Positioned.fill(
            child: _buildVideoStack(),
          ),
          // 顶部毛玻璃渐变遮罩
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.22),
                    Color.fromRGBO(0, 0, 0, 0.10),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // 顶部悬浮LOGO
          Positioned(
            top: MediaQuery.of(context).padding.top + 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.40),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.25),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withOpacity(0.18), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.35),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: SvgPicture.asset(
                          'assets/icons/wiimadhiit-w-red.svg',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'WiiMadHIIT',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 底部滑动卡片区
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 220, // 增加高度以适应新的卡片设计
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pkList.length,
                      physics: const PageScrollPhysics(),
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return AnimatedScale(
                          scale: _currentIndex == index ? 1.0 : 0.92,
                          duration: const Duration(milliseconds: 300),
                          child: _PKEntry(
                            pk: pkList[index],
                            onTap: () => _onPKTap(pkList[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 底部指示器
                  AnimatedSmoothIndicator(
                    activeIndex: _currentIndex,
                    count: pkList.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.primary,
                      dotColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 无PK时的提示语
          if (pkList.isEmpty)
            Center(
              child: Text(
                "No PK challenges available!",
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 按压动效组件，点击时有缩放反馈
class PowerfulTapEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;
  final Duration pressDuration;
  final Duration reboundDuration;
  final Curve reboundCurve;

  const PowerfulTapEffect({
    required this.child,
    required this.onTap,
    this.pressedScale = 0.90,
    this.pressDuration = const Duration(milliseconds: 80),
    this.reboundDuration = const Duration(milliseconds: 320),
    this.reboundCurve = Curves.elasticOut,
    Key? key,
  }) : super(key: key);

  @override
  State<PowerfulTapEffect> createState() => _PowerfulTapEffectState();
}

class _PowerfulTapEffectState extends State<PowerfulTapEffect> {
  double _scale = 1.0;
  bool _isAnimating = false;

  Future<void> _handleTap() async {
    if (_isAnimating) return;
    setState(() {
      _scale = widget.pressedScale;
      _isAnimating = true;
    });
    await Future.delayed(widget.pressDuration);
    setState(() {
      _scale = 1.0;
    });
    await Future.delayed(widget.reboundDuration);
    widget.onTap();
    setState(() {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        scale: _scale,
        duration: _scale < 1.0 ? widget.pressDuration : widget.reboundDuration,
        curve: _scale < 1.0 ? Curves.easeIn : widget.reboundCurve,
        child: widget.child,
      ),
    );
  }
}

/// 单个PK卡片组件，根据不同状态显示不同样式
class _PKEntry extends StatefulWidget {
  final PKItem pk;
  final VoidCallback onTap;

  const _PKEntry({required this.pk, required this.onTap});

  @override
  State<_PKEntry> createState() => _PKEntryState();
}

class _PKEntryState extends State<_PKEntry> {
  double _scale = 1.0;

  void _onTap() {
    setState(() => _scale = 0.97);
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() => _scale = 1.0);
      widget.onTap();
    });
  }

  /// 获取状态对应的颜色主题
  Color _getStatusColor() {
    switch (widget.pk.status) {
      case PKStatus.ongoing:
        return const Color(0xFF00C851); // 绿色 - 进行中
      case PKStatus.ended:
        return const Color(0xFF6C757D); // 灰色 - 已结束
      case PKStatus.upcoming:
        return const Color(0xFFFF6B35); // 橙色 - 即将开始
    }
  }

  /// 获取状态对应的标签文本
  String _getStatusText() {
    switch (widget.pk.status) {
      case PKStatus.ongoing:
        return '进行中';
      case PKStatus.ended:
        return '已结束';
      case PKStatus.upcoming:
        return '即将开始';
    }
  }

  /// 获取状态对应的按钮文本
  String _getButtonText() {
    switch (widget.pk.status) {
      case PKStatus.ongoing:
        return '立即加入';
      case PKStatus.ended:
        return '查看结果';
      case PKStatus.upcoming:
        return '查看介绍';
    }
  }

  /// 获取状态对应的按钮图标
  IconData _getButtonIcon() {
    switch (widget.pk.status) {
      case PKStatus.ongoing:
        return Icons.flash_on;
      case PKStatus.ended:
        return Icons.emoji_events;
      case PKStatus.upcoming:
        return Icons.info_outline;
    }
  }

  /// 格式化剩余时间
  String _formatTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.pk.endDate.difference(now);
    
    if (difference.isNegative) {
      return '已结束';
    }
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天${difference.inHours % 24}小时';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时${difference.inMinutes % 60}分钟';
    } else {
      return '${difference.inMinutes}分钟';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: PowerfulTapEffect(
        onTap: _onTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            splashColor: statusColor.withOpacity(0.08),
            highlightColor: statusColor.withOpacity(0.10),
            onTap: _onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: statusColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部状态栏
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusText(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // 参与人数
                      if (widget.pk.participants != null && widget.pk.participants! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.pk.participants}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // PK名称
                  Text(
                    widget.pk.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 奖励信息
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.1),
                          statusColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.pk.reward,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 底部信息栏
                  Row(
                    children: [
                      // 结束时间
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimeRemaining(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // 操作按钮
                      PowerfulTapEffect(
                        onTap: widget.onTap,
                        pressedScale: 0.90,
                        pressDuration: Duration(milliseconds: 80),
                        reboundDuration: Duration(milliseconds: 320),
                        reboundCurve: Curves.elasticOut,
                        child: _AnimatedButton(
                          onPressed: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor,
                                  statusColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getButtonIcon(),
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getButtonText(),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 按钮缩放动画组件
class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _AnimatedButton({required this.onPressed, required this.child});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1.0;

  void _onTap() {
    setState(() => _scale = 0.90);
    Future.delayed(const Duration(milliseconds: 80), () {
      setState(() => _scale = 1.0);
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}
