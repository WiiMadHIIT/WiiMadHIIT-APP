import 'package:flutter/material.dart';
import 'dart:async';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';
import 'challenge_record_list_widget.dart';

/// Profile页面的挑战记录列表组件
/// 支持下滑加载更多和防抖动
class ProfileChallengeRecordList extends StatefulWidget {
  final List<Map<String, dynamic>> records;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetry;
  final Function(Map<String, dynamic>)? onRecordTap;

  const ProfileChallengeRecordList({
    Key? key,
    required this.records,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
    this.onRetry,
    this.onRecordTap,
  }) : super(key: key);

  @override
  State<ProfileChallengeRecordList> createState() => _ProfileChallengeRecordListState();
}

class _ProfileChallengeRecordListState extends State<ProfileChallengeRecordList> {
  late ScrollController _scrollController;
  Timer? _debounceTimer;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) return;

    // 防抖动：300ms延迟
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && !_isLoadingMore && widget.hasMore) {
        setState(() {
          _isLoadingMore = true;
        });
        widget.onLoadMore!();
        
        // 重置加载状态
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.records.isEmpty) {
      return _buildInitialLoading();
    }

    if (widget.records.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            key: const PageStorageKey('profileChallengeList'),
            padding: const EdgeInsets.only(top: 12),
            itemCount: widget.records.length + (widget.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.records.length) {
                return _buildLoadMoreIndicator();
              }

              final record = widget.records[index];
              return _buildRecordItem(record);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> record) {
    final challengeRecord = ChallengeRecord.fromMap(record, onTap: widget.onRecordTap);
    final style = const ChallengeRecordListStyle(
      indexBackgroundColor: AppColors.primary,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      rankTextStyle: TextStyle(
        fontSize: 14,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      timeTextStyle: TextStyle(
        fontSize: 12,
        color: Colors.grey,
        fontWeight: FontWeight.w400,
      ),
      ongoingStatusColor: Color(0xFF00C851),
      ongoingBackgroundColor: Color(0xFFF0FFF4),
    );
    
    return _buildSingleRecordItem(challengeRecord, style);
  }

  /// 构建单个记录项（从ChallengeRecordListWidget复制并修改）
  Widget _buildSingleRecordItem(ChallengeRecord record, ChallengeRecordListStyle style) {
    if (record.status == 'ongoing') {
      return _buildOngoingCard(record, style);
    } else if (record.status == 'ready') {
      return _buildReadyCard(record, style);
    } else {
      return _buildEndedCard(record, style);
    }
  }

  /// 构建进行中的卡片
  Widget _buildOngoingCard(ChallengeRecord record, ChallengeRecordListStyle style) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: record.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 序号
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: style.indexBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${record.index}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: style.titleTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: style.ongoingBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Ongoing',
                              style: TextStyle(
                                color: style.ongoingStatusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            record.formattedTime,
                            style: style.timeTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 排名
                Text(
                  record.rank,
                  style: style.rankTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建准备中的卡片
  Widget _buildReadyCard(ChallengeRecord record, ChallengeRecordListStyle style) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: record.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 序号
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: style.indexBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${record.index}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: style.titleTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Ready',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            record.formattedTime,
                            style: style.timeTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 排名
                Text(
                  record.rank,
                  style: style.rankTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建已结束的卡片
  Widget _buildEndedCard(ChallengeRecord record, ChallengeRecordListStyle style) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: record.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 序号
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: style.indexBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${record.index}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: style.titleTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Ended',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            record.formattedTime,
                            style: style.timeTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 排名
                Text(
                  record.rank,
                  style: style.rankTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_isLoadingMore) {
      return _buildLoadingMore();
    }

    if (!widget.hasMore) {
      return _buildNoMoreData();
    }

    return _buildLoadMoreButton();
  }

  Widget _buildLoadingMore() {
    final loadingMessages = [
      'Fetching more quests...',
      'Loading epic battles...',
      'Gathering champions...',
      'Summoning warriors...',
      'Preparing challenges...',
    ];
    
    final message = loadingMessages[DateTime.now().millisecond % loadingMessages.length];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreData() {
    final noMoreMessages = [
      'No more quests... yet 📜',
      'All challenges conquered! 🏆',
      'That\'s all, folks! 🎭',
      'End of the adventure! 🗺️',
      'No more battles to fight! ⚔️',
    ];
    
    final message = noMoreMessages[DateTime.now().millisecond % noMoreMessages.length];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ElevatedButton(
          onPressed: widget.onLoadMore,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Summon 🔄'),
        ),
      ),
    );
  }

  Widget _buildInitialLoading() {
    return const SizedBox(
      height: 240,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, color: Colors.grey[400], size: 48),
            const SizedBox(height: 12),
            Text(
              'No past challenges yet 📜',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (widget.onRetry != null)
              TextButton(
                onPressed: widget.onRetry,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Rewind'),
              ),
          ],
        ),
      ),
    );
  }
}
