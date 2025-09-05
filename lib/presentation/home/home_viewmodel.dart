import 'package:flutter/material.dart';
import '../../domain/services/home_service.dart';
import '../../domain/entities/home/home_entities.dart';
import '../../domain/usecases/get_home_dashboard_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final GetHomeAnnouncementsUseCase getHomeAnnouncementsUseCase;
  final GetHomeChampionsUseCase getHomeChampionsUseCase;
  final GetHomeActiveUsersUseCase getHomeActiveUsersUseCase;
  final HomeService homeService;

  // 独立的数据状态
  List<Announcement>? announcements;
  List<Champion>? recentChampions;
  List<ActiveUser>? activeUsers;
  
  // 独立的错误状态
  String? announcementsError;
  String? championsError;
  String? activeUsersError;
  
  // 独立的加载状态
  bool isAnnouncementsLoading = false;
  bool isChampionsLoading = false;
  bool isActiveUsersLoading = false;

  // 新增：时间戳跟踪（用于基于时间的刷新）
  DateTime? _lastFullRefreshTime;
  static const Duration _refreshInterval = Duration(hours: 20);

  HomeViewModel({
    required this.getHomeAnnouncementsUseCase,
    required this.getHomeChampionsUseCase,
    required this.getHomeActiveUsersUseCase,
    required this.homeService,
  });

  // 新增：独立加载公告栏数据
  Future<void> loadAnnouncements() async {
    isAnnouncementsLoading = true;
    announcementsError = null;
    notifyListeners();

    try {
      announcements = await getHomeAnnouncementsUseCase.execute();
      announcementsError = null;
    } catch (e) {
      announcementsError = e.toString();
      announcements = null;
      print('加载公告栏数据失败: $e');
    } finally {
      isAnnouncementsLoading = false;
      notifyListeners();
    }
  }

  // 新增：独立加载冠军数据
  Future<void> loadChampions() async {
    isChampionsLoading = true;
    championsError = null;
    notifyListeners();

    try {
      recentChampions = await getHomeChampionsUseCase.execute();
      championsError = null;
    } catch (e) {
      championsError = e.toString();
      recentChampions = null;
      print('加载冠军数据失败: $e');
    } finally {
      isChampionsLoading = false;
      notifyListeners();
    }
  }

  // 新增：独立加载活跃用户数据
  Future<void> loadActiveUsers() async {
    isActiveUsersLoading = true;
    activeUsersError = null;
    notifyListeners();

    try {
      activeUsers = await getHomeActiveUsersUseCase.execute();
      activeUsersError = null;
    } catch (e) {
      activeUsersError = e.toString();
      activeUsers = null;
      print('加载活跃用户数据失败: $e');
    } finally {
      isActiveUsersLoading = false;
      notifyListeners();
    }
  }

  // 新增：并行加载所有数据
  Future<void> loadAllData() async {
    await Future.wait([
      loadAnnouncements(),
      loadChampions(),
      loadActiveUsers(),
    ]);
  }

  // 新增：刷新所有数据
  Future<void> refreshAllData() async {
    await Future.wait([
      loadAnnouncements(),
      loadChampions(),
      loadActiveUsers(),
    ]);
  }

  /// 智能刷新：结合时间检查和数据存在性检查
  /// 如果距离上次完整刷新超过20小时，执行完整刷新
  /// 否则执行智能刷新（有数据时跳过）
  Future<void> smartRefreshWithTimeCheck() async {
    print('🔍 HomeViewModel: 开始智能时间检查刷新');
    
    final now = DateTime.now();
    final shouldFullRefresh = _lastFullRefreshTime == null || 
        now.difference(_lastFullRefreshTime!) >= _refreshInterval;
    
    if (shouldFullRefresh) {
      print('🔍 HomeViewModel: 距离上次完整刷新超过20小时，执行完整刷新');
      await refreshAllData();
      _lastFullRefreshTime = now;
      print('🔍 HomeViewModel: 完整刷新完成，更新时间戳: $_lastFullRefreshTime');
    } else {
      print('🔍 HomeViewModel: 距离上次完整刷新未超过20小时，执行智能刷新');
      await smartRefresh();
    }
  }

  /// 智能刷新Home数据（有数据时不刷新，无数据时才刷新）
  Future<void> smartRefresh() async {
    print('🔍 HomeViewModel: 开始智能刷新Home数据');
    
    // 检查是否有任何数据
    final hasAnyData = hasAnnouncements || hasChampions || hasActiveUsers;
    
    if (!hasAnyData) {
      // 无数据时，执行刷新
      print('🔍 HomeViewModel: 无数据，执行刷新');
      await loadAllData();
    } else {
      // 有数据时，不刷新，只记录日志
      print('🔍 HomeViewModel: 已有数据，跳过刷新');
    }
  }

  // 计算属性 - 新架构
  bool get hasAnnouncements => announcements != null && announcements!.isNotEmpty;
  bool get hasChampions => recentChampions != null && recentChampions!.isNotEmpty;
  bool get hasActiveUsers => activeUsers != null && activeUsers!.isNotEmpty;
  
  bool get hasAnnouncementsError => announcementsError != null;
  bool get hasChampionsError => championsError != null;
  bool get hasActiveUsersError => activeUsersError != null;
  
  bool get isAllLoading => isAnnouncementsLoading || isChampionsLoading || isActiveUsersLoading;
  bool get hasAnyError => announcementsError != null || championsError != null || activeUsersError != null;

  // 排序后的数据
  List<Announcement> get sortedAnnouncements {
    if (announcements == null) return [];
    final sorted = List<Announcement>.from(announcements!);
    sorted.sort((a, b) => a.priority.compareTo(b.priority));
    return sorted;
  }

  List<Champion> get sortedChampions {
    if (recentChampions == null) return [];
    final sorted = List<Champion>.from(recentChampions!);
    sorted.sort((a, b) => a.rank.compareTo(b.rank));
    return sorted;
  }

  List<ActiveUser> get sortedActiveUsers {
    if (activeUsers == null) return [];
    final sorted = List<ActiveUser>.from(activeUsers!);
    sorted.sort((a, b) => b.streakDays.compareTo(a.streakDays));
    return sorted;
  }

  // 错误处理 - 新架构
  void clearAnnouncementsError() {
    announcementsError = null;
    notifyListeners();
  }

  void clearChampionsError() {
    championsError = null;
    notifyListeners();
  }

  void clearActiveUsersError() {
    activeUsersError = null;
    notifyListeners();
  }

  void clearAllErrors() {
    announcementsError = null;
    championsError = null;
    activeUsersError = null;
    notifyListeners();
  }

  /// 清理所有数据（用于退出登录时）
  void clearAllData() {
    print('🔍 HomeViewModel: 清理所有数据');
    
    // 清理数据
    announcements = null;
    recentChampions = null;
    activeUsers = null;
    
    // 清理错误状态
    announcementsError = null;
    championsError = null;
    activeUsersError = null;
    
    // 清理时间戳
    _lastFullRefreshTime = null;
    
    // 重置加载状态
    isAnnouncementsLoading = false;
    isChampionsLoading = false;
    isActiveUsersLoading = false;
    
    print('🔍 HomeViewModel: 所有数据已清理完成');
    
    // 通知监听器更新UI
    notifyListeners();
  }
}
