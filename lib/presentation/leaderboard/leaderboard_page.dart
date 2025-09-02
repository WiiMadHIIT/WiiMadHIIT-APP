import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../widgets/floating_logo.dart';
import 'leaderboard_viewmodel.dart';
import '../../domain/usecases/get_leaderboards_usecase.dart';
import '../../data/repository/leaderboard_repository.dart';
import '../../data/api/leaderboard_api.dart';
import '../../domain/entities/leaderboard/leaderboard.dart';

class LeaderboardPage extends StatelessWidget {
  LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repository = LeaderboardRepositoryImpl(LeaderboardApi());
    return ChangeNotifierProvider(
      create: (_) => LeaderboardViewModel(
        getLeaderboardsUseCase: GetLeaderboardsUseCase(repository),
        getLeaderboardRankingsUseCase: GetLeaderboardRankingsUseCase(repository),
      ),
      child: const _LeaderboardContent(),
    );
  }
}

class _LeaderboardContent extends StatefulWidget {
  const _LeaderboardContent({Key? key}) : super(key: key);

  @override
  State<_LeaderboardContent> createState() => _LeaderboardContentState();
}

class _LeaderboardContentState extends State<_LeaderboardContent> {
  // ViewModel 引用
  LeaderboardViewModel? _viewModel;
  
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // 添加滚动监听器
    _scrollController.addListener(_onScroll);
    
    // 延迟初始化，确保在build之后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = Provider.of<LeaderboardViewModel>(context, listen: false);
        _viewModel = viewModel;
        
