import 'package:flutter/material.dart';
import '../../widgets/floating_logo.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';
import '../../routes/app_routes.dart';

// 1. 定义playoff数据结构
enum PlayoffStage { round32, round8, round4, semi, finalMatch }

const Map<PlayoffStage, String> playoffStageNames = {
  PlayoffStage.round32: '1/32 PLAYOFF',
  PlayoffStage.round8: '1/8 FINALS',
  PlayoffStage.round4: '1/4 FINALS',
  PlayoffStage.semi: 'SEMI FINAL',
  PlayoffStage.finalMatch: 'FINAL',
};

class PlayoffMatch {
  final String? avatar1;
  final String? name1;
  final String? avatar2;
  final String? name2;
  final int? score1;
  final int? score2;
  final bool finished;
  PlayoffMatch({
    this.avatar1,
    this.name1,
    this.avatar2,
    this.name2,
    this.score1,
    this.score2,
    this.finished = false,
  });
}

final Map<PlayoffStage, List<PlayoffMatch>> playoffData = {
  PlayoffStage.round8: [
    PlayoffMatch(
      avatar1: 'https://randomuser.me/api/portraits/men/1.jpg',
      name1: 'Karateboxarwjs',
      avatar2: 'https://randomuser.me/api/portraits/men/2.jpg',
      name2: 'JaylenF',
      score1: 45,
      score2: 41,
      finished: true,
    ),
    PlayoffMatch(
      avatar1: 'https://randomuser.me/api/portraits/men/3.jpg',
      name1: 'Ein_gelo',
      avatar2: null,
      name2: null,
      score1: 40,
      score2: 35,
      finished: true,
    ),
    PlayoffMatch(),
    PlayoffMatch(),
  ],
  PlayoffStage.round4: [
    PlayoffMatch(), PlayoffMatch()
  ],
  PlayoffStage.semi: [
    PlayoffMatch()
  ],
  PlayoffStage.finalMatch: [
    PlayoffMatch()
  ],
  PlayoffStage.round32: [
    PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(),
    PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(), PlayoffMatch(),
  ],
};

class ChallengeDetailsPage extends StatefulWidget {
  const ChallengeDetailsPage({Key? key}) : super(key: key);

  @override
  State<ChallengeDetailsPage> createState() => ChallengeDetailsPageState();
}

class ChallengeDetailsPageState extends State<ChallengeDetailsPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  // 已不再需要ProfileFunctionGridState相关逻辑

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3个Tab
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 已不再需要ProfileFunctionGridState相关逻辑

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
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
                  Image.asset(
                    'assets/images/player_cover.png',
                    fit: BoxFit.cover,
                  ),
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
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _RuleCard(),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 5)),
          SliverToBoxAdapter(child: _FeatureEntryCard(
            onVideo: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _FullScreenVideoPage()),
              );
            },
            onJoin: () {
              // 获取id参数并跳转
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              final id = args != null ? args['challengeId'] : null;
              if (id != null) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.challengeRule,
                  arguments: {'challengeId': id},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Challenge id not found.')),
                );
              }
            },
          )),
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
                  Tab(text: 'Game Tracker'),
                  Tab(text: 'Preseason'),
                  Tab(text: 'Playoffs'),
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
              _GameTrackerTab(),
              _PreseasonRecordList(),
              _PlayoffBracket(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final VoidCallback? onMore;
  const _RuleCard({this.onMore});

  final List<String> _rules = const [
    '1. Complete the daily workout to earn points.',
    '2. Rankings are based on total points.',
    '3. Top 3 will receive exclusive rewards!',
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // 更紧凑
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule, color: Theme.of(context).primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Challenge Rules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6), // 更紧凑
            ..._rules.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 2), // 更紧凑
                  child: Text(
                    r,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[800], height: 1.35),
                  ),
                )),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onMore ?? () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Challenge Details'),
                      content: const Text(
                        'Here you can provide a more detailed description of the challenge rules, scoring, rewards, and any other information participants should know.\n\nYou can also add links, images, or FAQs as needed.'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  padding: EdgeInsets.zero, // 紧凑
                  minimumSize: const Size(0, 32), // 紧凑
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 紧凑
                ),
                child: const Text('Learn More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureEntryCard extends StatelessWidget {
  final VoidCallback? onVideo;
  final VoidCallback? onJoin;
  const _FeatureEntryCard({this.onVideo, this.onJoin});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      elevation: 0,
      color: Colors.white.withOpacity(0.98),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onVideo ?? () {},
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 0)),
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      return null;
                    }),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    overlayColor: MaterialStateProperty.all(primary.withOpacity(0.08)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_circle_fill, size: 20, color: Colors.white),
                          SizedBox(width: 7),
                          Flexible(
                            child: Text('Video Intro',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: onJoin ?? () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: primary, width: 1.5),
                    backgroundColor: Colors.black,
                    foregroundColor: primary,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, size: 18, color: primary),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text('Join Now',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreseasonRecordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final records = [
      {'index': 1, 'name': 'HIIT 7-Day Challenge', 'rank': '2nd'},
      {'index': 2, 'name': 'Yoga Masters Cup', 'rank': '1st'},
    ];
    // 公告内容
    final String notice = 'Preseason is for warm-up and fun! Results here do not affect the official playoffs. Enjoy and challenge yourself!';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              notice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ) ?? const TextStyle(fontSize: 15, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('preseasonList'),
            padding: const EdgeInsets.only(top: 0),
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
          ),
        ),
      ],
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
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}

class _FullScreenVideoPage extends StatefulWidget {
  const _FullScreenVideoPage({Key? key}) : super(key: key);
  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/video1.mp4')
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.red, size: 28),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
          ),
        ],
      ),
    );
  }
}

