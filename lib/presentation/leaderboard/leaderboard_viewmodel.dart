import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/entities/leaderboard/leaderboard.dart';
import '../../domain/usecases/get_leaderboards_usecase.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final GetLeaderboardsUseCase getLeaderboardsUseCase;
  GetLeaderboardRankingsUseCase? getLeaderboardRankingsUseCase;

  bool isLoading = false;
  String? error;
  List<LeaderboardBoard> boards = [];
  
  // 排行榜列表分页状态
  int _currentPage = 1;
  int _pageSize = 10;
  int _total = 0;
  int _totalPages = 0;
  bool _isLoadingMore = false;  // 私有变量：加载更多状态
  
  // 弹窗状态管理
  bool _isFullSheetVisible = false;
  String? _currentChallengeId;
  String? _currentChallengeTitle;
  
  // 缓存已加载的排行榜数据，避免重复请求
  final Map<String, LeaderboardRankingsPage> _rankingsCache = {};

  // 运行期资源管理
  bool _isDisposed = false;
  final Set<String> _inflightRequests = {};
  
  // 延迟清理相关
  Timer? _cleanupTimer;
  static const Duration _cleanupDelay = Duration(seconds: 30); // 30秒后清理

  LeaderboardViewModel({required this.getLeaderboardsUseCase, this.getLeaderboardRankingsUseCase});

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  Future<void> loadLeaderboards({int page = 1, int size = 10}) async {
    // 防重复加载：第一页时检查是否已有数据，其他页时检查是否正在加载更多
    if (page == 1) {
      if (isLoading || (boards.isNotEmpty && error == null)) {
        return; // 已有数据且无错误时避免重复请求
      }
      isLoading = true;
    } else {
      if (_isLoadingMore || !hasNextPage) {
        return; // 正在加载更多或没有更多数据时避免重复请求
      }
      _isLoadingMore = true;
    }
    
    error = null;
    notifyListeners();

    try {
      final result = await getLeaderboardsUseCase.execute(page: page, size: size);
      
      if (page == 1) {
        // 第一页：替换所有数据
        boards = result.items;
        _currentPage = result.currentPage;
        _pageSize = result.pageSize;
        _total = result.total;
        _totalPages = (_total / _pageSize).ceil();
      } else {
        // 其他页：追加数据
        boards.addAll(result.items);
        _currentPage = result.currentPage;
      }
      
      error = null;
    } catch (e) {
      error = e.toString();
      if (page == 1) {
        boards = [];
      }
    } finally {
      if (page == 1) {
        isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  bool get hasError => error != null;
  bool get hasData => boards.isNotEmpty;
  
  // 分页信息 getter
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get total => _total;
  int get totalPages => _totalPages;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPreviousPage => _currentPage > 1;
  
  // 加载状态 getter
  bool get isLoadingMore => _isLoadingMore;

  // 分页数据状态
  final Map<String, List<RankingItem>> _rankingsItems = {};
  final Map<String, int> _rankingsTotal = {};
  final Map<String, int> _rankingsCurrentPage = {};
  final Map<String, bool> _rankingsLoading = {};
  final Map<String, bool> _rankingsLoadingMore = {};
  final Map<String, String?> _rankingsError = {};

  // 加载下一页排行榜列表（无限滚动）
  Future<void> loadNextPage() async {
    if (hasNextPage && !isLoading && !_isLoadingMore) {
      await loadLeaderboards(page: _currentPage + 1, size: _pageSize);
    }
  }

  // 拉取某挑战的排行榜分页（带缓存优化）
  Future<LeaderboardRankingsPage> loadRankings({
    required String challengeId,
    int page = 1,
    int pageSize = 16,
  }) async {
    // 检查缓存：如果是第一页且已缓存，直接返回
    final cacheKey = '${challengeId}_$page';
    if (page == 1 && _rankingsCache.containsKey(cacheKey)) {
      return _rankingsCache[cacheKey]!;
    }
    
    final usecase = getLeaderboardRankingsUseCase;
    if (usecase == null) {
      throw StateError('GetLeaderboardRankingsUseCase is not provided');
    }
    
    final result = await usecase.execute(challengeId: challengeId, page: page, pageSize: pageSize);
    
    // 缓存第一页数据
    if (page == 1) {
      _rankingsCache[cacheKey] = result;
    }
    
    return result;
  }

  // 统一的分页数据管理方法（带并发去重）
  Future<void> loadRankingsPage({
    required String challengeId,
    int page = 1,
    int pageSize = 16,
  }) async {
    final requestKey = '$challengeId:$page:$pageSize';
    if (_inflightRequests.contains(requestKey)) {
      return; // 去重：相同页码的并发请求直接忽略
    }
    _inflightRequests.add(requestKey);

    // 设置加载状态
    if (page == 1) {
      _rankingsLoading[challengeId] = true;
      _rankingsError[challengeId] = null;
    } else {
      _rankingsLoadingMore[challengeId] = true;
    }
    notifyListeners();

    try {
      final pageData = await loadRankings(
        challengeId: challengeId,
        page: page,
        pageSize: pageSize,
      );

      // 更新状态
      if (page == 1) {
        _rankingsItems[challengeId] = List<RankingItem>.from(pageData.items);
        _rankingsTotal[challengeId] = pageData.total;
        _rankingsCurrentPage[challengeId] = pageData.currentPage;
      } else {
        final currentItems = _rankingsItems[challengeId] ?? [];
        _rankingsItems[challengeId] = List<RankingItem>.from(currentItems)..addAll(pageData.items);
        _rankingsCurrentPage[challengeId] = pageData.currentPage;
      }
      _rankingsError[challengeId] = null;
    } catch (e) {
      _rankingsError[challengeId] = e.toString();
    } finally {
      if (page == 1) {
        _rankingsLoading[challengeId] = false;
      } else {
        _rankingsLoadingMore[challengeId] = false;
      }
      _inflightRequests.remove(requestKey);
      notifyListeners();
    }
  }

  // 获取分页数据状态
  bool isRankingsLoading(String challengeId) => _rankingsLoading[challengeId] ?? false;
  bool isRankingsLoadingMore(String challengeId) => _rankingsLoadingMore[challengeId] ?? false;
  bool hasRankingsError(String challengeId) => _rankingsError[challengeId] != null;
  String? getRankingsError(String challengeId) => _rankingsError[challengeId];
  List<RankingItem> getRankingsItems(String challengeId) => _rankingsItems[challengeId] ?? [];
  int getRankingsTotal(String challengeId) => _rankingsTotal[challengeId] ?? 0;
  int getRankingsCurrentPage(String challengeId) => _rankingsCurrentPage[challengeId] ?? 0;
  bool hasMoreRankings(String challengeId) {
    final items = _rankingsItems[challengeId] ?? [];
    final total = _rankingsTotal[challengeId] ?? 0;
    return items.length < total;
  }
  
  // 清理指定挑战的缓存
  void clearRankingsCache(String challengeId) {
    // 清理缓存数据
    _rankingsCache.removeWhere((key, _) => key.startsWith('${challengeId}_'));
    
    // 清理分页状态数据
    _rankingsItems.remove(challengeId);
    _rankingsTotal.remove(challengeId);
    _rankingsCurrentPage.remove(challengeId);
    _rankingsLoading.remove(challengeId);
    _rankingsLoadingMore.remove(challengeId);
    _rankingsError.remove(challengeId);
    
    notifyListeners();
  }
  
  // 清理所有缓存
  void clearAllCache() {
    _rankingsCache.clear();
    _rankingsItems.clear();
    _rankingsTotal.clear();
    _rankingsCurrentPage.clear();
    _rankingsLoading.clear();
    _rankingsLoadingMore.clear();
    _rankingsError.clear();
    _inflightRequests.clear();
    
    notifyListeners();
  }
  
  // 弹窗控制方法
  void showFullSheet(String challengeId, String title) {
    _currentChallengeId = challengeId;
    _currentChallengeTitle = title;
    _isFullSheetVisible = true;
    notifyListeners();
  }
  
  void hideFullSheet() {
    _isFullSheetVisible = false;
    _currentChallengeId = null;
    _currentChallengeTitle = null;
    notifyListeners();
  }
  
  // 弹窗状态获取
  bool get isFullSheetVisible => _isFullSheetVisible;
  String? get currentChallengeId => _currentChallengeId;
  String? get currentChallengeTitle => _currentChallengeTitle;
  
  /// 智能延迟清理：延迟清理数据以提升用户体验
  void scheduleCleanup() {
    // 取消之前的清理定时器
    _cleanupTimer?.cancel();
    
    // 设置新的延迟清理定时器
    _cleanupTimer = Timer(_cleanupDelay, () {
      _cleanupData();
    });
  }

  /// 立即清理数据
  void _cleanupData() {
    clearAllCache();
    notifyListeners();
  }

  /// 取消延迟清理（当用户重新访问页面时）
  void cancelCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// 检查是否有缓存数据
  bool get hasCachedData => boards.isNotEmpty;

  // 页面退出时的完整清理
  @override
  void dispose() {
    // 取消定时器
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    
    // 立即清理数据
    _cleanupData();
    _isDisposed = true;
    super.dispose();
  }
}


