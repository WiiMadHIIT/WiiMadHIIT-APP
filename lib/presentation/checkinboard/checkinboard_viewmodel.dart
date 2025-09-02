import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/usecases/get_checkinboard_usecase.dart';
import '../../domain/entities/checkinboard/checkinboard.dart';
import '../../domain/services/checkinboard_service.dart';

class CheckinboardViewModel extends ChangeNotifier {
  final GetCheckinboardUseCase getCheckinboardUseCase;
  final CheckinboardService service;
  GetCheckinboardRankingsUseCase? getRankingsUseCase;

  bool isLoading = false;
  String? error;
  CheckinboardPage? pageData;
  
  // 弹窗状态管理
  bool _isFullSheetVisible = false;
  String? _currentActivity;
  String? _currentActivityTitle;
  
  // 缓存已加载的排行榜数据，避免重复请求
  final Map<String, CheckinboardRankingsPage> _rankingsCache = {};
  
  // 分页数据状态
  final Map<String, List<CheckinRanking>> _rankingsItems = {};
  final Map<String, int> _rankingsTotal = {};
  final Map<String, int> _rankingsCurrentPage = {};
  final Map<String, bool> _rankingsLoading = {};
  final Map<String, bool> _rankingsLoadingMore = {};
  final Map<String, String?> _rankingsError = {};

  // 运行期资源管理
  bool _isDisposed = false;
  final Set<String> _inflightRequests = {};
  
  // 延迟清理相关
  Timer? _cleanupTimer;
  static const Duration _cleanupDelay = Duration(seconds: 30); // 30秒后清理

  CheckinboardViewModel({
    required this.getCheckinboardUseCase,
    required this.service,
    this.getRankingsUseCase,
  });

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  Future<void> loadCheckinboards({int page = 1, int pageSize = 10}) async {
    if (isLoading || (pageData != null && error == null)) {
      return; // 已有数据且无错误时避免重复请求
    }
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      pageData = await getCheckinboardUseCase.execute(page: page, pageSize: pageSize);
      error = null;
    } catch (e) {
      error = e.toString();
      pageData = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool get hasError => error != null;
  bool get hasData => pageData != null && service.isPageDataValid(pageData!);

  Future<CheckinboardRankingsPage> loadRankings({String? activity, String? activityId, int page = 1, int pageSize = 16}) async {
    // 检查缓存：如果是第一页且已缓存，直接返回
    final cacheKey = '${activity ?? activityId ?? 'default'}_$page';
    if (page == 1 && _rankingsCache.containsKey(cacheKey)) {
      return _rankingsCache[cacheKey]!;
    }
    
    final usecase = getRankingsUseCase;
    if (usecase == null) {
      throw StateError('GetCheckinboardRankingsUseCase is not provided');
    }
    
    final result = await usecase.execute(activity: activity, activityId: activityId, page: page, pageSize: pageSize);
    
    // 缓存第一页数据
    if (page == 1) {
      _rankingsCache[cacheKey] = result;
    }
    
    return result;
  }

  // 统一的分页数据管理方法（带并发去重）
  Future<void> loadRankingsPage({
    String? activity,
    String? activityId,
    int page = 1,
    int pageSize = 16,
  }) async {
    final key = activity ?? activityId ?? 'default';
    final requestKey = '$key:$page:$pageSize';
    if (_inflightRequests.contains(requestKey)) {
      return; // 去重：相同页码的并发请求直接忽略
    }
    _inflightRequests.add(requestKey);
    
    // 设置加载状态
    if (page == 1) {
      _rankingsLoading[key] = true;
      _rankingsError[key] = null;
    } else {
      _rankingsLoadingMore[key] = true;
    }
    notifyListeners();

    try {
      final pageData = await loadRankings(
        activity: activity,
        activityId: activityId,
        page: page,
        pageSize: pageSize,
      );

      // 更新状态
      if (page == 1) {
        _rankingsItems[key] = List<CheckinRanking>.from(pageData.items);
        _rankingsTotal[key] = pageData.total;
        _rankingsCurrentPage[key] = pageData.currentPage;
      } else {
        final currentItems = _rankingsItems[key] ?? [];
        _rankingsItems[key] = List<CheckinRanking>.from(currentItems)..addAll(pageData.items);
        _rankingsCurrentPage[key] = pageData.currentPage;
      }
      _rankingsError[key] = null;
    } catch (e) {
      _rankingsError[key] = e.toString();
    } finally {
      if (page == 1) {
        _rankingsLoading[key] = false;
      } else {
        _rankingsLoadingMore[key] = false;
      }
      _inflightRequests.remove(requestKey);
      notifyListeners();
    }
  }

  // 获取分页数据状态
  bool isRankingsLoading(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    return _rankingsLoading[key] ?? false;
  }
  
  bool isRankingsLoadingMore(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    return _rankingsLoadingMore[key] ?? false;
  }
  
  bool hasRankingsError(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    return _rankingsError[key] != null;
  }
  
  String? getRankingsError(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    return _rankingsError[key];
  }
  
  List<CheckinRanking> getRankingsItems(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    return _rankingsItems[key] ?? [];
  }
  
  int getRankingsTotal(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    return _rankingsTotal[key] ?? 0;
  }
  
  int getRankingsCurrentPage(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    return _rankingsCurrentPage[key] ?? 0;
  }
  
  bool hasMoreRankings(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    final items = _rankingsItems[key] ?? [];
    final total = _rankingsTotal[key] ?? 0;
    return items.length < total;
  }
  
  // 清理指定活动的缓存
  void clearRankingsCache(String? activity, String? activityId) {
    final key = activity ?? activityId ?? 'default';
    
    // 清理缓存数据
    _rankingsCache.removeWhere((cacheKey, _) => cacheKey.startsWith('${key}_'));
    
    // 清理分页状态数据
    _rankingsItems.remove(key);
    _rankingsTotal.remove(key);
    _rankingsCurrentPage.remove(key);
    _rankingsLoading.remove(key);
    _rankingsLoadingMore.remove(key);
    _rankingsError.remove(key);
    
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
  void showFullSheet(String activity, String title) {
    _currentActivity = activity;
    _currentActivityTitle = title;
    _isFullSheetVisible = true;
    notifyListeners();
  }
  
  void hideFullSheet() {
    _isFullSheetVisible = false;
    _currentActivity = null;
    _currentActivityTitle = null;
    notifyListeners();
  }
  
  // 弹窗状态获取
  bool get isFullSheetVisible => _isFullSheetVisible;
  String? get currentActivity => _currentActivity;
  String? get currentActivityTitle => _currentActivityTitle;
  
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
  bool get hasCachedData => pageData != null && service.isPageDataValid(pageData!);

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
