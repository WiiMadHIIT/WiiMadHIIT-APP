import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/floating_logo.dart';

class LeaderboardPage extends StatelessWidget {
  LeaderboardPage({Key? key}) : super(key: key);

  // 示例数据
  final List<Map<String, dynamic>> leaderboards = [
    {
      'activity': '7-Day HIIT Showdown',
      'participants': 128,
      'topUser': {'name': 'John Doe', 'score': 980},
      'rankings': [
        {'rank': 1, 'user': 'John Doe', 'score': 980},
        {'rank': 2, 'user': 'Alice', 'score': 950},
        {'rank': 3, 'user': 'Bob', 'score': 900},
      ],
    },
    {
      'activity': 'Yoga Masters Cup',
      'participants': 89,
      'topUser': {'name': 'Emily', 'score': 870},
      'rankings': [
        {'rank': 1, 'user': 'Emily', 'score': 870},
        {'rank': 2, 'user': 'Sophia', 'score': 860},
        {'rank': 3, 'user': 'Liam', 'score': 850},
      ],
    },
    {
      'activity': 'Endurance Marathon',
      'participants': 256,
      'topUser': {'name': 'Mike', 'score': 1200},
      'rankings': [
        {'rank': 1, 'user': 'Mike', 'score': 1200},
        {'rank': 2, 'user': 'Anna', 'score': 1150},
        {'rank': 3, 'user': 'Chris', 'score': 1100},
      ],
    },
    {
      'activity': 'Endurance Marathon',
      'participants': 256,
      'topUser': {'name': 'Mike', 'score': 1200},
      'rankings': [
        {'rank': 1, 'user': 'Mike', 'score': 1200},
        {'rank': 2, 'user': 'Anna', 'score': 1150},
        {'rank': 3, 'user': 'Chris', 'score': 1100},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double expandedHeight = 180;
    final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            expandedHeight: expandedHeight,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            // 只在收起时显示title
            title: Text(
                    'Leaderboard',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Material(
                color: Colors.black.withOpacity(0.18),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double t = ((constraints.maxHeight - collapsedHeight) /
                        (expandedHeight - collapsedHeight))
                    .clamp(0.0, 1.0);
                // 只在展开时显示LOGO
                if (t < 0.15) return const SizedBox.shrink();
                return Opacity(
                  opacity: Curves.easeIn.transform(t),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 24,
                      ),
                      child: const LogoContent(),
                    ),
                  ),
                );
              },
            ),
          ),
          // 排行榜列表
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final board = leaderboards[idx];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 活动名和参与人数
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  board['activity'],
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.people, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${board['participants']} joined',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // RANK USER SCORE 标题
                          Row(
                            children: [
                              Expanded(
                                child: Text('RANK', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('USER', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text('SCORE', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 只展示前三名
                          ...List.generate(3, (i) {
                            final r = board['rankings'][i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${r['rank']}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: r['rank'] == 1 ? AppColors.primary : Colors.black87,
                                        fontWeight: r['rank'] == 1 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      r['user'],
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: r['rank'] == 1 ? AppColors.primary : Colors.black87,
                                        fontWeight: r['rank'] == 1 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${r['score']}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: r['rank'] == 1 ? AppColors.primary : Colors.black87,
                                        fontWeight: r['rank'] == 1 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                          // 头号获奖者
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Top Winner: ${board['topUser']['name']}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // 查看完整排名提示
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Tap to view full leaderboard',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: leaderboards.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 用于内容区大标题的渐隐动画
class _FadeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Widget child;

  _FadeHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 只在LOGO完全展开时显示
    final double t = (1 - (shrinkOffset / (maxExtent - minExtent))).clamp(0.0, 1.0);
    return Opacity(
      opacity: t > 0.98 ? 1.0 : 0.0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_FadeHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent;
  }
}

class LogoContent extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  const LogoContent({this.margin, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.40),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.13), width: 1.1),
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
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
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
    );
  }
}
