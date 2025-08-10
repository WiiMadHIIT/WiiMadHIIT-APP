import 'package:flutter/material.dart';

class TrainingHistoryRankingWidget extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final ScrollController scrollController;
  final String title;
  final bool showCount;
  final String? currentNote;
  final String? rankField;
  final String? dateField;
  final String? timeField;
  final String? noteField;
  final String? secondsField;
  final Function(int)? onItemTap;
  final Widget? customHeader;
  final Widget? customFooter;

  const TrainingHistoryRankingWidget({
    Key? key,
    required this.history,
    required this.scrollController,
    this.title = 'TOP SCORES',
    this.showCount = true,
    this.currentNote = 'current',
    this.rankField = 'rank',
    this.dateField = 'date',
    this.timeField = 'time',
    this.noteField = 'note',
    this.secondsField = 'seconds',
    this.onItemTap,
    this.customHeader,
    this.customFooter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
          SliverToBoxAdapter(
            child: Column(
              children: [
                // 顶部大面积可拖动区域
                Container(
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
                // 自定义头部或默认头部
                customHeader ?? _buildDefaultHeader(),
                // 榜单表头
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text('RANK', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                      ),
                      Expanded(
                        child: Text('DATE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                      ),
                      SizedBox(
                        width: 60,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('TIME', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final e = history[index];
                final isCurrent = e[noteField] == currentNote;
                final isTopThree = e[rankField] != null && e[rankField] <= 3;
                
                return GestureDetector(
                  onTap: onItemTap != null ? () => onItemTap!(index) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCurrent 
                          ? Colors.white.withOpacity(0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent
                          ? Border.all(color: Colors.redAccent, width: 2)
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // 排名徽章
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: isTopThree && !isCurrent && e[rankField] != null
                                    ? LinearGradient(
                                       colors: e[rankField] == 1
                                           ? [Color(0xFFFFF176), Color(0xFFFFA500)]
                                           : e[rankField] == 2
                                               ? [Color(0xFFB0BEC5), Color(0xFF90A4AE)]
                                               : [Color(0xFFBCAAA4), Color(0xFF8D6E63)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isCurrent
                                    ? Colors.redAccent
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
                                e[rankField] != null ? '${e[rankField]}' : '...',
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : (isTopThree ? Colors.black : Colors.white),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 日期和当前标识
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      e[dateField] ?? '',
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.redAccent, Colors.red],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.redAccent.withOpacity(0.18),
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
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // seconds展示 - 转换为MM:SS格式
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(e[secondsField] ?? 0),
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.timer,
                                  color: isCurrent ? Colors.white : Colors.white54,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: history.length,
            ),
          ),
          // 自定义底部或默认底部
          if (customFooter != null)
            SliverToBoxAdapter(child: customFooter!)
          else
            SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildDefaultHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.0,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
          const Spacer(),
          if (showCount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
              ),
              child: Text(
                '${history.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
} 