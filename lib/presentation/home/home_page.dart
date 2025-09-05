import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/services/home_service.dart';
import '../../domain/entities/home/home_entities.dart';
import '../../data/repository/home_repository.dart';
import '../../data/api/home_api.dart';
import '../../domain/usecases/get_home_dashboard_usecase.dart';
import 'home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        getHomeAnnouncementsUseCase: GetHomeAnnouncementsUseCase(HomeRepository(HomeApi())),
        getHomeChampionsUseCase: GetHomeChampionsUseCase(HomeRepository(HomeApi())),
        getHomeActiveUsersUseCase: GetHomeActiveUsersUseCase(HomeRepository(HomeApi())),
        homeService: HomeService(),
      )..loadAllData(), // 使用新的并行加载方法
      child: const _HomePageContent(),
    );
  }

  /// 大厂级别：智能刷新Home数据（结合时间检查）
  /// 如果距离上次完整刷新超过20小时，执行完整刷新
  /// 否则执行智能刷新（有数据时跳过）
  void smartRefreshHomeData() {
    try {
      // 通过 Provider 获取 ViewModel
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      
      // 检查是否有任何数据
      final hasAnyData = viewModel.hasAnnouncements || viewModel.hasChampions || viewModel.hasActiveUsers;
      
      if (!hasAnyData) {
        // 无数据时，执行刷新
        print('🔐 HomePage: 无数据，执行刷新');
        viewModel.loadAllData();
      } else {
        // 调用新的智能时间检查刷新方法
        print('🔐 HomePage: 调用智能时间检查刷新');
        viewModel.smartRefreshWithTimeCheck();
      }
    } catch (e) {
      print('🔐 HomePage: 智能刷新失败: $e');
    }
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent({Key? key}) : super(key: key);

  Future<void> _launchOfficialWebsite() async {
    final Uri url = Uri.parse('https://www.wiimadhiit.com/?utm_source=WiiMadHIIT_APP_home&utm_medium=app_official_link&utm_campaign=WiiMadHIIT_APP');
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        // 可以在这里添加错误处理，比如显示SnackBar
        print('Failed to launch official website');
      }
    } catch (e) {
      print('Error launching official website: $e');
    }
  }

  Future<void> _launchTikTok() async {
    final Uri url = Uri.parse('https://www.tiktok.com/@wiimadhiit');
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        print('Failed to launch TikTok');
      }
    } catch (e) {
      print('Error launching TikTok: $e');
    }
  }

  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse('https://www.instagram.com/wiimadhiit/');
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        print('Failed to launch Instagram');
      }
    } catch (e) {
      print('Error launching Instagram: $e');
    }
  }

  Future<void> _launchYouTube() async {
    final Uri url = Uri.parse('https://www.youtube.com/@wiimadhiit');
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        print('Failed to launch YouTube');
      }
    } catch (e) {
      print('Error launching YouTube: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom; //safty安全区高度 
    
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A), // 深色背景，TikTok风格
          body: RefreshIndicator(
            onRefresh: () => viewModel.refreshAllData(),
            child: CustomScrollView(
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
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
                                  if (viewModel.isAllLoading) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Syncing...',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                                                      Text(
                          'Welcome back, Fitness Warrior! 👋',
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
                          'Ready to crush today\'s goals?',
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
                
                // 滚动公告栏 - 简洁苹果风格
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    height: 100, // 减少高度，更简洁
                    child: _buildAnnouncementCarousel(viewModel),
                  ),
                ),

                // 最近7天突出比赛结果 - 霓虹卡片
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: '🏆 This Week\'s Legends',
                    subtitle: 'The fitness heroes who crushed it',
                    color: Colors.amber,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildChampionsSection(viewModel),
                ),

                // 最近7天打卡积极用户 - 霓虹风格
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: '🔥 Consistency Kings & Queens',
                    subtitle: 'The daily grind champions',
                    color: Colors.red,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildActiveUsersSection(viewModel),
                ),
                
                // 使用说明 - 霓虹绿色
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: '📖 Quick Start Guide',
                    subtitle: 'Get fit in 3 easy steps',
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _GuideItem(
                          step: '1',
                          title: 'Connect Your Gear',
                          description: 'Sync your smart watch or phone',
                          icon: Icons.bluetooth,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _GuideItem(
                          step: '2',
                          title: 'Join the Battle',
                          description: 'Take on daily fitness challenges',
                          icon: Icons.emoji_events,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        _GuideItem(
                          step: '3',
                          title: 'Track & Crush',
                          description: 'Watch your progress soar',
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
                    title: '🌐 Desktop Experience',
                    subtitle: 'Big screen, bigger gains',
                    color: Colors.blue,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: _launchOfficialWebsite,
                      child: _PortalCard(
                        icon: Icons.language,
                        title: 'WiiMadHIIT Official',
                        description: '🚀 Discover more awesomeness & stay connected with us! 💪',
                        url: 'https://wiimadhiit.com',
                        color: Colors.blue,
                        gradient: [
                          Colors.blue.withOpacity(0.1),
                          Colors.cyan.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),

                // 社媒入口 - 霓虹紫色
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: '📱 Social Fitness',
                    subtitle: 'Join the community',
                    color: Colors.purple,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _launchTikTok,
                          child: _SocialCard(
                            icon: Icons.camera_alt,
                            title: 'TikTok',
                            description: 'Get fit with viral moves',
                            handle: '@wiimadhiit',
                            color: Colors.black,
                            gradient: [
                              Colors.black.withOpacity(0.1),
                              Colors.grey.withOpacity(0.1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _launchInstagram,
                          child: _SocialCard(
                            icon: Icons.photo_camera,
                            title: 'Instagram',
                            description: 'Daily dose of motivation',
                            handle: '@wiimadhiit',
                            color: Colors.purple,
                            gradient: [
                              Colors.purple.withOpacity(0.1),
                              Colors.pink.withOpacity(0.1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _launchYouTube,
                          child: _SocialCard(
                            icon: Icons.share,
                            title: 'YouTube',
                            description: 'Master your workouts',
                            handle: 'Wiimadhiit Official',
                            color: Colors.red,
                            gradient: [
                              Colors.red.withOpacity(0.1),
                              Colors.orange.withOpacity(0.1),
                            ],
                          ),
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
          ),
        );
      },
    );
  }

  // 构建公告轮播组件
  Widget _buildAnnouncementCarousel(HomeViewModel viewModel) {
    if (viewModel.isAnnouncementsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasAnnouncementsError) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              Text(
                'Oops! Announcements went MIA',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => viewModel.loadAnnouncements(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (!viewModel.hasAnnouncements) {
      return Center(
        child: Text(
          'No announcements yet',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }

    return _SimplifiedAnnouncementCarousel(
      announcements: viewModel.sortedAnnouncements,
    );
  }

  // 构建冠军展示区域
  Widget _buildChampionsSection(HomeViewModel viewModel) {
    if (viewModel.isChampionsLoading) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.hasChampionsError) {
      return SizedBox(
        height: 240,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Oops! Champions went MIA',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => viewModel.loadChampions(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!viewModel.hasChampions) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Text(
            'No champions yet - be the first!',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.sortedChampions.length,
        itemBuilder: (context, index) {
          final champion = viewModel.sortedChampions[index];
          return _ChampionCard(
            name: champion.username,
            challenge: champion.challengeName,
            rank: champion.rankText,
            score: champion.scoreText,
            avatar: champion.avatar.isNotEmpty ? champion.avatar : 'assets/images/avatar_default.png',
            gradient: [
              Colors.amber.withOpacity(0.2),
              Colors.orange.withOpacity(0.2),
              Colors.red.withOpacity(0.1),
            ],
          );
        },
      ),
    );
  }

  // 构建活跃用户展示区域
  Widget _buildActiveUsersSection(HomeViewModel viewModel) {
    if (viewModel.isActiveUsersLoading) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.hasActiveUsersError) {
      return SizedBox(
        height: 140,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Oops! Users went AWOL',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => viewModel.loadActiveUsers(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!viewModel.hasActiveUsers) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'No active users yet - start the trend!',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.sortedActiveUsers.length,
        itemBuilder: (context, index) {
          final user = viewModel.sortedActiveUsers[index];
          return _ActiveUserCard(
            name: user.username,
            streak: user.streakText,
            avatar: user.avatar.isNotEmpty ? user.avatar : 'assets/images/avatar_default.png',
            gradient: [
              Colors.red.withOpacity(0.1),
              Colors.pink.withOpacity(0.1),
            ],
          );
        },
      ),
    );
  }
}

// 冠军卡片组件 - 苹果风格优化
class _ChampionCard extends StatelessWidget {
  final String name;
  final String challenge;
  final String rank;
  final String score;
  final String avatar;
  final List<Color> gradient;

  const _ChampionCard({
    required this.name,
    required this.challenge,
    required this.rank,
    required this.score,
    required this.avatar,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // 增加宽度以容纳更多内容
      margin: const EdgeInsets.only(right: 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部排名徽章
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getRankIcon(int.parse(rank)),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$rank Place',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 主要内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头像和用户信息
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildAvatar(avatar, 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                score,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 挑战项目信息
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Challenge',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          challenge,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.star;
    }
  }

  Widget _buildAvatar(String avatar, double radius) {
    // 判断是否为远程HTTP图片
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatar),
        onBackgroundImageError: (exception, stackTrace) {
          // 网络图片加载失败时，使用默认头像
          print('Failed to load network image: $avatar');
        },
        child: null,
      );
    } else {
      // 本地assets图片
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(avatar),
        onBackgroundImageError: (exception, stackTrace) {
          // 本地图片加载失败时，使用默认头像
          print('Failed to load asset image: $avatar');
        },
        child: null,
      );
    }
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
            ),
            child: _buildAvatar(avatar, 25),
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

  Widget _buildAvatar(String avatar, double radius) {
    // 判断是否为远程HTTP图片1
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatar),
        onBackgroundImageError: (exception, stackTrace) {
          // 网络图片加载失败时，使用默认头像
          print('Failed to load network image: $avatar');
        },
        child: null,
      );
    } else {
      // 本地assets图片
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(avatar),
        onBackgroundImageError: (exception, stackTrace) {
          // 本地图片加载失败时，使用默认头像
          print('Failed to load asset image: $avatar');
        },
        child: null,
      );
    }
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
      mainAxisSize: MainAxisSize.min,
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
            mainAxisSize: MainAxisSize.min,
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
        mainAxisSize: MainAxisSize.min,
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
              mainAxisSize: MainAxisSize.min,
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
        mainAxisSize: MainAxisSize.min,
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
              mainAxisSize: MainAxisSize.min,
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
        mainAxisSize: MainAxisSize.min,
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

// 公告项目数据类
class _AnnouncementItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final Color color;
  final List<Color> gradient;
  final String? route;

  _AnnouncementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.color,
    required this.gradient,
    this.route,
  });
}

