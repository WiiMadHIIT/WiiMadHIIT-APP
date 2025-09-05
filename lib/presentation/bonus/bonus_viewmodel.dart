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

  // 新增：时间戳跟踪（用于基于时间的刷新）
  DateTime? _lastFullRefreshTime;
  static const Duration _refreshInterval = Duration(hours: 2);

  // 新增：智能追加加载相关状态
  DateTime? _lastAppendLoadTime;
  int _appendLoadCount = 0;
  static const Duration _appendLoadWindow = Duration(hours: 1); // 1小时窗口
  static const int _maxAppendLoads = 3; // 1小时内最多3次
  bool _isAppendLoading = false;

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

  // 智能追加加载相关 Getters
  bool get isAppendLoading => _isAppendLoading;
  int get appendLoadCount => _appendLoadCount;
  bool get canAppendLoad => _canAppendLoad();

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

  /// 智能刷新：结合时间检查和数据存在性检查
  /// 如果距离上次完整刷新超过2小时，执行完整刷新
  /// 否则执行智能刷新（有数据时跳过）
  Future<void> smartRefreshWithTimeCheck() async {
    print('🔍 BonusViewModel: 开始智能时间检查刷新');
    
    final now = DateTime.now();
    final shouldFullRefresh = _lastFullRefreshTime == null || 
        now.difference(_lastFullRefreshTime!) >= _refreshInterval;
    
    if (shouldFullRefresh) {
      print('🔍 BonusViewModel: 距离上次完整刷新超过2小时，执行完整刷新');
      await refresh();
      _lastFullRefreshTime = now;
      print('🔍 BonusViewModel: 完整刷新完成，更新时间戳: $_lastFullRefreshTime');
    } else {
      print('🔍 BonusViewModel: 距离上次完整刷新未超过2小时，执行智能刷新');
      await smartRefresh();
    }
  }

  /// 智能刷新Bonus数据（有数据时不刷新，无数据时才刷新）
  Future<void> smartRefresh() async {
    print('🔍 BonusViewModel: 开始智能刷新Bonus数据');
    
    // 检查是否有数据
    if (_activities.isEmpty) {
      // 无数据时，执行刷新
      print('🔍 BonusViewModel: 无数据，执行刷新');
      await loadBonusActivities(page: 1, size: _pageSize);
    } else {
      // 有数据时，不刷新，只记录日志
      print('🔍 BonusViewModel: 已有数据，跳过刷新');
    }
  }

  /// 智能追加加载：1小时内最多3次，带防抖机制
  /// 如果_activities为空或null，直接刷新第一页
  /// 否则检查时间限制和次数限制
  Future<void> smartAppendLoad() async {
    print('🔍 BonusViewModel: 开始智能追加加载');
    
    // 防抖检查
    if (_isAppendLoading) {
      print('🔍 BonusViewModel: 正在追加加载中，跳过请求');
      return;
    }
    
    // 如果_activities为空或null，直接刷新第一页
    if (_activities.isEmpty) {
      print('🔍 BonusViewModel: 活动列表为空，直接刷新第一页');
      await loadBonusActivities(page: 1, size: _pageSize);
      return;
    }
    
    // 检查是否可以追加加载
    if (!canAppendLoad) {
      print('🔍 BonusViewModel: 1小时内已达到最大追加加载次数(${_maxAppendLoads}次)，跳过');
      return;
    }
    
    // 检查是否还有下一页
    if (!_hasNextPage) {
      print('🔍 BonusViewModel: 没有更多数据可加载');
      return;
    }
    
    // 执行追加加载
    _isAppendLoading = true;
    notifyListeners();
    
    try {
      print('🔍 BonusViewModel: 执行追加加载，当前页: ${_currentPage + 1}');
      await loadBonusActivities(
        page: _currentPage + 1,
        size: _pageSize,
        append: true,
      );
      
      // 更新追加加载统计
      _lastAppendLoadTime = DateTime.now();
      _appendLoadCount++;
      
      print('🔍 BonusViewModel: 追加加载完成，当前总数量: ${_activities.length}，追加次数: $_appendLoadCount');
    } catch (e) {
      print('❌ BonusViewModel: 追加加载失败: $e');
    } finally {
      _isAppendLoading = false;
      notifyListeners();
    }
  }

  /// 检查是否可以追加加载（时间窗口和次数限制）
  bool _canAppendLoad() {
    // 首先检查是否还有下一页数据
    if (!_hasNextPage) {
      print('🔍 BonusViewModel: 没有更多数据可加载');
      return false;
    }
    
    final now = DateTime.now();
    
    // 如果从未追加加载过，可以加载
    if (_lastAppendLoadTime == null) {
      return true;
    }
    
    // 检查是否在1小时窗口内
    final timeSinceLastLoad = now.difference(_lastAppendLoadTime!);
    if (timeSinceLastLoad >= _appendLoadWindow) {
      // 超过1小时，重置计数器
      _appendLoadCount = 0;
      print('🔍 BonusViewModel: 超过1小时窗口，重置追加加载计数器');
      return true;
    }
    
    // 在1小时窗口内，检查次数限制
    return _appendLoadCount < _maxAppendLoads;
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

  /// 清理所有数据（用于退出登录时）
  void clearAllData() {
    print('🔍 BonusViewModel: 清理所有数据');
    
    // 清理活动数据
    _activities = [];
    _filteredActivities = [];
    
    // 清理分页状态
    _currentPage = 1;
    _total = 0;
    _hasNextPage = false;
    _hasPreviousPage = false;
    
    // 清理时间戳
    _lastFullRefreshTime = null;
    
    // 清理智能追加加载状态
    _lastAppendLoadTime = null;
    _appendLoadCount = 0;
    _isAppendLoading = false;
    
    // 重置加载状态
    _isLoading = false;
    _currentIndex = 0;
    _error = null;
    
    print('🔍 BonusViewModel: 所有数据已清理完成');
    
    // 通知监听器更新UI
    notifyListeners();
  }
} 