// 3. 新增_PlayoffBracket组件
class _PlayoffBracket extends StatefulWidget {
  @override
  State<_PlayoffBracket> createState() => _PlayoffBracketState();
}

class _PlayoffBracketState extends State<_PlayoffBracket> {
  PlayoffStage _selectedStage = PlayoffStage.round8;

  @override
  Widget build(BuildContext context) {
    final matches = playoffData[_selectedStage] ?? [];
    return Container(
      color: const Color(0xFFF7F8FA), // 苹果风浅灰背景
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部分段选择器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PlayoffStage.values.map((stage) {
                  final selected = _selectedStage == stage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStage = stage),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 18),
                        decoration: BoxDecoration(
                          color: selected ? Colors.black : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: selected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                        ),
                        child: Text(
                          playoffStageNames[stage]!,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 分组对阵
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final m = matches[i];
                return _PlayoffMatchCard(match: m);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayoffMatchCard extends StatelessWidget {
  final PlayoffMatch match;
  const _PlayoffMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final bool hasData = match.name1 != null || match.name2 != null;
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFE5E6EB);
    final Gradient cardGradient = LinearGradient(
      colors: [
        Theme.of(context).primaryColor.withOpacity(0.08),
        Colors.white,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      child: hasData ? Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _PlayoffUserCell(
              avatar: match.avatar1,
              name: match.name1,
              isWinner: (match.score1 ?? 0) > (match.score2 ?? 0),
              score: match.score1,
              alignRight: false,
            ),
          ),
          // VS圆形徽章
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.18),
                    blurRadius: 8,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  'VS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _PlayoffUserCell(
              avatar: match.avatar2,
              name: match.name2,
              isWinner: (match.score2 ?? 0) > (match.score1 ?? 0),
              score: match.score2,
              alignRight: true,
            ),
          ),
        ],
      ) : const SizedBox(height: 32),
    );
  }
}

class _PlayoffUserCell extends StatelessWidget {
  final String? avatar;
  final String? name;
  final bool isWinner;
  final int? score;
  final bool alignRight;
  const _PlayoffUserCell({this.avatar, this.name, this.isWinner = false, this.score, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    if (name == null) {
      return const SizedBox(width: 100);
    }
    return Row(
      mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (!alignRight) ...[
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
            child: avatar == null ? const Icon(Icons.person, color: Colors.grey, size: 20) : null,
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        name!,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isWinner && score != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.emoji_events, color: Colors.amber, size: 22, shadows: [Shadow(color: Colors.amber, blurRadius: 6)]),
                    ),
                ],
              ),
              if (score != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                      shadows: [Shadow(color: Theme.of(context).primaryColor.withOpacity(0.12), blurRadius: 4)],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (alignRight) ...[
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
            child: avatar == null ? const Icon(Icons.person, color: Colors.grey, size: 20) : null,
          ),
        ],
      ],
    );
  }
}

class _GameTrackerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 伪数据
    final List<Map<String, dynamic>> posts = [
      {
        'announcement': '🏆 Congratulations!\nYou are the WINNER of the 10 SEC MAX Challenge!',
        'image': 'assets/images/player_cover.png',
        'desc': 'Share your achievement with friends and stay tuned for the next challenge!',
        'time': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'announcement': '🔥 New Record!\nYou hit 50 punches in 10 seconds!',
        'image': 'assets/images/avatar_default.png',
        'desc': 'Keep pushing your limits and break more records!',
        'time': DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
      },
      {
        'announcement': '🎉 Challenge Completed!\nYou finished all daily tasks.',
        'image': 'assets/images/player_cover.png',
        'desc': 'Great job! Don’t forget to check out the next event.',
        'time': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      },
      {
        'announcement': '🎉 Challenge Completed!\nYou finished all daily tasks.',
        'image': null,
        'desc': 'Great job! Don’t forget to check out the next event.',
        'time': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      },
      {
        'announcement': '🎉 Challenge Completed!\nYou finished all daily tasks.',
        'image': null,
        'desc': null,
        'time': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      },
      {
        'announcement': null,
        'image': 'assets/images/player_cover.png',
        'desc': null,
        'time': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      }
    ];
    // 按时间倒序
    posts.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: posts.map((post) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _GameTrackerCard(
            announcement: post['announcement'],
            imageAsset: post['image'],
            desc: post['desc'],
            time: post['time'],
          ),
        )).toList(),
      ),
    );
  }
}

class _GameTrackerCard extends StatelessWidget {
  final String? announcement;
  final String? imageAsset;
  final String? desc;
  final DateTime? time;
  const _GameTrackerCard({
    this.announcement,
    this.imageAsset,
    this.desc,
    this.time,
  });

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${t.year}/${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    // 时间
    if (time != null) {
      children.add(Row(
        children: [
          Icon(Icons.access_time, color: Colors.grey[500], size: 18),
          const SizedBox(width: 6),
          Text(
            _formatTime(time!),
            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2),
          ),
        ],
      ));
      if (imageAsset != null || announcement != null || desc != null) {
        children.add(const SizedBox(height: 10));
      }
    }

    // 图片
    if (imageAsset != null) {
      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Image.asset(
                imageAsset!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
      if (announcement != null || desc != null) {
        children.add(const SizedBox(height: 16));
      }
    }

    // 标题
    if (announcement != null) {
      children.add(
        Text(
          announcement!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.4,
              ) ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      );
      if (desc != null) {
        children.add(const SizedBox(height: 8));
      }
    }

    // 描述
    if (desc != null) {
      children.add(
        Text(
          desc!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
