import 'package:flutter/material.dart';

/// 挑战游戏历史排行榜数据模型
class ChallengeHistoryRankingItem {
  final int? rank;
  final String date;
  final int counts;
  final String? note;
  final String? name;
  final Map<String, dynamic>? additionalData;

  const ChallengeHistoryRankingItem({
    this.rank,
    required this.date,
    required this.counts,
    this.note,
    this.name,
    this.additionalData,
  });

  /// 从Map创建实例
  factory ChallengeHistoryRankingItem.fromMap(Map<String, dynamic> map) {
    return ChallengeHistoryRankingItem(
      rank: map['rank'],
      date: map['date'] ?? '',
      counts: map['counts'] ?? 0,
      note: map['note'],
      name: map['name'],
      additionalData: map,
    );
  }

  /// 是否为当前项目
  bool get isCurrent => note == 'current';
  
  /// 是否为前三名
  bool get isTopThree => rank != null && rank! <= 3;
  
  /// 获取显示用的名字（处理长名字）
  String get displayName {
    if (name == null || name!.isEmpty) return 'Unknown';
    if (name!.length <= 8) return name!;
    return '${name!.substring(0, 7)}...';
  }
  
  /// 根据屏幕宽度获取显示用的名字
  String getDisplayNameForWidth(double width) {
    if (name == null || name!.isEmpty) return 'Unknown';
    
    // 根据屏幕宽度智能调整显示长度
    final isVeryNarrow = width < 400;
    final isNarrow = width < 600;
    final maxLength = isVeryNarrow ? 6 : (isNarrow ? 8 : 12);
    
    if (name!.length <= maxLength) return name!;
    return '${name!.substring(0, maxLength - 1)}...';
  }
}

/// 挑战游戏历史排行榜组件配置
class ChallengeHistoryRankingConfig {
  final String title;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? currentItemColor;
  final double borderRadius;
  final EdgeInsets padding;

  const ChallengeHistoryRankingConfig({
    this.title = 'CHALLENGE RANKINGS',
    this.backgroundColor,
    this.titleColor,
    this.currentItemColor,
    this.borderRadius = 28.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });
}

/// 挑战游戏专用历史排行榜组件
class ChallengeHistoryRankingWidget extends StatelessWidget {
  final List<ChallengeHistoryRankingItem> history;
  final ScrollController scrollController;
  final ChallengeHistoryRankingConfig? config;
  final Widget Function(ChallengeHistoryRankingItem item, int index)? itemBuilder;
  final VoidCallback? onItemTap;
  final String? emptyMessage;

