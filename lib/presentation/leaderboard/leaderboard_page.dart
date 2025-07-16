import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 顶部悬浮LOGO和返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 32,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // LOGO始终居中
                Center(
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
                // 返回按钮，左上角绝对定位
                Positioned(
                  left: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.18),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 活动排行榜区
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 110,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: ListView.separated(
              itemCount: leaderboards.length + 1,
              separatorBuilder: (context, idx) => idx == 0 ? const SizedBox(height: 24) : const SizedBox(height: 28),
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  // LeaderBoard标题（无背景，白色大号字体，页面主标题风格）
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Center(
                      child: Text(
                        'LeaderBoard',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  );
                }
                final board = leaderboards[idx - 1];
                return GestureDetector(
                  onTap: () {
                    // TODO: 跳转完整排名页面
                  },
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
            ),
          ),
        ],
      ),
    );
  }
}