// 公告卡片组件
class _AnnouncementCard extends StatelessWidget {
  final _AnnouncementItem announcement;
  final bool isActive;

  const _AnnouncementCard({
    required this.announcement,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16), // 减少padding
      child: GestureDetector(
        onTap: () {
          if (announcement.route != null) {
            Navigator.pushNamed(context, announcement.route!);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: announcement.gradient.map((color) => 
                color.withOpacity(0.15)
              ).toList(),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: announcement.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12), // 减少内部padding
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标区域
                Container(
                  padding: const EdgeInsets.all(8), // 减少图标padding
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: announcement.gradient.map((color) => 
                        color.withOpacity(0.2)
                      ).toList(),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: announcement.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    announcement.icon,
                    color: announcement.color,
                    size: 20, // 稍微减小图标
                  ),
                ),
                
                const SizedBox(width: 12), // 减少间距
                
                // 内容区域
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        announcement.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16, // 控制字体大小
                          shadows: [
                            Shadow(
                              color: announcement.color.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // 减少间距
                      Text(
                        announcement.subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13, // 控制字体大小
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8), // 减少间距
                
                // 操作按钮
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // 减少按钮padding
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: announcement.gradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: announcement.color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    announcement.action,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11, // 控制字体大小
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 指示器圆点组件
class _IndicatorDot extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _IndicatorDot({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(isActive ? 6 : 4),
        boxShadow: isActive ? [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
    );
  }
}

// 导航按钮组件
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _NavigationButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}

// 简洁版公告轮播组件 - 苹果风格设计
class _SimplifiedAnnouncementCarousel extends StatefulWidget {
  final List<Announcement> announcements;
  
  const _SimplifiedAnnouncementCarousel({
    required this.announcements,
  });

  @override
  State<_SimplifiedAnnouncementCarousel> createState() => _SimplifiedAnnouncementCarouselState();
}

class _SimplifiedAnnouncementCarouselState extends State<_SimplifiedAnnouncementCarousel> 
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  
  // 公告数据 - 从传入的announcements转换
  List<_SimplifiedAnnouncementItem> get _announcements {
    return widget.announcements.map((announcement) => _SimplifiedAnnouncementItem(
      icon: announcement.icon,
      title: announcement.title,
      subtitle: announcement.subtitle,
      color: announcement.color,
      route: null, // 暂时设为null，后续可以根据需要添加路由
    )).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // 自动滚动
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _nextPage();
        _startAutoScroll();
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < _announcements.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _announcements.length - 1;
    }
    
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 公告内容
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: _announcements.length,
          itemBuilder: (context, index) {
            final announcement = _announcements[index];
            return _SimplifiedAnnouncementCard(
              announcement: announcement,
              isActive: index == _currentIndex,
            );
          },
        ),
        
        // 指示器
        Positioned(
          bottom: 4,
          left: 0,
          right: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _announcements.length,
              (index) => _SimplifiedIndicatorDot(
                isActive: index == _currentIndex,
                color: _announcements[index].color,
              ),
            ),
          ),
        ),
        
