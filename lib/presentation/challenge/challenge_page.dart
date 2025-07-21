// 引入所需的包
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import '../../routes/app_routes.dart';
import '../leaderboard/leaderboard_page.dart';
import '../../widgets/floating_logo.dart';

/// PK status enum
enum PKStatus {
  ongoing,    // Ongoing
  ended,      // Ended
  upcoming    // Upcoming
}

/// PK item data model
class PKItem {
  final String name;           // PK name
  final String reward;         // PK reward
  final DateTime endDate;      // End date
  final String status;         // PK status as string (for backend integration)
  final String iconAsset;      // Icon asset path
  final String routeName;      // Route name
  final String? videoAsset;    // Video asset path (optional)
  final int? participants;     // Number of participants (optional)
  final String? description;   // Description (optional)

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

  /// Map status string to PKStatus enum
  PKStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return PKStatus.ongoing;
      case 'ended':
        return PKStatus.ended;
      case 'upcoming':
        return PKStatus.upcoming;
      default:
        return PKStatus.upcoming;
    }
  }
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

  /// 当前筛选状态，null为全部
  PKStatus? currentFilter;

  /// PK list (sample data for US/English users)
  final List<PKItem> pkList = [
    PKItem(
      name: "7-Day HIIT Showdown 7-Day HIIT Showdown 7-Day HIIT Showdown 7-Day HIIT Showdown",
      reward: "🏆 \$200 Amazon Gift Card Amazon Gift Card Amazon Gift Card Amazon Gift Card",
      endDate: DateTime.now().add(const Duration(days: 3)),
      status: 'ongoing',
      iconAsset: "assets/icons/hiit.svg",
      routeName: AppRoutes.challengeDetails,
      videoAsset: "assets/video/video1.mp4",
      participants: 128,
      description: "Push your limits in this high-intensity interval training battle! Push your limits in this high-intensity interval training battle! Push your limits in this high-intensity interval training battle! Push your limits in this high-intensity interval training battle!",
    ),
    PKItem(
      name: "Yoga Masters Cup",
      reward: "🥇 Gold Medal & Exclusive Badge",
      endDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'ended',
      iconAsset: "assets/icons/yoga.svg",
      routeName: AppRoutes.challengeDetails,
      videoAsset: "assets/video/video2.mp4",
      participants: 89,
      description: "Compete for flexibility and balance in the ultimate yoga challenge.",
    ),
    PKItem(
      name: "Strength Warriors",
      reward: "💪 Champion Title & Gym Gear",
      endDate: DateTime.now().add(const Duration(days: 7)),
      status: 'upcoming',
      iconAsset: "assets/icons/hiit.svg",
      routeName: AppRoutes.challengeDetails,
      videoAsset: "assets/video/video3.mp4",
      participants: 0,
      description: "Show your power in this strength training competition.",
    ),
    PKItem(
      name: "Endurance Marathon",
      reward: "🏃 \$500 Cash Prize",
      endDate: DateTime.now().add(const Duration(hours: 12)),
      status: 'ongoing',
      iconAsset: "assets/icons/hiit.svg",
      routeName: AppRoutes.challengeDetails,
      videoAsset: "assets/video/video1.mp4",
      participants: 256,
      description: "Test your stamina in a marathon-style endurance challenge.",
    ),
  ];

  /// 获取筛选后的PK列表
  List<PKItem> get filteredPkList {
    if (currentFilter == null) return pkList;
    return pkList.where((pk) => pk.statusEnum == currentFilter).toList();
  }

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

  /// 显示底部筛选菜单
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.96),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOption(null, 'All'),
                const SizedBox(height: 8),
                _buildFilterOption(PKStatus.ongoing, 'Ongoing'),
                const SizedBox(height: 8),
                _buildFilterOption(PKStatus.upcoming, 'Upcoming'),
                const SizedBox(height: 8),
                _buildFilterOption(PKStatus.ended, 'Ended'),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建筛选选项
  Widget _buildFilterOption(PKStatus? status, String label) {
    final bool selected = currentFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentFilter = status;
          _currentIndex = 0;
        });
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              status == null
                ? Icons.all_inclusive
                : status == PKStatus.ongoing
                  ? Icons.flash_on
                  : status == PKStatus.upcoming
                    ? Icons.schedule
                    : Icons.emoji_events,
              color: selected ? AppColors.primary : Colors.grey[500],
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.titleLarge.copyWith(
                color: selected ? AppColors.primary : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (selected)
              const Spacer(),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
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
    final double bottomPadding = MediaQuery.of(context).padding.bottom; //safty安全区高度 
    // final double bottomPadding2 = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight; //safty安全区高度 + 底部tabbar高度
    
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
          const FloatingLogo(),

          // 底部滑动卡片区
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding + 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 240, // 增加高度以适应新的卡片设计
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: filteredPkList.length,
                      physics: const PageScrollPhysics(),
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return AnimatedScale(
                          scale: _currentIndex == index ? 1.0 : 0.92,
                          duration: const Duration(milliseconds: 300),
                          child: _PKEntry(
                            pk: filteredPkList[index],
                            onTap: () => _onPKTap(filteredPkList[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 底部指示器
                  AnimatedSmoothIndicator(
                    activeIndex: _currentIndex,
                    count: filteredPkList.length,
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
          // 悬浮筛选按钮和排行榜按钮（TikTok风格，卡片区和TabBar之间右下角，水平排列）
          Positioned(
            right: 16,
            bottom: bottomPadding + 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LeaderboardFab(onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaderboardPage()),
                  );
                }),
                const SizedBox(width: 16),
                _FilterFab(onTap: _showFilterSheet, currentFilter: currentFilter),
              ],
            ),
          ),
          // 无PK时的提示语
          if (filteredPkList.isEmpty)
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

/// TikTok风格悬浮筛选按钮
class _FilterFab extends StatelessWidget {
  final VoidCallback onTap;
  final PKStatus? currentFilter;
  const _FilterFab({required this.onTap, required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              'Filter',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
            ),
            if (currentFilter != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.circle,
                  color: AppColors.primary,
                  size: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 新增排行榜按钮组件
class _LeaderboardFab extends StatelessWidget {
  final VoidCallback onTap;
  const _LeaderboardFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.leaderboard,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              'Rank',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
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

  /// Get status color
  Color _getStatusColor() {
    switch (widget.pk.statusEnum) {
      case PKStatus.ongoing:
        return const Color(0xFF00C851); // Green - Ongoing
      case PKStatus.ended:
        return const Color(0xFF6C757D); // Gray - Ended
      case PKStatus.upcoming:
        return const Color(0xFFFF6B35); // Orange - Upcoming
    }
  }

  /// Get status label (English)
  String _getStatusText() {
    switch (widget.pk.statusEnum) {
      case PKStatus.ongoing:
        return 'Ongoing';
      case PKStatus.ended:
        return 'Ended';
      case PKStatus.upcoming:
        return 'Upcoming';
    }
  }

  /// Get button text (English)
  String _getButtonText() {
    switch (widget.pk.statusEnum) {
      case PKStatus.ongoing:
        return 'Join Now';
      case PKStatus.ended:
        return 'Results';
      case PKStatus.upcoming:
        return 'Reserve';
    }
  }

  /// Get status button icon
  IconData _getButtonIcon() {
    switch (widget.pk.statusEnum) {
      case PKStatus.ongoing:
        return Icons.flash_on;
      case PKStatus.ended:
        return Icons.emoji_events;
      case PKStatus.upcoming:
        return Icons.info_outline;
    }
  }

  /// Format time remaining (English)
  String _formatTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.pk.endDate.difference(now);
    
    if (difference.isNegative) {
      return 'Ended';
    }
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    } else {
      return '${difference.inMinutes}m left';
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
                  // Top status bar
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
                      // Participants or Reservations
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
                                widget.pk.statusEnum == PKStatus.upcoming
                                  ? '${widget.pk.participants} reservations'
                                  : '${widget.pk.participants} joined',
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
                  
                  // PK name
                  Text(
                    widget.pk.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Reward info
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
                            maxLines: 1,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // description info
                  if (widget.pk.description != null && widget.pk.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                      child: Text(
                        widget.pk.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Bottom info bar
                  Row(
                    children: [
                      // End time
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
                              Flexible(
                                child: Text(
                                  _formatTimeRemaining(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Action button
                      Flexible(
                        child: PowerfulTapEffect(
                          onTap: widget.onTap,
                          pressedScale: 0.90,
                          pressDuration: Duration(milliseconds: 80),
                          reboundDuration: Duration(milliseconds: 320),
                          reboundCurve: Curves.elasticOut,
                          child: _AnimatedButton(
                            onPressed: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _getButtonText(),
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
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
