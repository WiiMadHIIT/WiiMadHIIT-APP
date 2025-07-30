import 'package:flutter/material.dart';
import '../../domain/entities/bonus_activity.dart';
import '../../domain/usecases/get_bonus_activities_usecase.dart';
import '../../domain/usecases/claim_bonus_usecase.dart';
import '../../domain/services/bonus_service.dart';

class BonusViewModel extends ChangeNotifier {
  final GetBonusActivitiesUseCase getBonusActivitiesUseCase;
  final ClaimBonusUseCase claimBonusUseCase;
  final BonusService bonusService;

  List<BonusActivity> _activities = [];
  List<BonusActivity> _filteredActivities = [];
  String? _error;
  bool _isLoading = false;
  int _currentIndex = 0;
  String _userRegion = 'US'; // 默认用户地区，后续可从用户配置获取

  // Getters
  List<BonusActivity> get activities => _activities;
  List<BonusActivity> get filteredActivities => _filteredActivities;
  String? get error => _error;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  bool get hasActivities => _activities.isNotEmpty;
  bool get hasError => _error != null;

  BonusViewModel({
    required this.getBonusActivitiesUseCase,
    required this.claimBonusUseCase,
    required this.bonusService,
  });

  /// 加载奖励活动列表
  Future<void> loadBonusActivities() async {
    _setLoading(true);
    _clearError();

    try {
      final activities = await getBonusActivitiesUseCase.execute();
      _activities = activities;
      _filteredActivities = activities;
      _notifyListeners();
    } catch (e) {
      _setError(e.toString());
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

  /// 领取奖励
  Future<void> claimBonus(String activityId) async {
    try {
      final result = await claimBonusUseCase.execute(activityId);
      
      // 更新本地活动状态
      final index = _activities.indexWhere((activity) => activity.id == activityId);
      if (index != -1) {
        // 这里需要重新加载数据来获取最新的状态
        await loadBonusActivities();
      }
      
      _notifyListeners();
    } catch (e) {
      _setError('Failed to claim bonus: $e');
    }
  }

  /// 按分类过滤活动
  void filterByCategory(String category) {
    if (category.isEmpty) {
      _filteredActivities = _activities;
    } else {
      _filteredActivities = bonusService.filterByCategory(_activities, category);
    }
    _currentIndex = 0; // 重置索引
    _notifyListeners();
  }

  /// 按难度过滤活动
  void filterByDifficulty(String difficulty) {
    if (difficulty.isEmpty) {
      _filteredActivities = _activities;
    } else {
      _filteredActivities = bonusService.filterByDifficulty(_activities, difficulty);
    }
    _currentIndex = 0; // 重置索引
    _notifyListeners();
  }

  /// 只显示可用活动
  void showAvailableOnly() {
    _filteredActivities = bonusService.filterAvailableActivities(_activities, _userRegion);
    _currentIndex = 0; // 重置索引
    _notifyListeners();
  }

  /// 显示所有活动
  void showAllActivities() {
    _filteredActivities = _activities;
    _currentIndex = 0; // 重置索引
    _notifyListeners();
  }

  /// 获取活动统计信息
  Map<String, dynamic> getActivityStats() {
    return bonusService.getActivityStats(_activities);
  }

  /// 检查用户是否符合活动资格
  bool isUserEligible(BonusActivity activity) {
    return bonusService.isUserEligible(activity, _userRegion);
  }

  /// 设置用户地区
  void setUserRegion(String region) {
    _userRegion = region;
    _notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadBonusActivities();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }
} 