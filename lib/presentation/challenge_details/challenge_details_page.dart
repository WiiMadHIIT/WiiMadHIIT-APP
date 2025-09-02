import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/floating_logo.dart';
import '../../widgets/challenge_rules_sheet.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';
import '../../routes/app_routes.dart';
import 'challenge_details_viewmodel.dart';
import '../../domain/entities/challenge_details/challenge_details.dart';
import '../../domain/entities/challenge_details/playoff_match.dart';
import '../../domain/entities/challenge_details/game_tracker_post.dart';
import '../../domain/entities/challenge_details/preseason_record.dart';
import '../../domain/usecases/get_challenge_details_usecase.dart';
import '../../data/repository/challenge_details_repository.dart';
import '../../data/api/challenge_details_api.dart';
import '../../domain/services/challenge_details_service.dart';

// 定义playoff阶段枚举
enum PlayoffStage { round32, round16, round8, round4, semi, finalMatch }

// 季后赛阶段名称映射
Map<PlayoffStage, String> getPlayoffStageNames(Map<String, String>? stages) {
  if (stages == null) {
    return {
      PlayoffStage.round32: '1/32 PLAYOFF',
      PlayoffStage.round16: '1/16 FINALS',
      PlayoffStage.round8: '1/8 FINALS',
      PlayoffStage.round4: '1/4 FINALS',
      PlayoffStage.semi: 'SEMI FINAL',
      PlayoffStage.finalMatch: 'FINAL',
    };
  }
  
  return {
    PlayoffStage.round32: stages['round32'] ?? '1/32 PLAYOFF',
    PlayoffStage.round16: stages['round16'] ?? '1/16 FINALS',
    PlayoffStage.round8: stages['round8'] ?? '1/8 FINALS',
    PlayoffStage.round4: stages['round4'] ?? '1/4 FINALS',
    PlayoffStage.semi: stages['semi'] ?? 'SEMI FINAL',
    PlayoffStage.finalMatch: stages['finalMatch'] ?? 'FINAL',
  };
}

/// 挑战详情页面，包含规则卡片、功能入口、Tab页面等
class ChallengeDetailsPage extends StatelessWidget {
  const ChallengeDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChallengeDetailsViewModel(
        getChallengeBasicUseCase: GetChallengeBasicUseCase(
          ChallengeDetailsRepository(
            ChallengeDetailsApi(),
          ),
        ),
        getChallengePlayoffsUseCase: GetChallengePlayoffsUseCase(
          ChallengeDetailsRepository(
            ChallengeDetailsApi(),
          ),
        ),
        getChallengePreseasonUseCase: GetChallengePreseasonUseCase(
          ChallengeDetailsRepository(
            ChallengeDetailsApi(),
          ),
        ),
        challengeDetailsService: ChallengeDetailsService(),
      ),
      child: const _ChallengeDetailsPageContent(),
    );
  }

  /// 从路由参数获取挑战ID
  String _getChallengeId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['challengeId'] as String? ?? 'default';
  }
}

class _ChallengeDetailsPageContent extends StatefulWidget {
  const _ChallengeDetailsPageContent({Key? key}) : super(key: key);

  @override
  State<_ChallengeDetailsPageContent> createState() => _ChallengeDetailsPageContentState();
}

