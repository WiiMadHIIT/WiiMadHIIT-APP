import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // 顶部欢迎区域
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.white,
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
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Welcome back, John! 👋',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
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
          
          // 今日数据概览
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.emoji_events,
                      value: '3',
                      label: 'Challenges',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      value: '12',
                      label: 'Check-ins',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 最近7天突出比赛结果
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🏆 Recent Champions',
              subtitle: 'Top performers this week',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
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
                  );
                },
              ),
            ),
          ),

          // 最近7天打卡积极用户
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🔥 Active Users',
              subtitle: 'Most consistent this week',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return _ActiveUserCard(
                    name: 'User ${index + 1}',
                    streak: '${7 + index}',
                    avatar: 'assets/images/avatar_default.png',
                  );
                },
              ),
            ),
          ),

          // 装备展示
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '⚡ Your Gear',
              subtitle: 'Track your equipment',
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
                    Colors.purple.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: Colors.purple, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Connected Devices',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _GearItem(icon: Icons.watch, name: 'Smart Watch', status: 'Connected'),
                      const SizedBox(width: 16),
                      _GearItem(icon: Icons.phone_android, name: 'Phone', status: 'Connected'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 未来推出计划
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🚀 Coming Soon',
              subtitle: 'Exciting features ahead',
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
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
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
                  ),
                  const SizedBox(height: 8),
                  _FeatureItem(
                    icon: Icons.analytics,
                    title: 'Advanced Analytics',
                    description: 'Detailed progress tracking',
                    date: 'Coming Soon',
                  ),
                ],
              ),
            ),
          ),

          // 未来推出活动
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🎯 Upcoming Events',
              subtitle: 'Don\'t miss out',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
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
                  );
                },
              ),
            ),
          ),

          // 使用说明
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '📖 How to Use',
              subtitle: 'Get started quickly',
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
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
                  ),
                  const SizedBox(height: 16),
                  _GuideItem(
                    step: '2',
                    title: 'Join Challenges',
                    description: 'Participate in daily fitness challenges',
                    icon: Icons.emoji_events,
                  ),
                  const SizedBox(height: 16),
                  _GuideItem(
                    step: '3',
                    title: 'Track Progress',
                    description: 'Monitor your achievements and streaks',
                    icon: Icons.trending_up,
                  ),
                ],
              ),
            ),
          ),

          // 网站入口
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '🌐 Web Portal',
              subtitle: 'Access on desktop',
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
              ),
            ),
          ),

          // 社媒入口
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '📱 Social Media',
              subtitle: 'Connect with us',
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
                  ),
                  const SizedBox(height: 12),
                  _SocialCard(
                    icon: Icons.photo_camera,
                    title: 'Instagram',
                    description: 'Daily motivation & updates',
                    handle: '@wiimadhiit',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _SocialCard(
                    icon: Icons.share,
                    title: 'YouTube',
                    description: 'Workout tutorials & guides',
                    handle: 'Wiimadhiit Official',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),

          // 底部间距
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}

// 统计卡片组件
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// 冠军卡片组件
class _ChampionCard extends StatelessWidget {
  final String name;
  final String challenge;
  final String rank;
  final String avatar;

  const _ChampionCard({
    required this.name,
    required this.challenge,
    required this.rank,
    required this.avatar,
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
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(avatar),
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
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      challenge,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey[600],
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
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
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

// 活跃用户卡片组件
class _ActiveUserCard extends StatelessWidget {
  final String name;
  final String streak;
  final String avatar;

  const _ActiveUserCard({
    required this.name,
    required this.streak,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(avatar),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
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

// 装备项目组件
class _GearItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String status;

  const _GearItem({
    required this.icon,
    required this.name,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.purple, size: 24),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
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

// 功能项目组件
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String date;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange, size: 20),
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
                ),
              ),
              Text(
                description,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// 活动卡片组件
class _EventCard extends StatelessWidget {
  final String name;
  final String date;
  final String participants;

  const _EventCard({
    required this.name,
    required this.date,
    required this.participants,
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
          colors: [
            Colors.pink.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.pink.withOpacity(0.3),
          width: 1,
        ),
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
              color: Colors.grey[600],
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

// 指南项目组件
class _GuideItem extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final IconData icon;

  const _GuideItem({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                ),
              ),
              Text(
                description,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(icon, color: AppColors.primary, size: 20),
      ],
    );
  }
}

// 门户卡片组件
class _PortalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String url;
  final Color color;

  const _PortalCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
                    color: Colors.grey[600],
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

// 社交卡片组件
class _SocialCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String handle;
  final Color color;

  const _SocialCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.handle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
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
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.grey[600],
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

// 区域标题组件
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
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
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 