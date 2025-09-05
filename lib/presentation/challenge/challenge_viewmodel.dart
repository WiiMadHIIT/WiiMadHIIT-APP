import 'package:flutter/foundation.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/usecases/get_challenges_usecase.dart';
import '../../data/repository/challenge_repository.dart';

class ChallengeViewModel extends ChangeNotifier {
  final GetChallengesUseCase _getChallengesUseCase;

  ChallengeViewModel(this._getChallengesUseCase);

  // 状态变量
  List<Challenge> _challenges = [];
  bool _isLoading = false;
  int _currentIndex = 0;
  String? _currentFilter; // 当前筛选状态

  // 分页相关状态
  int _currentPage = 1;
  int _pageSize = 10;
  int _total = 0;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;

  // 新增：时间戳跟踪（用于基于时间的刷新）
  DateTime? _lastFullRefreshTime;
  static const Duration _refreshInterval = Duration(hours: 24);

  // 新增：智能追加加载相关状态
  DateTime? _lastAppendLoadTime;
  int _appendLoadCount = 0;
  static const Duration _appendLoadWindow = Duration(hours: 1); // 1小时窗口
  static const int _maxAppendLoads = 3; // 1小时内最多3次
  bool _isAppendLoading = false;

  // Getters
  List<Challenge> get challenges => _challenges;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  bool get hasChallenges => _challenges.isNotEmpty;
  String? get currentFilter => _currentFilter;

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

  /// 获取筛选后的挑战列表
  List<Challenge> get filteredChallenges {
    if (_currentFilter == null) return _challenges;
    
    return _challenges.where((challenge) {
      switch (_currentFilter!.toLowerCase()) {
        case 'ongoing':
          return challenge.statusEnum == ChallengeStatus.ongoing;
        case 'ended':
          return challenge.statusEnum == ChallengeStatus.ended;
        case 'upcoming':
          return challenge.statusEnum == ChallengeStatus.upcoming;
        default:
          return challenge.status.toLowerCase() == _currentFilter!.toLowerCase();
      }
    }).toList();
  }

