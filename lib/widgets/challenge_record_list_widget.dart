import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';
import 'dart:async'; // Added for Timer

/// 挑战记录数据模型
class ChallengeRecord {
  final int index;
  final String name;
  final String rank;
  final String status; // 'ended'、'ongoing' 或 'ready'
  final int timestep; // 时间戳
  final String? challengeId; // 挑战ID，用于跳转
  final VoidCallback? onTap;

  const ChallengeRecord({
    required this.index,
    required this.name,
    required this.rank,
    required this.status,
    required this.timestep,
    this.challengeId,
    this.onTap,
  });

  /// 从 Map 创建 ChallengeRecord
  factory ChallengeRecord.fromMap(Map<String, dynamic> map, {void Function(Map<String, dynamic>)? onTap}) {
    return ChallengeRecord(
      index: map['index'] as int,
      name: map['name'] as String,
      rank: map['rank'] as String,
      status: map['status'] as String,
      timestep: map['timestep'] as int,
      challengeId: map['challengeId'] as String?,
      onTap: onTap != null ? () => onTap!(map) : null,
    );
  }

  /// 格式化时间显示
  String get formattedTime {
    final now = DateTime.now();
    final time = DateTime.fromMillisecondsSinceEpoch(timestep);
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.year}/${time.month.toString().padLeft(2, '0')}/${time.day.toString().padLeft(2, '0')}';
  }

  /// 获取状态显示文本
  String get statusDisplayText {
    switch (status) {
      case 'ongoing':
        return 'Join Now!'; // 改为更明确的参与提示
      case 'ready':
        return 'Ready!'; // 新增：准备就绪状态
      case 'ended':
        return rank;
      default:
        return rank;
    }
  }

  /// 获取状态颜色
  Color get statusColor {
    switch (status) {
      case 'ongoing':
        return const Color(0xFF34C759); // 苹果系统绿色
      case 'ready':
        return const Color(0xFF007AFF); // 苹果系统蓝色
      case 'ended':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  /// 获取状态图标
  IconData get statusIcon {
    switch (status) {
      case 'ongoing':
        return Icons.play_circle_filled;
      case 'ready':
        return Icons.check_circle; // 新增：准备就绪图标
      case 'ended':
        return Icons.emoji_events;
      default:
        return Icons.emoji_events;
    }
  }

  /// 计算剩余时间（毫秒）
  int get remainingTime {
    final now = DateTime.now();
    final endTime = DateTime.fromMillisecondsSinceEpoch(timestep);
    final diff = endTime.difference(now);
    return diff.inMilliseconds > 0 ? diff.inMilliseconds : 0;
  }

  /// 格式化剩余时间显示
  String get formattedRemainingTime {
    final remaining = remainingTime;
    if (remaining <= 0) return 'Expired';
    
    final hours = remaining ~/ (1000 * 60 * 60);
    final minutes = (remaining % (1000 * 60 * 60)) ~/ (1000 * 60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m left';
    } else {
      return '< 1m left';
    }
  }

  /// 检查是否即将过期（小于1小时）
  bool get isExpiringSoon {
    return remainingTime < 1000 * 60 * 60; // 小于1小时
  }
}

/// 挑战记录列表组件
/// 支持自定义数据、样式、点击事件等
class ChallengeRecordListWidget extends StatefulWidget {
  /// 挑战记录列表
  final List<ChallengeRecord> records;
  
  /// 列表顶部内边距
  final EdgeInsets padding;
  
  /// 列表项之间的间距
  final EdgeInsets itemMargin;
  
  /// 卡片圆角半径
  final double cardBorderRadius;
  
  /// 卡片阴影
  final double cardElevation;
  
  /// 自定义样式配置
  final ChallengeRecordListStyle? style;
  
  /// 空数据时显示的组件
  final Widget? emptyWidget;
  
  /// 是否显示加载状态
  final bool isLoading;
  
  /// 加载状态组件
  final Widget? loadingWidget;
  
  /// 是否还有更多数据
  final bool hasMore;
  
  /// 加载更多回调
  final VoidCallback? onLoadMore;

  const ChallengeRecordListWidget({
    Key? key,
    required this.records,
    this.padding = const EdgeInsets.only(top: 12),
    this.itemMargin = const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    this.cardBorderRadius = 16.0,
    this.cardElevation = 1.0,
    this.style,
    this.emptyWidget,
    this.isLoading = false,
    this.loadingWidget,
    this.hasMore = false,
    this.onLoadMore,
  }) : super(key: key);

  @override
  State<ChallengeRecordListWidget> createState() => _ChallengeRecordListWidgetState();
}

class _ChallengeRecordListWidgetState extends State<ChallengeRecordListWidget> {
  Timer? _timer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // 启动定时器，每秒更新一次倒计时
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _safeUpdateState();
    });
  }

  /// 安全地更新状态，避免在布局过程中调用setState
  void _safeUpdateState() {
    if (!mounted) return;
    
    // 使用SchedulerBinding来确保在下一帧更新，避免在布局过程中调用setState
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          setState(() {
            // 触发重建以更新倒计时显示
          });
        } catch (e) {
          // 忽略setState错误，避免应用崩溃
          debugPrint('setState error in challenge_record_list_widget: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleLoadMore() {
    if (widget.onLoadMore != null && widget.hasMore && !widget.isLoading) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        widget.onLoadMore!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? const ChallengeRecordListStyle();
    
    if (widget.isLoading && widget.records.isEmpty) {
      return widget.loadingWidget ?? _buildLoadingWidget();
    }
    
    if (widget.records.isEmpty) {
      return widget.emptyWidget ?? _buildEmptyWidget();
    }

    return ListView.builder(
      key: const PageStorageKey('challengeList'),
      padding: widget.padding,
      itemCount: widget.records.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.records.length) {
          // Load More 按钮
          return _buildLoadMoreButton();
        }
        
        final record = widget.records[index];
        return _buildRecordItem(record, style);
      },
    );
  }

  /// 构建单个记录项
  Widget _buildRecordItem(ChallengeRecord record, ChallengeRecordListStyle style) {
    switch (record.status) {
      case 'ongoing':
        return _buildOngoingCard(record, style);
      case 'ready':
        return _buildReadyCard(record, style);
      case 'ended':
        return _buildEndedCard(record, style);
      default:
        return _buildEndedCard(record, style);
    }
  }

  /// 构建进行中的挑战卡片
  Widget _buildOngoingCard(ChallengeRecord record, ChallengeRecordListStyle style) {
    // 智能颜色选择 - 基于剩余时间动态调整
    final Color primaryColor = _getDynamicPrimaryColor(record);
    final Color accentColor = _getDynamicAccentColor(record);
    final Color backgroundColor = _getDynamicBackgroundColor(record);
    
    return Card(
      margin: widget.itemMargin,
      elevation: widget.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.cardBorderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.cardBorderRadius),
          onTap: record.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.cardBorderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor,
                  backgroundColor.withOpacity(0.9),
                  backgroundColor.withOpacity(0.7),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 倒计时区域 - 采用动态渐变色彩
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        accentColor,
                        primaryColor.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 动态倒计时图标
                      Icon(
                        _getDynamicIcon(record),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(height: 2),
                      // 剩余时间文本
                      Text(
                        record.formattedRemainingTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 内容区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: style.titleTextStyle.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // 状态标签 - 采用动态色彩胶囊（更克制的视觉权重）
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  primaryColor,
                                  accentColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.25),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              _getDynamicStatusText(record),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 提示文本 - 采用动态强调色（防止溢出）
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                _getDynamicHintText(record),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style.timeTextStyle.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 箭头指示器 - 采用动态色彩
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.15),
                        accentColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建准备就绪的挑战卡片
  Widget _buildReadyCard(ChallengeRecord record, ChallengeRecordListStyle style) {
    return Card(
      margin: widget.itemMargin,
      elevation: widget.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.cardBorderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.cardBorderRadius),
          onTap: record.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.cardBorderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF0F8FF), // 浅蓝色背景
                  const Color(0xFFE6F3FF),
                  const Color(0xFFD1ECFF),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              border: Border.all(
                color: const Color(0xFF007AFF).withOpacity(0.3),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007AFF).withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 准备就绪图标区域
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF007AFF),
                        const Color(0xFF5856D6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // 内容区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: style.titleTextStyle.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // 状态标签（更克制的视觉权重）
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFF007AFF),
                                  const Color(0xFF5856D6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF007AFF).withOpacity(0.25),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text(
                              'READY!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 提示文本（防止溢出）
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF007AFF).withOpacity(0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF007AFF).withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Tap to start!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style.timeTextStyle.copyWith(
                                  color: const Color(0xFF007AFF),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 箭头指示器
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF007AFF).withOpacity(0.15),
                        const Color(0xFF5856D6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF007AFF).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF007AFF),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建已结束的挑战卡片
  Widget _buildEndedCard(ChallengeRecord record, ChallengeRecordListStyle style) {
    return Card(
      margin: widget.itemMargin,
      elevation: widget.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.cardBorderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.cardBorderRadius),
          color: Colors.grey[50],
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 完成状态图标 - 采用苹果风格的简约设计
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // 内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.name,
                    style: style.titleTextStyle.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    record.formattedTime,
                    style: style.timeTextStyle.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // 排名标签 - 采用苹果风格的胶囊设计（固定在右侧）
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                record.statusDisplayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建加载更多按钮
  Widget _buildLoadMoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: ElevatedButton(
        onPressed: _handleLoadMore,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text('Load More'),
      ),
    );
  }

  /// 构建加载状态组件
  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// 构建空数据组件
  Widget _buildEmptyWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No challenges yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Participate in challenges to see your records here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 获取动态主色调 - 基于剩余时间智能选择
  Color _getDynamicPrimaryColor(ChallengeRecord record) {
    final remaining = record.remainingTime;
    final hours = remaining ~/ (1000 * 60 * 60);
    
    if (hours < 1) {
      // 小于1小时：苹果系统橙色 - 紧急但不平庸
      return const Color(0xFFFF9500);
    } else if (hours < 3) {
      // 1-3小时：苹果系统黄色 - 温和提醒
      return const Color(0xFFFFCC00);
    } else if (hours < 6) {
      // 3-6小时：苹果系统蓝色 - 平静但注意
      return const Color(0xFF007AFF);
    } else {
      // 大于6小时：苹果系统绿色 - 正常状态
      return const Color(0xFF34C759);
    }
  }

  /// 获取动态强调色 - 与主色调形成和谐搭配
  Color _getDynamicAccentColor(ChallengeRecord record) {
    final primaryColor = _getDynamicPrimaryColor(record);
    
    // 基于主色调智能选择强调色
    if (primaryColor == const Color(0xFFFF9500)) {
      return const Color(0xFFFF6B35); // 橙色配红橙
    } else if (primaryColor == const Color(0xFFFFCC00)) {
      return const Color(0xFFFF9500); // 黄色配橙色
    } else if (primaryColor == const Color(0xFF007AFF)) {
      return const Color(0xFF5856D6); // 蓝色配紫色
    } else {
      return const Color(0xFF30D158); // 绿色配亮绿
    }
  }

  /// 获取动态背景色 - 与主色调形成柔和对比
  Color _getDynamicBackgroundColor(ChallengeRecord record) {
    final primaryColor = _getDynamicPrimaryColor(record);
    
    // 基于主色调智能选择背景色
    if (primaryColor == const Color(0xFFFF9500)) {
      return const Color(0xFFFFF8F0); // 橙色配浅橙白
    } else if (primaryColor == const Color(0xFFFFCC00)) {
      return const Color(0xFFFFFDF0); // 黄色配浅黄白
    } else if (primaryColor == const Color(0xFF007AFF)) {
      return const Color(0xFFF0F8FF); // 蓝色配浅蓝白
    } else {
      return const Color(0xFFF0FFF0); // 绿色配浅绿白
    }
  }

  /// 获取动态图标 - 基于剩余时间选择合适图标
  IconData _getDynamicIcon(ChallengeRecord record) {
    final remaining = record.remainingTime;
    final hours = remaining ~/ (1000 * 60 * 60);
    
    if (hours < 1) {
      return Icons.warning_rounded; // 警告图标
    } else if (hours < 3) {
      return Icons.access_time_filled; // 时钟图标
    } else if (hours < 6) {
      return Icons.schedule; // 日程图标
    } else {
      return Icons.timer; // 定时器图标
    }
  }

  /// 获取动态状态文本 - 基于剩余时间选择合适文案
  String _getDynamicStatusText(ChallengeRecord record) {
    final remaining = record.remainingTime;
    final hours = remaining ~/ (1000 * 60 * 60);
    
    if (hours < 1) {
      return 'URGENT!'; // 紧急状态
    } else if (hours < 3) {
      return 'Hurry Up!'; // 快速提醒
    } else if (hours < 6) {
      return 'Join Soon!'; // 温和提醒
    } else {
      return 'Join Now!'; // 正常状态
    }
  }

  /// 获取动态提示文本 - 基于剩余时间选择合适提示
  String _getDynamicHintText(ChallengeRecord record) {
    final remaining = record.remainingTime;
    final hours = remaining ~/ (1000 * 60 * 60);
    
    if (hours < 1) {
      return 'Last chance!'; // 最后机会
    } else if (hours < 3) {
      return 'Almost expired!'; // 即将过期
    } else if (hours < 6) {
      return 'Limited time!'; // 限时参与
    } else {
      return 'Tap to join!'; // 正常提示
    }
  }

}

