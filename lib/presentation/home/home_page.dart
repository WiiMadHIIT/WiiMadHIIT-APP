import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom; //safty安全区高度 
    // final double bottomPadding2 = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight; //safty安全区高度 + 底部tabbar高度
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // 深色背景，TikTok风格
      body: CustomScrollView(
        slivers: [
          // 顶部欢迎区域 - 更强烈的渐变
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: Colors.black,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                      Colors.black,
                    ],
                    stops: [0, 0.6, 1],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '🔥 TRENDING',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back, John! 👋',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready for today\'s challenge?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 今日数据概览 - 霓虹风格
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    const Color(0xFF1A1A1A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      value: '7',
                      label: 'Day Streak',
                      color: Colors.orange,
                      gradient: [Colors.orange, Colors.red],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.emoji_events,
                      value: '3',
                      label: 'Challenges',
                      color: AppColors.primary,
                      gradient: [AppColors.primary, Colors.purple],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      value: '12',
                      label: 'Check-ins',
                      color: Colors.green,
                      gradient: [Colors.green, Colors.teal],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 最近7天突出比赛结果 - 霓虹卡片
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🏆 Recent Champions',
              subtitle: 'Top performers this week',
              color: Colors.amber,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _ChampionCard(
                    name: 'User ${index + 1}',
                    challenge: 'HIIT Challenge',
                    rank: '${index + 1}',
                    avatar: 'assets/images/avatar_default.png',
                    gradient: [
                      Colors.amber.withOpacity(0.2),
                      Colors.orange.withOpacity(0.2),
                      Colors.red.withOpacity(0.1),
                    ],
                  );
                },
              ),
            ),
          ),

          // 最近7天打卡积极用户 - 霓虹风格
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🔥 Active Users',
              subtitle: 'Most consistent this week',
              color: Colors.red,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return _ActiveUserCard(
                    name: 'User ${index + 1}',
                    streak: '${7 + index}',
                    avatar: 'assets/images/avatar_default.png',
                    gradient: [
                      Colors.red.withOpacity(0.1),
                      Colors.pink.withOpacity(0.1),
                    ],
                  );
                },
              ),
            ),
          ),

          // 装备展示 - 科技感
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '⚡ Your Gear',
              subtitle: 'Track your equipment',
              color: Colors.cyan,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.cyan.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                    Colors.purple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.cyan.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.fitness_center, color: Colors.cyan, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Connected Devices',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _GearItem(
                        icon: Icons.watch,
                        name: 'Smart Watch',
                        status: 'Connected',
                        color: Colors.cyan,
                      ),
                      const SizedBox(width: 16),
                      _GearItem(
                        icon: Icons.phone_android,
                        name: 'Phone',
                        status: 'Connected',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 未来推出计划 - 霓虹橙色
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🚀 Coming Soon',
              subtitle: 'Exciting features ahead',
              color: Colors.orange,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.red.withOpacity(0.1),
                    Colors.pink.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Features',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.group,
                    title: 'Social Challenges',
                    description: 'Compete with friends',
                    date: 'Next Week',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _FeatureItem(
                    icon: Icons.analytics,
                    title: 'Advanced Analytics',
                    description: 'Detailed progress tracking',
                    date: 'Coming Soon',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),

          // 未来推出活动 - 霓虹粉色
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🎯 Upcoming Events',
              subtitle: 'Don\'t miss out',
              color: Colors.pink,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final events = [
                    {'name': 'Summer Fitness', 'date': 'June 15', 'participants': '1.2K'},
                    {'name': 'Yoga Masterclass', 'date': 'June 20', 'participants': '856'},
                    {'name': 'HIIT Marathon', 'date': 'June 25', 'participants': '2.1K'},
                    {'name': 'Wellness Week', 'date': 'July 1', 'participants': '3.5K'},
                  ];
                  return _EventCard(
                    name: events[index]['name']!,
                    date: events[index]['date']!,
                    participants: events[index]['participants']!,
                    gradient: [
                      Colors.pink.withOpacity(0.2),
                      Colors.purple.withOpacity(0.2),
                      Colors.blue.withOpacity(0.1),
                    ],
                  );
                },
              ),
            ),
          ),

          // 使用说明 - 霓虹绿色
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '📖 How to Use',
              subtitle: 'Get started quickly',
              color: Colors.green,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    const Color(0xFF1A1A1A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _GuideItem(
                    step: '1',
                    title: 'Connect Your Device',
                    description: 'Link your smart watch or phone',
                    icon: Icons.bluetooth,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _GuideItem(
                    step: '2',
                    title: 'Join Challenges',
                    description: 'Participate in daily fitness challenges',
                    icon: Icons.emoji_events,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _GuideItem(
                    step: '3',
                    title: 'Track Progress',
                    description: 'Monitor your achievements and streaks',
                    icon: Icons.trending_up,
                    color: Colors.cyan,
                  ),
                ],
              ),
            ),
          ),

          // 网站入口 - 霓虹蓝色
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🌐 Web Portal',
              subtitle: 'Access on desktop',
              color: Colors.blue,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _PortalCard(
                icon: Icons.language,
                title: 'Web Dashboard',
                description: 'Full features on desktop',
                url: 'https://wiimadhiit.com',
                color: Colors.blue,
                gradient: [
                  Colors.blue.withOpacity(0.1),
                  Colors.cyan.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // 社媒入口 - 霓虹紫色
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '📱 Social Media',
              subtitle: 'Connect with us',
              color: Colors.purple,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SocialCard(
                    icon: Icons.camera_alt,
                    title: 'TikTok',
                    description: 'Follow us for fitness tips',
                    handle: '@wiimadhiit',
                    color: Colors.black,
                    gradient: [
                      Colors.black.withOpacity(0.1),
                      Colors.grey.withOpacity(0.1),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SocialCard(
                    icon: Icons.photo_camera,
                    title: 'Instagram',
                    description: 'Daily motivation & updates',
                    handle: '@wiimadhiit',
                    color: Colors.purple,
                    gradient: [
                      Colors.purple.withOpacity(0.1),
                      Colors.pink.withOpacity(0.1),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SocialCard(
                    icon: Icons.share,
                    title: 'YouTube',
                    description: 'Workout tutorials & guides',
                    handle: 'Wiimadhiit Official',
                    color: Colors.red,
                    gradient: [
                      Colors.red.withOpacity(0.1),
                      Colors.orange.withOpacity(0.1),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 底部间距
          SliverToBoxAdapter(
            child: SizedBox(height: bottomPadding + 32),
          ),
        ],
      ),
    );
  }
}

// 统计卡片组件 - 霓虹风格
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final List<Color> gradient;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(
                color: color.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// 冠军卡片组件 - 霓虹风格
class _ChampionCard extends StatelessWidget {
  final String name;
  final String challenge;
  final String rank;
  final String avatar;
  final List<Color> gradient;

  const _ChampionCard({
    required this.name,
    required this.challenge,
    required this.rank,
    required this.avatar,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(avatar),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      challenge,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$rank Place',
              style: AppTextStyles.labelMedium.copyWith(
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

// 活跃用户卡片组件 - 霓虹风格
class _ActiveUserCard extends StatelessWidget {
  final String name;
  final String streak;
  final String avatar;
  final List<Color> gradient;

  const _ActiveUserCard({
    required this.name,
    required this.streak,
    required this.avatar,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(avatar),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$streak days',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// 装备项目组件 - 科技感
class _GearItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String status;
  final Color color;

  const _GearItem({
    required this.icon,
    required this.name,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              const Color(0xFF1A1A1A),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              status,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 功能项目组件 - 霓虹风格
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String date;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: 20),
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
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            date,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// 活动卡片组件 - 霓虹风格
class _EventCard extends StatelessWidget {
  final String name;
  final String date;
  final String participants;
  final List<Color> gradient;

  const _EventCard({
    required this.name,
    required this.date,
    required this.participants,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.pink.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, color: Colors.pink, size: 16),
              const SizedBox(width: 4),
              Text(
                participants,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 指南项目组件 - 霓虹风格
class _GuideItem extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _GuideItem({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              step,
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Icon(icon, color: color, size: 20),
      ],
    );
  }
}

// 门户卡片组件 - 霓虹风格
class _PortalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String url;
  final Color color;
  final List<Color> gradient;

  const _PortalCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.url,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    );
  }
}

// 社交卡片组件 - 霓虹风格
class _SocialCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String handle;
  final Color color;
  final List<Color> gradient;

  const _SocialCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.handle,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  handle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    );
  }
}

// 区域标题组件 - 霓虹风格
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
} 