        // 检查是否有缓存数据，如果有则取消清理定时器
        if (viewModel.hasCachedData) {
          viewModel.cancelCleanup();
        } else {
          // 加载排行榜数据
          viewModel.loadLeaderboards();
        }
      }
    });
  }

  // 滚动监听：检测滚动到底部时自动加载更多
  void _onScroll() {
    if (_viewModel == null) return;
    
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // 距离底部200像素时触发加载更多
      if (_viewModel!.hasNextPage && !_viewModel!.isLoading && !_viewModel!.isLoadingMore) {
        _viewModel!.loadNextPage();
      }
    }
  }

  @override
  void dispose() {
    // 移除滚动监听器
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    
    // 智能延迟清理：延迟清理数据以提升用户体验
    if (_viewModel != null) {
      _viewModel!.scheduleCleanup();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double expandedHeight = 180;
    final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

    return Consumer<LeaderboardViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors.primary,
                    expandedHeight: expandedHeight,
                    pinned: true,
                    elevation: 0,
                    automaticallyImplyLeading: false,
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
                  if (viewModel.isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (viewModel.hasError)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Oops! Leaderboard took a coffee break ☕',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (!viewModel.hasData)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No leaderboards yet',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, idx) {
                            // 检查是否是加载更多项
                            if (idx >= viewModel.boards.length) {
                              // 显示加载更多指示器
                              if (viewModel.isLoadingMore) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Loading more leaderboards...',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              // 检查是否还有更多数据
                              if (viewModel.hasNextPage) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white70,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Scroll to load more',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // 已到达最后一页，显示友好提示
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: Colors.white70,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '🎉 You\'ve reached the end!',
                                        style: AppTextStyles.titleMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'All leaderboards have been loaded. Great job exploring! 🚀',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                            
                            final board = viewModel.boards[idx];
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            board.activity,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.titleLarge.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.people, color: AppColors.primary, size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${board.participants} joined',
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text('RANK', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('USER', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey, fontWeight: FontWeight.bold)),
                                        ),
                                        Expanded(
                                          child: Text('COUNTS', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...List.generate(board.rankings.length, (i) {
                                      final r = board.rankings[i];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${r.rank}',
                                                style: AppTextStyles.bodyMedium.copyWith(
                                                  color: r.rank == 1 ? AppColors.primary : Colors.black87,
                                                  fontWeight: r.rank == 1 ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                r.user,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.bodyMedium.copyWith(
                                                  color: r.rank == 1 ? AppColors.primary : Colors.black87,
                                                  fontWeight: r.rank == 1 ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${r.counts}',
                                                style: AppTextStyles.bodyMedium.copyWith(
                                                  color: r.rank == 1 ? AppColors.primary : Colors.black87,
                                                  fontWeight: r.rank == 1 ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                                        const SizedBox(height: 6),
                                        Expanded(
                                          child: Text(
                                            'Top Winner: ${board.topUser.name}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          viewModel.showFullSheet(board.challengeId, board.activity);
                                        },
                                        child: Text(
                                          '👀 See who else is sweating',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.labelMedium.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: viewModel.boards.length + (viewModel.hasNextPage ? 1 : 0),
                        ),
                      ),
                    ),
                ],
              ),
              if (_viewModel?.isFullSheetVisible == true)
                _LeaderboardFullSheet(
                  challengeId: _viewModel!.currentChallengeId!,
                  title: _viewModel!.currentChallengeTitle!,
                  onClose: () => _viewModel!.hideFullSheet(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class LogoContent extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  const LogoContent({super.key, this.margin});

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

class _LeaderboardFullSheet extends StatefulWidget {
  final String challengeId;
  final String title;
  final VoidCallback onClose;

  const _LeaderboardFullSheet({
    super.key,
    required this.challengeId,
    required this.title,
    required this.onClose,
  });

  @override
  State<_LeaderboardFullSheet> createState() => _LeaderboardFullSheetState();
}

class _LeaderboardFullSheetState extends State<_LeaderboardFullSheet> {
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 16;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 使用 addPostFrameCallback 避免在 build 阶段调用 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Column(
          children: [
            const Spacer(),
            Container(
              height: media.size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildGrabber(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.close, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildHeaderRow(),
                  const SizedBox(height: 6),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrabber() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'RANK',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'USER',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'COUNTS',
              textAlign: TextAlign.right,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _loadInitialData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'No rankings yet',
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<LeaderboardViewModel>(
      builder: (context, viewModel, _) {
        final isLoading = viewModel.isRankingsLoading(widget.challengeId);
        final isLoadingMore = viewModel.isRankingsLoadingMore(widget.challengeId);
        final hasError = viewModel.hasRankingsError(widget.challengeId);
        final errorMessage = viewModel.getRankingsError(widget.challengeId);
        final items = viewModel.getRankingsItems(widget.challengeId);
        final total = viewModel.getRankingsTotal(widget.challengeId);

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (hasError) {
          return _buildError(context, errorMessage ?? 'Unknown error');
        }
        if (items.isEmpty) {
          return _buildEmpty();
        }

        return ListView.separated(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Loading more...', style: TextStyle(color: Colors.black87)),
                  ],
                ),
              );
            }
            final item = items[index];
            return _RankingRow(item: item);
          },
          separatorBuilder: (_, __) => Divider(
            color: Colors.grey.withOpacity(0.2),
            height: 10,
            thickness: 1,
          ),
          itemCount: items.length + (isLoadingMore ? 1 : 0),
        );
      },
    );
  }

  void _onScroll() {
    final viewModel = Provider.of<LeaderboardViewModel>(context, listen: false);
    if (viewModel.isRankingsLoadingMore(widget.challengeId) || 
        viewModel.isRankingsLoading(widget.challengeId)) return;
    if (!viewModel.hasMoreRankings(widget.challengeId)) return;
    if (!_scrollController.hasClients) return;
    
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (max - offset < 200) {
      final nextPage = viewModel.getRankingsCurrentPage(widget.challengeId) + 1;
      viewModel.loadRankingsPage(
        challengeId: widget.challengeId,
        page: nextPage,
        pageSize: _pageSize,
      );
    }
  }

  void _loadInitialData() {
    final viewModel = Provider.of<LeaderboardViewModel>(context, listen: false);
    viewModel.loadRankingsPage(
      challengeId: widget.challengeId,
      page: 1,
      pageSize: _pageSize,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    
    try {
      final viewModel = Provider.of<LeaderboardViewModel>(context, listen: false);
      viewModel.clearRankingsCache(widget.challengeId);
    } catch (e) {
      // 忽略错误，确保 dispose 正常完成
    }
    
    super.dispose();
  }
}

class _RankingRow extends StatelessWidget {
  final RankingItem item;

  const _RankingRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isTop = item.rank == 1;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isTop ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.rank}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isTop ? AppColors.primary : Colors.black87,
                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _AvatarPlaceholder(name: item.user),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.user,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isTop ? AppColors.primary : Colors.black87,
                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${item.counts}',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isTop ? AppColors.primary : Colors.black87,
                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final String name;

  const _AvatarPlaceholder({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.6), AppColors.primary.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