        // 左右导航按钮
        Positioned(
          left: 4,
          top: 0,
          bottom: 0,
          child: Center(
            child: _SimplifiedNavigationButton(
              icon: Icons.chevron_left,
              onTap: _previousPage,
            ),
          ),
        ),
        
        Positioned(
          right: 4,
          top: 0,
          bottom: 0,
          child: Center(
            child: _SimplifiedNavigationButton(
              icon: Icons.chevron_right,
              onTap: _nextPage,
            ),
          ),
        ),
      ],
    );
  }
}

// 简洁版公告项目数据类
class _SimplifiedAnnouncementItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? route;

  _SimplifiedAnnouncementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.route,
  });
}

// 简洁版公告卡片组件
class _SimplifiedAnnouncementCard extends StatelessWidget {
  final _SimplifiedAnnouncementItem announcement;
  final bool isActive;

  const _SimplifiedAnnouncementCard({
    required this.announcement,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          if (announcement.route != null) {
            Navigator.pushNamed(context, announcement.route!);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                announcement.color.withOpacity(0.1),
                announcement.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: announcement.color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标区域
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: announcement.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    announcement.icon,
                    color: announcement.color,
                    size: 18,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 内容区域
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        announcement.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        announcement.subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // 箭头指示
                Icon(
                  Icons.arrow_forward_ios,
                  color: announcement.color.withOpacity(0.6),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 简洁版指示器圆点组件
class _SimplifiedIndicatorDot extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _SimplifiedIndicatorDot({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: isActive ? 8 : 4,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// 简洁版导航按钮组件
class _SimplifiedNavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SimplifiedNavigationButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 14,
        ),
      ),
    );
  }
}

// 简约版功能项目组件 - 苹果风格设计
class _SimplifiedFeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String date;
  final Color color;
  final String priority;

  const _SimplifiedFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
    required this.priority,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标区域
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
          
          const SizedBox(width: 16),
          
          // 内容区域
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // 优先级标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getPriorityColor(priority).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        priority,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getPriorityColor(priority),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 日期区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  date,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  Icons.schedule,
                  color: color.withOpacity(0.7),
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
