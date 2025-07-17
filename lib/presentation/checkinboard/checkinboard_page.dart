import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/floating_logo.dart';

class CheckinboardPage extends StatelessWidget {
  CheckinboardPage({Key? key}) : super(key: key);

  // 示例数据
  final List<Map<String, dynamic>> checkinboards = [
    {
      'activity': 'HIIT Pro',
      'totalCheckins': 320,
      'topUser': {'name': 'John Doe', 'country': 'USA', 'streak': 45, 'year': 120, 'quarter': 40, 'month': 15},
      'rankings': [
        {'rank': 1, 'user': 'John Doe', 'country': 'USA', 'streak': 45, 'year': 120, 'quarter': 40, 'month': 15},
        {'rank': 2, 'user': 'Alice', 'country': 'UK', 'streak': 38, 'year': 110, 'quarter': 35, 'month': 12},
        {'rank': 3, 'user': 'Bob', 'country': 'Canada', 'streak': 30, 'year': 100, 'quarter': 30, 'month': 10},
      ],
    },
    {
      'activity': 'Yoga Flex',
      'totalCheckins': 210,
      'topUser': {'name': 'Emily', 'country': 'Germany', 'streak': 50, 'year': 130, 'quarter': 45, 'month': 20},
      'rankings': [
        {'rank': 1, 'user': 'Emily', 'country': 'Germany', 'streak': 50, 'year': 130, 'quarter': 45, 'month': 20},
        {'rank': 2, 'user': 'Sophia', 'country': 'France', 'streak': 40, 'year': 120, 'quarter': 40, 'month': 15},
        {'rank': 3, 'user': 'Liam', 'country': 'Italy', 'streak': 35, 'year': 110, 'quarter': 38, 'month': 13},
      ],
    },
    {
      'activity': 'Endurance Marathon',
      'totalCheckins': 410,
      'topUser': {'name': 'Mike', 'country': 'USA', 'streak': 60, 'year': 150, 'quarter': 50, 'month': 25},
      'rankings': [
        {'rank': 1, 'user': 'Mike', 'country': 'USA', 'streak': 60, 'year': 150, 'quarter': 50, 'month': 25},
        {'rank': 2, 'user': 'Anna', 'country': 'USA', 'streak': 55, 'year': 140, 'quarter': 48, 'month': 22},
        {'rank': 3, 'user': 'Chris', 'country': 'Canada', 'streak': 50, 'year': 135, 'quarter': 45, 'month': 20},
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
                    'Checkinboard',
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
          // 打卡排行榜列表
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final board = checkinboards[idx];
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
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 活动名和总打卡人数
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
                                    '${board['totalCheckins']} check-ins',
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
                          // RANK USER COUNTRY STREAK DAYS THIS YEAR THIS QUARTER THIS MONTH 标题
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
                                child: Text('COUNTRY', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text('STREAK', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text('YEAR', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text('QTR', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text('MONTH', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
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
                                      r['country'],
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: r['rank'] == 1 ? AppColors.primary : Colors.black87,
                                        fontWeight: r['rank'] == 1 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${r['streak']}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: r['rank'] == 1 ? AppColors.primary : Colors.black87,
                                        fontWeight: r['rank'] == 1 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${r['year']}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: r['rank'] == 1 ? AppColors.primary : Colors.black87,
                                        fontWeight: r['rank'] == 1 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${r['quarter']}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: r['rank'] == 1 ? AppColors.primary : Colors.black87,
                                        fontWeight: r['rank'] == 1 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${r['month']}',
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
                          // 连续打卡第一的人
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Top Streak: ${board['topUser']['name']} (${board['topUser']['country']})',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // 查看完整checkinboard提示
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Tap to view full checkinboard',
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
                childCount: checkinboards.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 用于内容区大标题的渐隐动画，只在LOGO完全展开时显示
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