/// 挑战记录列表样式配置
class ChallengeRecordListStyle {
  /// 索引背景色
  final Color indexBackgroundColor;
  
  /// 索引文本样式
  final TextStyle indexTextStyle;
  
  /// 标题文本样式
  final TextStyle titleTextStyle;
  
  /// 排名文本样式
  final TextStyle rankTextStyle;

  /// 时间文本样式
  final TextStyle timeTextStyle;

  /// 进行中状态的颜色 - 采用苹果风格的鲜明绿色
  final Color ongoingStatusColor;

  /// 进行中状态的背景色 - 采用苹果风格的浅绿色渐变基础
  final Color ongoingBackgroundColor;

  const ChallengeRecordListStyle({
    this.indexBackgroundColor = AppColors.primary,
    this.indexTextStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    this.titleTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    this.rankTextStyle = const TextStyle(
      fontSize: 14,
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),
    this.timeTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
      fontWeight: FontWeight.w400,
    ),
    // 苹果风格的鲜明绿色，用于进行中的挑战
    this.ongoingStatusColor = const Color(0xFF34C759), // 苹果系统绿色
    // 苹果风格的浅绿色背景，提供柔和的视觉基础
    this.ongoingBackgroundColor = const Color(0xFFF2FCF5), // 非常浅的绿色
  });

  /// 创建深色主题样式
  ChallengeRecordListStyle copyWith({
    Color? indexBackgroundColor,
    TextStyle? indexTextStyle,
    TextStyle? titleTextStyle,
    TextStyle? rankTextStyle,
    TextStyle? timeTextStyle,
    Color? ongoingStatusColor,
    Color? ongoingBackgroundColor,
  }) {
    return ChallengeRecordListStyle(
      indexBackgroundColor: indexBackgroundColor ?? this.indexBackgroundColor,
      indexTextStyle: indexTextStyle ?? this.indexTextStyle,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      rankTextStyle: rankTextStyle ?? this.rankTextStyle,
      timeTextStyle: timeTextStyle ?? this.timeTextStyle,
      ongoingStatusColor: ongoingStatusColor ?? this.ongoingStatusColor,
      ongoingBackgroundColor: ongoingBackgroundColor ?? this.ongoingBackgroundColor,
    );
  }
}

/// 扩展方法：将Map列表转换为ChallengeRecord列表
extension ChallengeRecordListExtension on List<Map<String, dynamic>> {
  List<ChallengeRecord> toChallengeRecords({void Function(Map<String, dynamic>)? onTap}) {
    return map((map) => ChallengeRecord.fromMap(map, onTap: onTap)).toList();
  }
}
