import 'package:flutter/material.dart';
import '../../widgets/floating_logo.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // 顶部大背景+头像+荣誉墙
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
                    'assets/images/profile_bg.jpg',
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
                  // 编辑按钮
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 20,
                    child: _EditProfileButton(),
                  ),
                  // 头像+用户名+运动天数
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 32,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/images/avatar_default.png'),
                        ),
                        const SizedBox(height: 12),
                        Text('Username', style: AppTextStyles.headlineMedium.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('ID: 123456789', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700])),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatBlock(label: '连续运动', value: '36天'),
                            const SizedBox(width: 18),
                            _StatBlock(label: '年度运动', value: '120天'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 荣誉墙（横向滑动/宫格）
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -30,
                    child: _HonorWall(),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.only(top: 40, bottom: 24),
          children: [
            // 功能入口区
            _ProfileFunctionGrid(),
            const SizedBox(height: 18),
            // 比赛记录区
            _SectionTitle('Challenge Records'),
            _ChallengeRecordList(),
            const SizedBox(height: 18),
            // 打卡记录区
            _SectionTitle('Check-in Records'),
            _CheckinRecordList(),
          ],
        ),
      ),
    );
  }
}

// 下面是各个子组件的结构草图（可根据实际需求细化）

class _EditProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.edit, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Text('Edit', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
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
    // 可用ListView横向滑动或宫格
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MedalWidget(icon: Icons.emoji_events, label: '年度冠军', desc: '2023年HIIT总冠军'),
          const SizedBox(width: 18),
          _MedalWidget(icon: Icons.star, label: '最佳打卡', desc: '连续打卡60天'),
        ],
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
      children: [
        Icon(icon, color: AppColors.primary, size: 32),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        Text(desc, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700])),
      ],
    );
  }
}

class _ProfileFunctionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 宫格功能入口
    final items = [
      {'icon': Icons.card_giftcard, 'label': '激活入口'},
      {'icon': Icons.emoji_events, 'label': '奖励联系'},
      {'icon': Icons.shopping_bag, 'label': '产品列表'},
      {'icon': Icons.bar_chart, 'label': '运动数据'},
      {'icon': Icons.check_circle, 'label': '打卡数据'},
    ];
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            return Column(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.10),
                  child: Icon(item['icon'] as IconData, color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(item['label'] as String, style: AppTextStyles.labelMedium.copyWith(color: Colors.black87)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 0, 8),
      child: Text(title, style: AppTextStyles.titleMedium.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }
}

class _ChallengeRecordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final records = [
      {'index': 1, 'name': 'HIIT 7天挑战', 'rank': '第2名'},
      {'index': 2, 'name': '瑜伽大师赛', 'rank': '第1名'},
    ];
    return Column(
      children: records.map((r) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(child: Text('${r['index']}')),
            title: Text(r['name'].toString(), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            trailing: Text(r['rank'].toString(), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          ),
        );
      }).toList(),
    );
  }
}

class _CheckinRecordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final records = [
      {'index': 1, 'name': 'HIIT Pro', 'count': '第36次'},
      {'index': 2, 'name': 'Yoga Flex', 'count': '第20次'},
    ];
    return Column(
      children: records.map((r) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(child: Text('${r['index']}')),
            title: Text(r['name'].toString(), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            trailing: Text(r['count'].toString(), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          ),
        );
      }).toList(),
    );
  }
}