class _ChallengeDetailsPageContentState extends State<_ChallengeDetailsPageContent> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  
  // ViewModel 引用
  ChallengeDetailsViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    
    // 添加Tab切换监听器，实现按需加载
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final challengeId = args?['challengeId'] as String? ?? 'default';
        
        // 根据Tab索引按需加载数据
        switch (_tabController.index) {
          case 1: // Preseason Tab
            if (_viewModel?.preseasonData == null && !(_viewModel?.isPreseasonLoading ?? false)) {
              _viewModel?.loadChallengePreseason(challengeId);
            }
            break;
          case 2: // Playoffs Tab
            if (_viewModel?.playoffData == null && !(_viewModel?.isPlayoffsLoading ?? false)) {
              _viewModel?.loadChallengePlayoffs(challengeId);
            }
            break;
        }
      }
    });
    
    // 加载挑战详情数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final challengeId = args?['challengeId'] as String? ?? 'default';
      _viewModel = Provider.of<ChallengeDetailsViewModel>(context, listen: false);
      
      // 检查是否有缓存数据，如果有则取消清理定时器
      if (_viewModel!.hasCachedData) {
        _viewModel!.cancelCleanup();
      } else {
        // 只加载基础数据，其他数据按需加载
        _viewModel!.loadChallengeBasic(challengeId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    
    // 智能延迟清理：延迟清理数据以提升用户体验
    if (_viewModel != null) {
      _viewModel!.scheduleCleanup();
    }
    
    super.dispose();
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!,
            Colors.purple[600]!,
            Colors.orange[500]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Challenge Ready!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeDetailsViewModel>(
      builder: (context, viewModel, child) {
        // 显示加载状态（只检查基础数据加载）
        if (viewModel.isBasicLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                const Center(child: CircularProgressIndicator()),
                // 左上角返回按钮
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87,
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                      tooltip: 'Back',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 显示错误状态（只检查基础数据错误）
        if (viewModel.basicError != null) {
          // 打印错误到控制台而不是显示给用户
          print('Challenge details error: ${viewModel.basicError}');
          
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please try again later',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                          final challengeId = args?['challengeId'] as String? ?? 'default';
                          // 重新加载基础数据
                          viewModel.loadChallengeBasic(challengeId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                // 左上角返回按钮
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87,
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                      tooltip: 'Back',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 获取数据源
        final challengeBasic = viewModel.challengeBasic;
        final playoffData = viewModel.playoffData;
        final preseasonData = viewModel.preseasonData;
        final gameTracker = viewModel.gameTracker;
        final rules = viewModel.rules;
        final challengeName = viewModel.challengeName;
        final backgroundImage = viewModel.backgroundImage;
        final videoUrl = viewModel.videoUrl;

        // 如果没有基础数据，显示空状态
        if (challengeBasic == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_esports_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Challenge went MIA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Maybe it\'s taking a coffee break?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 左上角返回按钮
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87,
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                      tooltip: 'Back',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final double bottomPadding = MediaQuery.of(context).padding.bottom;
        return Scaffold(
          backgroundColor: Colors.white,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
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
                      backgroundImage.isNotEmpty && backgroundImage != 'null'
                        ? Image.network(
                            backgroundImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // 远程图片加载失败时显示本地备用图片
                              return _buildFallbackBackground();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildFallbackBackground(),
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
                            stops: const [0, 0.5, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _RuleCard(
                          rules: rules,
                          challengeName: challengeName,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 5)),
              SliverToBoxAdapter(child: _FeatureEntryCard(
                videoUrl: videoUrl,
                onVideo: () {
                  if (videoUrl.isNotEmpty && videoUrl != 'null') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _FullScreenVideoPage(videoUrl: videoUrl)),
                    );
                  } else {
                    // 没有视频时的幽默提示
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎬 Video still in production!'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onJoin: () {
                  // 获取挑战ID
                  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                  final challengeId = args?['challengeId'] as String? ?? 'default';
                  Navigator.pushNamed(
                    context,
                    AppRoutes.challengeRule,
                    arguments: {'challengeId': challengeId},
                  );
                },
              )),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey[500],
                    labelStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: AppTextStyles.titleMedium,
                    tabs: const [
                      Tab(text: 'Game Tracker'),
                      Tab(text: 'Preseason'),
                      Tab(text: 'Playoffs'),
                    ],
                  ),
                ),
              ),
            ],
            body: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _GameTrackerTab(posts: gameTracker?.posts ?? []),
                  _PreseasonRecordList(
                    preseason: preseasonData,
                    isLoading: viewModel.isPreseasonLoading,
                    onLoadMore: () {
                      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                      final challengeId = args?['challengeId'] as String? ?? 'default';
                      _viewModel?.loadChallengePreseasonNextPage(challengeId);
                    },
                  ),
                  _PlayoffBracket(
                    playoffs: playoffData,
                    isLoading: viewModel.isPlayoffsLoading,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RuleCard extends StatelessWidget {
  final ChallengeRules? rules;
  final String? challengeName;
  final VoidCallback? onMore;
  
  const _RuleCard({
    this.rules, 
    this.challengeName,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    // 检查是否有规则数据
    final hasRules = rules != null && rules!.title.isNotEmpty;
    final hasChallengeName = challengeName != null && challengeName!.isNotEmpty;
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 挑战名称显示
            if (hasChallengeName) ...[
              Text(
                challengeName!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 20,
                ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ] else ...[
              Text(
                'Mystery Challenge',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 20,
                ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
            ],
            
            // 规则部分
            if (hasRules) ...[
              Text(
                rules!.details,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[800], 
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onMore ?? () {
                    showChallengeRulesSheet(
                      context: context,
                      rules: rules!,
                      challengeName: challengeName ?? 'Challenge',
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Learn More'),
                ),
              ),
            ] else ...[
              // 没有规则时的幽默提示
              Row(
                children: [
                  Icon(Icons.rule, color: Colors.grey[400], size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Rules? What Rules?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Just wing it! 🎯',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600], 
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Rules coming soon...',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureEntryCard extends StatelessWidget {
  final String? videoUrl;
  final VoidCallback? onVideo;
  final VoidCallback? onJoin;
  
  const _FeatureEntryCard({this.videoUrl, this.onVideo, this.onJoin});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final hasVideo = videoUrl != null && videoUrl!.isNotEmpty && videoUrl != 'null';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      elevation: 0,
      color: Colors.white.withOpacity(0.98),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onVideo ?? () {},
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 0)),
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      return hasVideo ? null : Colors.grey[400];
                    }),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    overlayColor: MaterialStateProperty.all(primary.withOpacity(0.08)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: hasVideo 
                        ? LinearGradient(
                            colors: [primary, primary.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey[400]!, Colors.grey[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasVideo ? Icons.play_circle_fill : Icons.play_circle_outline, 
                            size: 20, 
                            color: Colors.white
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              hasVideo ? 'Video Intro' : 'Coming Soon',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: onJoin ?? () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: primary, width: 1.5),
                    backgroundColor: Colors.black,
                    foregroundColor: primary,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, size: 18, color: primary),
                      const SizedBox(width: 7),
                      const Flexible(
                        child: Text('Join Now',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreseasonRecordList extends StatelessWidget {
  final PreseasonData? preseason;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  
  const _PreseasonRecordList({
    this.preseason,
    this.isLoading = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    // 显示加载状态
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 创意加载动画
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.sports_score,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 幽默的加载文案
            Text(
              'Warming up the stats... 🔥',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our servers are doing jumping jacks',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
              ),
            ),
          ],
        ),
      );
    }
    
    if (preseason == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_score_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No preseason data yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The season hasn\'t started!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              'Preseason is warming up! 🔥',  // 简化显示，公告信息现在在基础信息中
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ) ?? const TextStyle(fontSize: 15, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: preseason!.records.isNotEmpty 
            ? ListView.builder(
                key: const PageStorageKey('preseasonList'),
                padding: const EdgeInsets.only(top: 0),
                itemCount: preseason!.records.length + (preseason!.pagination.currentPage < preseason!.pagination.totalPages ? 1 : 0),
                itemBuilder: (context, i) {
                  // 如果是最后一项且还有更多页，显示加载更多按钮
                  if (i == preseason!.records.length && preseason!.pagination.currentPage < preseason!.pagination.totalPages) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Center(
                        child: isLoading 
                          ? Column(
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
                                  'Loading more records... 📊',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          : ElevatedButton(
                              onPressed: onLoadMore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Load More'),
                            ),
                      ),
                    );
                  }
                  
                  final record = preseason!.records[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${record.index}')),
                      title: Text(record.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      trailing: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: record.rank,
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                            ),
                            TextSpan(
                              text: '  [${record.counts}]',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No records yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to make history! 🏆',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}

class _FullScreenVideoPage extends StatefulWidget {
  final String videoUrl;
  
  const _FullScreenVideoPage({required this.videoUrl});
  
  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        // 确保音量设置为最大值（有声音）
        _controller.setVolume(1.0);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.red, size: 28),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayoffBracket extends StatefulWidget {
  final PlayoffData? playoffs;
  final bool isLoading;
  
  const _PlayoffBracket({
    this.playoffs,
    this.isLoading = false,
  });
  
  @override
  State<_PlayoffBracket> createState() => _PlayoffBracketState();
}

class _PlayoffBracketState extends State<_PlayoffBracket> {
  PlayoffStage _selectedStage = PlayoffStage.round8;

  @override
  Widget build(BuildContext context) {
    // 显示加载状态
    if (widget.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 创意加载动画
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.purple[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 幽默的加载文案
            Text(
              'Setting up the bracket... 🏆',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The tournament gods are working overtime',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[400]!),
              ),
            ),
          ],
        ),
      );
    }
    
    if (widget.playoffs == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Playoffs not ready yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Still in regular season! 📅',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    final stageNames = getPlayoffStageNames(widget.playoffs!.stages);
    final matches = widget.playoffs!.matches;
    
    // 根据选择的阶段获取对应的比赛数据
    List<PlayoffMatch> stageMatches = [];
    switch (_selectedStage) {
      case PlayoffStage.round32:
        stageMatches = matches['round32'] ?? [];
        break;
      case PlayoffStage.round16:
        stageMatches = matches['round16'] ?? [];
        break;
      case PlayoffStage.round8:
        stageMatches = matches['round8'] ?? [];
        break;
      case PlayoffStage.round4:
        stageMatches = matches['round4'] ?? [];
        break;
      case PlayoffStage.semi:
        stageMatches = matches['semi'] ?? [];
        break;
      case PlayoffStage.finalMatch:
        stageMatches = matches['finalMatch'] ?? [];
        break;
    }
    
    return Container(
      color: const Color(0xFFF7F8FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部分段选择器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PlayoffStage.values.map((stage) {
                  final selected = _selectedStage == stage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStage = stage),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 18),
                        decoration: BoxDecoration(
                          color: selected ? Colors.black : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: selected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                        ),
                        child: Text(
                          stageNames[stage]!,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 分组对阵
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              itemCount: stageMatches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final match = stageMatches[i];
                return _PlayoffMatchCard(match: match);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayoffMatchCard extends StatelessWidget {
  final PlayoffMatch match;
  
  const _PlayoffMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final bool hasData = match.name1 != null || match.name2 != null;
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFE5E6EB);
    final Gradient cardGradient = LinearGradient(
      colors: [
        Theme.of(context).primaryColor.withOpacity(0.08),
        Colors.white,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      child: hasData ? Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _PlayoffUserCell(
              avatar: match.avatar1,
              name: match.name1,
              isWinner: (match.score1 ?? 0) > (match.score2 ?? 0),
              score: match.score1,
              alignRight: false,
            ),
          ),
          // VS圆形徽章
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.18),
                    blurRadius: 8,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _PlayoffUserCell(
              avatar: match.avatar2,
              name: match.name2,
              isWinner: (match.score2 ?? 0) > (match.score1 ?? 0),
              score: match.score2,
              alignRight: true,
            ),
          ),
        ],
      ) : const SizedBox(height: 32),
    );
  }
}

class _PlayoffUserCell extends StatelessWidget {
  final String? avatar;
  final String? name;
  final bool isWinner;
  final int? score;
  final bool alignRight;
  
  const _PlayoffUserCell({
    this.avatar, 
    this.name, 
    this.isWinner = false, 
    this.score, 
    this.alignRight = false
  });

  @override
  Widget build(BuildContext context) {
    if (name == null) {
      return const SizedBox(width: 100);
    }
    
    return Row(
      mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (!alignRight) ...[
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
            child: avatar == null ? const Icon(Icons.person, color: Colors.grey, size: 20) : null,
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        name!,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isWinner && score != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.emoji_events, color: Colors.amber, size: 22, shadows: [Shadow(color: Colors.amber, blurRadius: 6)]),
                    ),
                ],
              ),
              if (score != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                      shadows: [Shadow(color: Theme.of(context).primaryColor.withOpacity(0.12), blurRadius: 4)],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (alignRight) ...[
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
            child: avatar == null ? const Icon(Icons.person, color: Colors.grey, size: 20) : null,
          ),
        ],
      ],
    );
  }
}

class _GameTrackerTab extends StatelessWidget {
  final List<GameTrackerPost>? posts;
  
  const _GameTrackerTab({this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts == null || posts!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No game updates yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The game is still loading... 🎮',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    // 按时间倒序
    final sortedPosts = List<GameTrackerPost>.from(posts!)
      ..sort((a, b) => b.timestep.compareTo(a.timestep));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: sortedPosts.map((post) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _GameTrackerCard(
            announcement: post.announcement,
            imageUrl: post.image,
            desc: post.desc,
            timestep: post.timestep,
          ),
        )).toList(),
      ),
    );
  }
}

class _GameTrackerCard extends StatelessWidget {
  final String? announcement;
  final String? imageUrl;
  final String? desc;
  final int timestep;
  
  const _GameTrackerCard({
    this.announcement,
    this.imageUrl,
    this.desc,
    required this.timestep,
  });

  String _formatTime(int timestamp) {
    final now = DateTime.now();
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.year}/${time.month.toString().padLeft(2, '0')}/${time.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    // 时间
    children.add(Row(
      children: [
        Icon(Icons.access_time, color: Colors.grey[500], size: 18),
        const SizedBox(width: 6),
        Text(
          _formatTime(timestep),
          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2),
        ),
      ],
    ));
    if (imageUrl != null || announcement != null || desc != null) {
      children.add(const SizedBox(height: 10));
    }

    // 图片
    if (imageUrl != null) {
      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // 远程图片加载失败时显示本地备用图片
                  return Image.asset(
                    'assets/images/player_cover.png',
                    fit: BoxFit.contain,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      if (announcement != null || desc != null) {
        children.add(const SizedBox(height: 16));
      }
    }

    // 标题
    if (announcement != null) {
      children.add(
        Text(
          announcement!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.4,
              ) ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      );
      if (desc != null) {
        children.add(const SizedBox(height: 8));
      }
    }

    // 描述
    if (desc != null) {
      children.add(
        Text(
          desc!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
} 