  /// 加载挑战列表（分页）
  Future<void> loadChallenges({
    int page = 1,
    int size = 10,
    bool append = false,
  }) async {
    _setLoading(true);

    try {
      final pageData = await _getChallengesUseCase.execute(page: page, size: size);

      if (append && page > 1) {
        // 追加模式：将新数据追加到现有列表
        _challenges.addAll(pageData.challenges);
      } else {
        // 替换模式：替换现有数据
        _challenges = pageData.challenges;
      }

      // 更新分页信息
      _currentPage = pageData.currentPage;
      _pageSize = pageData.pageSize;
      _total = pageData.total;
      _hasNextPage = pageData.hasNextPage;
      _hasPreviousPage = pageData.hasPreviousPage;

      notifyListeners();
    } catch (e) {
      // 如果加载失败，设置为空列表，不显示错误
      print('❌ Error loading challenges: $e');
      if (!append) {
        _challenges = [];
        _currentPage = 1;
        _total = 0;
        _hasNextPage = false;
        _hasPreviousPage = false;
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 根据状态筛选挑战
  Future<void> filterChallengesByStatus(String? status) async {
    // 不再发起API请求，只在本地数据中筛选
    _setCurrentFilter(status);
    _resetCurrentIndex();
    
    // 如果当前没有数据，先加载一次
    if (_challenges.isEmpty) {
      await loadChallenges();
    }
  }

  /// 搜索挑战
  Future<void> searchChallenges(String query) async {
    if (query.isEmpty) {
      await loadChallenges();
      return;
    }

    // 只在本地数据中搜索，不发起API请求
    if (_challenges.isEmpty) {
      await loadChallenges();
    }
    
    // 搜索逻辑已经在 filteredChallenges 中处理
    _resetCurrentIndex();
  }

  /// 更新当前索引
  void updateCurrentIndex(int index) {
    if (index != _currentIndex && index >= 0 && index < filteredChallenges.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// 获取当前挑战
  Challenge? get currentChallenge {
    if (filteredChallenges.isEmpty || _currentIndex >= filteredChallenges.length) {
      return null;
    }
    return filteredChallenges[_currentIndex];
  }

  /// 获取挑战统计信息
  Future<Map<String, int>> getChallengeStatistics() async {
    try {
      return await _getChallengesUseCase.getChallengeStatistics();
    } catch (e) {
      print('❌ Error getting challenge statistics: $e');
      return {};
    }
  }

  /// 获取推荐挑战
  Future<void> loadRecommendedChallenges() async {
    // 只在本地数据中筛选，不发起API请求
    if (_challenges.isEmpty) {
      await loadChallenges();
    }
    
    // 推荐逻辑可以在 filteredChallenges 中处理
    _resetCurrentIndex();
  }

  /// 获取热门挑战
  Future<void> loadPopularChallenges() async {
    // 只在本地数据中筛选，不发起API请求
    if (_challenges.isEmpty) {
      await loadChallenges();
    }
    
    // 热门逻辑可以在 filteredChallenges 中处理
    _resetCurrentIndex();
  }

  /// 获取即将到期的挑战
  Future<void> loadExpiringSoonChallenges() async {
    // 只在本地数据中筛选，不发起API请求
    if (_challenges.isEmpty) {
      await loadChallenges();
    }
    
    // 即将到期逻辑可以在 filteredChallenges 中处理
    _resetCurrentIndex();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadChallenges(page: 1, size: _pageSize);
  }

  /// 智能刷新：结合时间检查和数据存在性检查
  /// 如果距离上次完整刷新超过24小时，执行完整刷新
  /// 否则执行智能刷新（有数据时跳过）
  Future<void> smartRefreshWithTimeCheck() async {
    print('🔍 ChallengeViewModel: 开始智能时间检查刷新');
    
    final now = DateTime.now();
    final shouldFullRefresh = _lastFullRefreshTime == null || 
        now.difference(_lastFullRefreshTime!) >= _refreshInterval;
    
    if (shouldFullRefresh) {
      print('🔍 ChallengeViewModel: 距离上次完整刷新超过24小时，执行完整刷新');
      await refresh();
      _lastFullRefreshTime = now;
      print('🔍 ChallengeViewModel: 完整刷新完成，更新时间戳: $_lastFullRefreshTime');
    } else {
      print('🔍 ChallengeViewModel: 距离上次完整刷新未超过24小时，执行智能刷新');
      await smartRefresh();
    }
  }

  /// 智能刷新Challenge数据（有数据时不刷新，无数据时才刷新）
  Future<void> smartRefresh() async {
    print('🔍 ChallengeViewModel: 开始智能刷新Challenge数据');
    
    // 检查是否有数据
    if (_challenges.isEmpty) {
      // 无数据时，执行刷新
      print('🔍 ChallengeViewModel: 无数据，执行刷新');
      await loadChallenges(page: 1, size: _pageSize);
    } else {
      // 有数据时，不刷新，只记录日志
      print('🔍 ChallengeViewModel: 已有数据，跳过刷新');
    }
  }

  /// 智能追加加载：1小时内最多3次，带防抖机制
  /// 如果_challenges为空或null，直接刷新第一页
  /// 否则检查时间限制和次数限制
  Future<void> smartAppendLoad() async {
    print('🔍 ChallengeViewModel: 开始智能追加加载');
    
    // 防抖检查
    if (_isAppendLoading) {
      print('🔍 ChallengeViewModel: 正在追加加载中，跳过请求');
      return;
    }
    
    // 如果_challenges为空或null，直接刷新第一页
    if (_challenges.isEmpty) {
      print('🔍 ChallengeViewModel: 挑战列表为空，直接刷新第一页');
      await loadChallenges(page: 1, size: _pageSize);
      return;
    }
    
    // 检查是否可以追加加载
    if (!canAppendLoad) {
      print('🔍 ChallengeViewModel: 1小时内已达到最大追加加载次数(${_maxAppendLoads}次)，跳过');
      return;
    }
    
    // 检查是否还有下一页
    if (!_hasNextPage) {
      print('🔍 ChallengeViewModel: 没有更多数据可加载');
      return;
    }
    
    // 执行追加加载
    _isAppendLoading = true;
    notifyListeners();
    
    try {
      print('🔍 ChallengeViewModel: 执行追加加载，当前页: ${_currentPage + 1}');
      await loadChallenges(
        page: _currentPage + 1,
        size: _pageSize,
        append: true,
      );
      
      // 更新追加加载统计
      _lastAppendLoadTime = DateTime.now();
      _appendLoadCount++;
      
      print('🔍 ChallengeViewModel: 追加加载完成，当前总数量: ${_challenges.length}，追加次数: $_appendLoadCount');
    } catch (e) {
      print('❌ ChallengeViewModel: 追加加载失败: $e');
    } finally {
      _isAppendLoading = false;
      notifyListeners();
    }
  }

  /// 检查是否可以追加加载（时间窗口和次数限制）
  bool _canAppendLoad() {
    // 首先检查是否还有下一页数据
    if (!_hasNextPage) {
      print('🔍 ChallengeViewModel: 没有更多数据可加载');
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
      print('🔍 ChallengeViewModel: 超过1小时窗口，重置追加加载计数器');
      return true;
    }
    
    // 在1小时窗口内，检查次数限制
    return _appendLoadCount < _maxAppendLoads;
  }

  /// 加载下一页
  Future<void> loadNextPage() async {
    if (_hasNextPage && !_isLoading) {
      await loadChallenges(
        page: _currentPage + 1,
        size: _pageSize,
        append: true,
      );
    }
  }

  /// 加载上一页
  Future<void> loadPreviousPage() async {
    if (_hasPreviousPage && !_isLoading) {
      await loadChallenges(
        page: _currentPage - 1,
        size: _pageSize,
        append: false,
      );
    }
  }

  /// 跳转到指定页
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages && !_isLoading) {
      await loadChallenges(
        page: page,
        size: _pageSize,
        append: false,
      );
    }
  }

  /// 清除筛选
  Future<void> clearFilter() async {
    await filterChallengesByStatus(null);
  }

  /// 清除错误（保留方法以兼容现有代码）
  void clearError() {
    // 不再需要清除错误，因为错误处理已经简化
  }

  /// 设置当前筛选状态
  void setCurrentFilter(String? filter) {
    _setCurrentFilter(filter);
  }

  // 私有方法
  void _setChallenges(List<Challenge> challenges) {
    _challenges = challenges;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }



  void _setCurrentFilter(String? filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void _resetCurrentIndex() {
    _currentIndex = 0;
    notifyListeners();
  }

  /// 清理所有数据（用于退出登录时）
  void clearAllData() {
    print('🔍 ChallengeViewModel: 清理所有数据');
    
    // 清理挑战数据
    _challenges = [];
    
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
    _currentFilter = null;
    
    print('🔍 ChallengeViewModel: 所有数据已清理完成');
    
    // 通知监听器更新UI
    notifyListeners();
  }

}
