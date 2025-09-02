import 'package:flutter/material.dart';

/// 历史排行榜数据模型
class HistoryRankingItem {
  final int? rank;
  final String date;
  final double countsPerMin;
  final String? note;
  final Map<String, dynamic>? additionalData;

  const HistoryRankingItem({
    this.rank,
    required this.date,
    required this.countsPerMin,
    this.note,
    this.additionalData,
  });

  /// 从Map创建实例
  factory HistoryRankingItem.fromMap(Map<String, dynamic> map) {
    return HistoryRankingItem(
      rank: map['rank'],
      date: map['date'] ?? '',
      countsPerMin: (map['countsPerMin'] as num?)?.toDouble() ?? 0.0,
      note: map['note'],
      additionalData: map,
    );
  }

  /// 是否为当前项目
  bool get isCurrent => note == 'current';
  
  /// 是否为前三名
  bool get isTopThree => rank != null && rank! <= 3;
}

/// 历史排行榜组件配置
class HistoryRankingConfig {
  final String title;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? currentItemColor;
  final double borderRadius;
  final EdgeInsets padding;

  const HistoryRankingConfig({
    this.title = 'TOP SCORES',
    this.backgroundColor,
    this.titleColor,
    this.currentItemColor,
    this.borderRadius = 28.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });
}

/// 通用历史排行榜组件
class HistoryRankingWidget extends StatelessWidget {
  final List<HistoryRankingItem> history;
  final ScrollController scrollController;
  final HistoryRankingConfig? config;
  final Widget Function(HistoryRankingItem item, int index)? itemBuilder;
  final VoidCallback? onItemTap;
  final String? emptyMessage;

  const HistoryRankingWidget({
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
    final effectiveConfig = config ?? const HistoryRankingConfig();
    
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

  Widget _buildTitleSection(HistoryRankingConfig config) {
    return SliverToBoxAdapter(
      child: Container(
        padding: config.padding,
        child: Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: config.titleColor ?? Colors.white,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              config.title,
              style: TextStyle(
                color: config.titleColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.0,
                shadows: [const Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 2),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                'RANK',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Expanded(
              child: Text(
                'DATE',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'PACE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultItem(HistoryRankingItem item, int index, HistoryRankingConfig config) {
    final isCurrent = item.isCurrent;
    
    return GestureDetector(
      onTap: onItemTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _buildRankBadge(item, config),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
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
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        _buildCurrentBadge(config),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.countsPerMin.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/min',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(HistoryRankingItem item, HistoryRankingConfig config) {
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

  Widget _buildCurrentBadge(HistoryRankingConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.currentItemColor ?? Colors.redAccent,
            (config.currentItemColor ?? Colors.redAccent).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: (config.currentItemColor ?? Colors.redAccent).withOpacity(0.18),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Text(
        'CURRENT',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
          letterSpacing: 0.6,
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
            emptyMessage ?? 'No records yet! 🏆\nStart your fitness journey!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your first workout could be legendary! 💪',
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