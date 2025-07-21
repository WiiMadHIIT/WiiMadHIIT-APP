import 'package:flutter/material.dart';
import '../../widgets/floating_logo.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final GlobalKey<ProfileFunctionGridState> _functionGridKey = GlobalKey<ProfileFunctionGridState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用从后台恢复时，重置滑动提示
    if (state == AppLifecycleState.resumed) {
      _functionGridKey.currentState?.resetScrollHint();
    }
  }

  /// 重置滑动提示状态
  void resetScrollHint() {
    _functionGridKey.currentState?.resetScrollHint();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom; //safty安全区高度 
    // final double bottomPadding2 = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight; //safty安全区高度 + 底部tabbar高度
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 背景大图
                //   Image.asset(
                //     'assets/images/profile_bg.jpg',
                //     fit: BoxFit.cover,
                //   ),
                  // 渐变遮罩
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.white.withOpacity(0.85),
                        ],
                        stops: [0, 0.5, 1],
                      ),
                    ),
                  ),
                  // 右上角按钮组
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionButton(
                          icon: Icons.edit,
                          onTap: () {
                            // TODO: 跳转到设置页面
                          },
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.settings,
                          onTap: () {
                            // TODO: 编辑资料
                          },
                        ),
                      ],
                    ),
                  ),
                  // 头像+用户名+运动天数
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 90,
                    child: Column(
                      children: [
                        // 用户头像
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/images/avatar_default.png'),
                        ),
                        const SizedBox(height: 12),
                        // 用户昵称
                        Text('John Doe', // TODO: 替换为真实昵称
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.black, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 用户ID
                        Text('User ID: 123456789',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 10),
                        // 运动天数统计
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatBlock(label: 'Current Streak', value: '36 days'),
                            const SizedBox(width: 18),
                            _StatBlock(label: 'Days This Year', value: '120 days'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 荣誉墙（横向滑动/宫格）
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _HonorWall(),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 40)), // 功能入口区上方间距
          SliverToBoxAdapter(child: _ProfileFunctionGrid(key: _functionGridKey)), // 功能入口区
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey[500],
                labelStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: AppTextStyles.titleMedium,
                tabs: const [
                  Tab(text: 'Challenges'),
                  Tab(text: 'Check-ins'),
                ],
              ),
            ),
          ),
        ],
        body: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: TabBarView(   
            controller: _tabController,
            children: [
              _ChallengeRecordList(),
              _CheckinRecordList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.withOpacity(0.3), // 灰色半透明背景
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.white, // 白色图标
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: Colors.grey[700])),
      ],
    );
  }
}

class _HonorWall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 荣誉墙，全部英文
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _MedalWidget(
                icon: Icons.emoji_events, 
                label: 'Overall Champion', 
                desc: 'HIIT Winner 2023'
              ),
            ),
            Expanded(
              child: _MedalWidget(
                icon: Icons.star, 
                label: 'Best Streak', 
                desc: '60-Day Check-in Streak'
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedalWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  const _MedalWidget({required this.icon, required this.label, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            label, 
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary, 
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        Flexible(
          child: Text(
            desc, 
            style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProfileFunctionGrid extends StatefulWidget {
  const _ProfileFunctionGrid({Key? key}) : super(key: key);
  
  @override
  State<_ProfileFunctionGrid> createState() => ProfileFunctionGridState();
}

class ProfileFunctionGridState extends State<_ProfileFunctionGrid> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showScrollHint = true;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 监听滚动事件
    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_hasScrolled) {
        setState(() {
          _hasScrolled = true;
          _showScrollHint = false;
        });
        _animationController.stop();
      }
    });

    // 延迟显示提示动画
    _startScrollHint();
  }

  /// 开始显示滑动提示
  void _startScrollHint() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _showScrollHint) {
        _animationController.repeat(reverse: true);
      }
    });
  }

  /// 重置滑动提示状态
  void resetScrollHint() {
    setState(() {
      _showScrollHint = true;
      _hasScrolled = false;
    });
    _animationController.stop();
    _startScrollHint();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 功能入口区，全部英文
    final items = [
      {'icon': Icons.card_giftcard, 'label': 'Activate'},
      {'icon': Icons.emoji_events, 'label': 'Rewards'},
      {'icon': Icons.shopping_bag, 'label': 'Gear'},
      {'icon': Icons.bar_chart, 'label': 'Challenges'},
      {'icon': Icons.check_circle, 'label': 'Check-ins'},
      {'icon': Icons.fitness_center, 'label': 'Workouts'},
      {'icon': Icons.analytics, 'label': 'Stats'},
      {'icon': Icons.group, 'label': 'Friends'},
      // 如有更多，继续添加
    ];
    
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Stack(
        children: [
          // 主要内容
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(), // 苹果风格弹性
              child: Row(
                children: [
                  const SizedBox(width: 8), // 首部 padding
                  ...items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        width: 60,// 固定宽度，保证icon对齐
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 40,
                              child: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.10),
                                child: Icon(item['icon'] as IconData, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 32,
                              child: Center(
                                child: Text(
                                  item['label'] as String,
                                  style: AppTextStyles.labelMedium.copyWith(color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(width: 8), // 尾部 padding
                ],
              ),
            ),
          ),
          
          // TikTok风格的滑动提示
          if (_showScrollHint && !_hasScrolled)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_left,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Swipe',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
        ],
      ),
    );
  }
}

class _ChallengeRecordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 比赛记录区，全部英文
    final records = [
      {'index': 1, 'name': 'HIIT 7-Day Challenge', 'rank': '2nd'},
      {'index': 2, 'name': 'Yoga Masters Cup', 'rank': '1st'},
    ];
    return ListView.builder(
      key: const PageStorageKey('challengeList'), // 关键：唯一key
      padding: const EdgeInsets.only(top: 12),
      itemCount: records.length,
      itemBuilder: (context, i) {
        final r = records[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(child: Text('${r['index']}')),
            title: Text(r['name'].toString(), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            trailing: Text(r['rank'].toString(), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          ),
        );
      },
    );
  }
}

class _CheckinRecordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 打卡记录区，全部英文
    final records = [
      {'index': 1, 'name': 'HIIT Pro', 'count': '36th Check-in'},
      {'index': 2, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 3, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 4, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 5, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 6, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 7, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 8, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 9, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 10, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 11, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 12, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 13, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 14, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 15, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 16, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 17, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 18, 'name': 'Yoga Flex', 'count': '20th Check-in'},
      {'index': 19, 'name': 'Yoga Flex', 'count': '20th Check-in'},
    ];
    return ListView.builder(
      key: const PageStorageKey('checkinList'), // 关键：唯一key
      padding: const EdgeInsets.only(top: 12),
      itemCount: records.length,
      itemBuilder: (context, i) {
        final r = records[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(child: Text('${r['index']}')),
            title: Text(r['name'].toString(), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            trailing: Text(r['count'].toString(), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // 保证吸顶时背景不穿透
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
