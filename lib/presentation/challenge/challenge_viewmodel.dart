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


}
