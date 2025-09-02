import 'package:flutter/material.dart';
import '../../domain/entities/bonus_activity.dart';
import '../../domain/usecases/get_bonus_activities_usecase.dart';
import '../../domain/services/bonus_service.dart';
import '../../data/repository/bonus_repository.dart';

class BonusViewModel extends ChangeNotifier {
  final GetBonusActivitiesUseCase getBonusActivitiesUseCase;
  final BonusService bonusService;

  List<BonusActivity> _activities = [];
  List<BonusActivity> _filteredActivities = [];
  String? _error;
  bool _isLoading = false;
  int _currentIndex = 0;
  String _userRegion = 'US'; // 默认用户地区，后续可从用户配置获取
  
  // 分页相关状态
  int _currentPage = 1;
  int _pageSize = 10;
  int _total = 0;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;

  // Getters
  List<BonusActivity> get activities => _activities;
  List<BonusActivity> get filteredActivities => _filteredActivities;
  String? get error => _error;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  bool get hasActivities => _activities.isNotEmpty;
  bool get hasError => _error != null;
  
  // 分页相关 Getters
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get total => _total;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get totalPages => (_total / _pageSize).ceil();

  BonusViewModel({
    required this.getBonusActivitiesUseCase,
    required this.bonusService,
  });

  /// 加载奖励活动列表（分页）
  Future<void> loadBonusActivities({
    int page = 1,
    int size = 10,
    bool append = false,
  }) async {
    _setLoading(true);

    try {
      final pageData = await getBonusActivitiesUseCase.execute(page: page, size: size);
      
      if (append && page > 1) {
        // 追加模式：将新数据追加到现有列表
        _activities.addAll(pageData.activities);
        _filteredActivities.addAll(pageData.activities);
      } else {
        // 替换模式：替换现有数据
        _activities = pageData.activities;
        _filteredActivities = pageData.activities;
      }
      
      // 更新分页信息
      _currentPage = pageData.currentPage;
      _pageSize = pageData.pageSize;
      _total = pageData.total;
      _hasNextPage = pageData.hasNextPage;
      _hasPreviousPage = pageData.hasPreviousPage;
      
      _notifyListeners();
    } catch (e) {
      // 如果加载失败，设置为空列表，不显示错误
      print('❌ Error loading bonus activities: $e');
      if (!append) {
        _activities = [];
        _filteredActivities = [];
        _currentPage = 1;
        _total = 0;
        _hasNextPage = false;
        _hasPreviousPage = false;
      }
      _notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 设置当前选中的活动索引
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _filteredActivities.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// 获取当前活动
  BonusActivity? get currentActivity {
    if (_currentIndex >= 0 && _currentIndex < _filteredActivities.length) {
      return _filteredActivities[_currentIndex];
    }
    return null;
  }



  /// 刷新数据
  Future<void> refresh() async {
    await loadBonusActivities(page: 1, size: _pageSize);
  }

  /// 加载下一页
  Future<void> loadNextPage() async {
    if (_hasNextPage && !_isLoading) {
      await loadBonusActivities(
        page: _currentPage + 1,
        size: _pageSize,
        append: true,
      );
    }
  }

  /// 加载上一页
  Future<void> loadPreviousPage() async {
    if (_hasPreviousPage && !_isLoading) {
      await loadBonusActivities(
        page: _currentPage - 1,
        size: _pageSize,
        append: false,
      );
    }
  }

  /// 跳转到指定页
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages && !_isLoading) {
      await loadBonusActivities(
        page: page,
        size: _pageSize,
        append: false,
      );
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }
} 