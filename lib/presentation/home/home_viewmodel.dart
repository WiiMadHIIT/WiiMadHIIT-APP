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
}