  const ChallengeHistoryRankingWidget({
    super.key,
    required this.history,
    required this.scrollController,
    this.config,
    this.itemBuilder,
    this.onItemTap,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? const ChallengeHistoryRankingConfig();
    
    return Container(
      decoration: BoxDecoration(
        color: effectiveConfig.backgroundColor ?? Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.vertical(top: Radius.circular(effectiveConfig.borderRadius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildDragIndicator(),
          _buildTitleSection(effectiveConfig),
          _buildHeaderSection(),
          if (history.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = history[index];
                  if (itemBuilder != null) {
                    return itemBuilder!(item, index);
                  }
                  return _buildDefaultItem(item, index, effectiveConfig);
                },
                childCount: history.length,
              ),
            )
          else
            SliverToBoxAdapter(child: _buildEmptyState()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildDragIndicator() {
    return SliverToBoxAdapter(
      child: Container(
        height: 32,
        alignment: Alignment.topCenter,
        child: Container(
          width: 32,
          height: 3,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(ChallengeHistoryRankingConfig config) {
    return SliverToBoxAdapter(
      child: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          final screenWidth = MediaQuery.of(context).size.width;
          final isVeryNarrow = screenWidth < 400;
          
          // 根据屏幕宽度动态调整字体大小
          final titleFontSize = isVeryNarrow ? 14.0 : (isLandscape ? 16.0 : 18.0);
          final countFontSize = isVeryNarrow ? 9.0 : (isLandscape ? 10.0 : 11.0);
          
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isVeryNarrow ? 12 : (isLandscape ? 16 : 20),
              vertical: isVeryNarrow ? 8 : 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: isVeryNarrow ? 14 : 18,
                  decoration: BoxDecoration(
                    color: config.titleColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                SizedBox(width: isVeryNarrow ? 6 : 10),
                Expanded(
                  child: Text(
                    config.title,
                    style: TextStyle(
                      color: config.titleColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                      letterSpacing: isVeryNarrow ? 0.5 : 1.0,
                      shadows: [const Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVeryNarrow ? 6 : (isLandscape ? 8 : 10),
                    vertical: isVeryNarrow ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                  ),
                  child: Text(
                    '${history.length}',
                    style: TextStyle(
                      color: config.titleColor ?? Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: countFontSize,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          final screenWidth = MediaQuery.of(context).size.width;
          final isVeryNarrow = screenWidth < 400;
          
          // 根据屏幕宽度动态调整字体大小
          final headerFontSize = isVeryNarrow ? 11.0 : (isLandscape ? 12.0 : 13.0);
          
          return Padding(
            padding: EdgeInsets.only(
              left: isVeryNarrow ? 12 : (isLandscape ? 16 : 20),
              right: isVeryNarrow ? 12 : (isLandscape ? 16 : 20),
              top: 0,
              bottom: 2,
            ),
            child: Row(
              children: [
                // RANK 列 - 根据屏幕方向调整
                SizedBox(
                  width: isVeryNarrow ? 28 : (isLandscape ? 36 : 32),
                  child: Text(
                    'RANK',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: headerFontSize,
                      letterSpacing: isVeryNarrow ? 0.3 : 0.5,
                    ),
                  ),
                ),
                SizedBox(width: isVeryNarrow ? 4 : (isLandscape ? 8 : 6)),
                // NAME 列 - 根据屏幕方向调整
                SizedBox(
                  width: isVeryNarrow ? 40 : (isLandscape ? 70 : 55),
                  child: Text(
                    'NAME',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: headerFontSize,
                      letterSpacing: isVeryNarrow ? 0.3 : 0.5,
                    ),
                  ),
                ),
                SizedBox(width: isVeryNarrow ? 4 : (isLandscape ? 8 : 6)),
                // DATE 列 - 自适应宽度
                Expanded(
                  child: Text(
                    'DATE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: headerFontSize,
                      letterSpacing: isVeryNarrow ? 0.3 : 0.5,
                    ),
                  ),
                ),
                // COUNTS 列 - 根据屏幕方向调整
                SizedBox(
                  width: isVeryNarrow ? 40 : (isLandscape ? 60 : 50),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'COUNTS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: headerFontSize,
                        letterSpacing: isVeryNarrow ? 0.3 : 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultItem(ChallengeHistoryRankingItem item, int index, ChallengeHistoryRankingConfig config) {
    final isCurrent = item.isCurrent;
    
    return GestureDetector(
      onTap: onItemTap,
      child: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          final screenWidth = MediaQuery.of(context).size.width;
          final isVeryNarrow = screenWidth < 400;
          
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: isVeryNarrow ? 8 : (isLandscape ? 10 : 12),
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: isCurrent 
                  ? (config.currentItemColor ?? Colors.redAccent).withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isCurrent
                  ? Border.all(color: config.currentItemColor ?? Colors.redAccent, width: 2)
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isVeryNarrow ? 8 : (isLandscape ? 10 : 12),
                  vertical: isVeryNarrow ? 8 : 10,
                ),
                child: Row(
                  children: [
                    // RANK 列 - 根据屏幕方向调整
                    SizedBox(
                      width: isVeryNarrow ? 32 : (isLandscape ? 40 : 36),
                      child: _buildRankBadge(item, config),
                    ),
                    SizedBox(width: isVeryNarrow ? 6 : (isLandscape ? 12 : 8)),
                    // 名字列 - 根据屏幕方向调整，使用智能截断
                    SizedBox(
                      width: isVeryNarrow ? 45 : (isLandscape ? 80 : 60),
                      child: Tooltip(
                        message: item.name ?? 'Unknown',
                        child: Text(
                          item.getDisplayNameForWidth(screenWidth),
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: isVeryNarrow ? 6 : (isLandscape ? 12 : 8)),
                    // 日期列 - 自适应宽度
                    Expanded(
                      child: Text(
                        item.date,
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // COUNTS 列 - 根据屏幕方向调整
                    SizedBox(
                      width: isVeryNarrow ? 45 : (isLandscape ? 65 : 55),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '${item.counts}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.sports_esports,
                            color: isCurrent ? Colors.white : Colors.white54,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankBadge(ChallengeHistoryRankingItem item, ChallengeHistoryRankingConfig config) {
    final isCurrent = item.isCurrent;
    final isTopThree = item.isTopThree;
    
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isTopThree && !isCurrent && item.rank != null
            ? LinearGradient(
                colors: item.rank == 1
                    ? [const Color(0xFFFFF176), const Color(0xFFFFA500)]
                    : item.rank == 2
                        ? [const Color(0xFFB0BEC5), const Color(0xFF90A4AE)]
                        : [const Color(0xFFBCAAA4), const Color(0xFF8D6E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isCurrent
            ? (config.currentItemColor ?? Colors.redAccent)
            : (isTopThree ? null : Colors.white.withOpacity(0.10)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Text(
        item.rank != null ? '${item.rank}' : '...',
        style: TextStyle(
          color: isCurrent ? Colors.white : (isTopThree ? Colors.black : Colors.white),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }



  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage ?? 'No challengers yet! 🏆\nBe the first to make history!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to dominate the leaderboard? 💪',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
} 