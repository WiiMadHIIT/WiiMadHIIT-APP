import 'package:flutter/foundation.dart';
import '../../domain/entities/checkin_product.dart';
import '../../domain/usecases/get_checkin_products_usecase.dart';
import '../../data/repository/checkin_repository.dart';

class CheckinViewModel extends ChangeNotifier {
  final GetCheckinProductsUseCase _getCheckinProductsUseCase;

  CheckinViewModel(this._getCheckinProductsUseCase);

  // 状态变量
  List<CheckinProduct> _products = [];
  bool _isLoading = false;
  String? _error;
  int _currentIndex = 0;
  
  // 数据加载状态标记
  bool _hasInitialized = false;

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
  List<CheckinProduct> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentIndex => _currentIndex;
  bool get hasProducts => _products.isNotEmpty;
  bool get hasError => _error != null;
  bool get hasInitialized => _hasInitialized;

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

  /// 加载产品列表（分页）
  Future<void> loadCheckinProducts({
    int page = 1,
    int size = 10,
    bool append = false,
  }) async {
    _setLoading(true);

    try {
      final pageData = await _getCheckinProductsUseCase.execute(page: page, size: size);

      if (append && page > 1) {
        // 追加模式：将新数据追加到现有列表
        _products.addAll(pageData.products);
      } else {
        // 替换模式：替换现有数据
        _products = pageData.products;
      }

      // 更新分页信息
      _currentPage = pageData.currentPage;
      _pageSize = pageData.pageSize;
      _total = pageData.total;
      _hasNextPage = pageData.hasNextPage;
      _hasPreviousPage = pageData.hasPreviousPage;

      _hasInitialized = true;
      print('CheckinViewModel: Products loaded successfully, count: ${_products.length}, page: $page');
      notifyListeners();
    } catch (e) {
      // 如果加载失败，设置为空列表，不显示错误
      print('❌ Error loading checkin products: $e');
      _setProducts([]);
      _hasInitialized = true;
    } finally {
      _setLoading(false);
    }
  }

  /// 搜索产品
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      if (_hasInitialized) {
        print('CheckinViewModel: Empty search query, keeping original data');
        return;
      }
      await loadCheckinProducts(page: 1, size: _pageSize);
      return;
    }

    _setLoading(true);

    try {
      final products = await _getCheckinProductsUseCase.executeWithSearch(query);
      _setProducts(products);
      print('CheckinViewModel: Search completed, found ${products.length} products');
    } catch (e) {
      print('❌ Error searching checkin products: $e');
      _setProducts([]);
    } finally {
      _setLoading(false);
    }
  }

  /// 更新当前索引
  void updateCurrentIndex(int index) {
    if (index != _currentIndex && index >= 0) {
      _currentIndex = index;
      print('CheckinViewModel: Current index updated to $index');
      notifyListeners();
    }
  }

  /// 获取当前产品
  CheckinProduct? get currentProduct {
    if (_products.isEmpty || _currentIndex >= _products.length) {
      return null;
    }
    return _products[_currentIndex];
  }

  /// 获取产品统计信息
  Future<Map<String, int>> getProductStatistics() async {
    try {
      return await _getCheckinProductsUseCase.getProductStatistics();
    } catch (e) {
      print('❌ Error getting checkin product statistics: $e');
      return {};
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    print('CheckinViewModel: Manual refresh requested');
    _hasInitialized = false;
    await loadCheckinProducts(page: 1, size: _pageSize);
  }

  /// 智能刷新：结合时间检查和数据存在性检查
  /// 如果距离上次完整刷新超过24小时，执行完整刷新
  /// 否则执行智能刷新（有数据时跳过）
  Future<void> smartRefreshWithTimeCheck() async {
    print('🔍 CheckinViewModel: 开始智能时间检查刷新');
    
    final now = DateTime.now();
    final shouldFullRefresh = _lastFullRefreshTime == null || 
        now.difference(_lastFullRefreshTime!) >= _refreshInterval;
    
    if (shouldFullRefresh) {
      print('🔍 CheckinViewModel: 距离上次完整刷新超过24小时，执行完整刷新');
      await refresh();
      _lastFullRefreshTime = now;
      print('🔍 CheckinViewModel: 完整刷新完成，更新时间戳: $_lastFullRefreshTime');
    } else {
      print('🔍 CheckinViewModel: 距离上次完整刷新未超过24小时，执行智能刷新');
      await smartRefresh();
    }
  }

  /// 智能刷新Checkin数据（有数据时不刷新，无数据时才刷新）
  Future<void> smartRefresh() async {
    print('🔍 CheckinViewModel: 开始智能刷新Checkin数据');
    
    // 检查是否有数据
    if (_products.isEmpty) {
      // 无数据时，执行刷新
      print('🔍 CheckinViewModel: 无数据，执行刷新');
      await loadCheckinProducts(page: 1, size: _pageSize);
    } else {
      // 有数据时，不刷新，只记录日志
      print('🔍 CheckinViewModel: 已有数据，跳过刷新');
    }
  }

  /// 智能追加加载：1小时内最多3次，带防抖机制
  /// 如果_products为空或null，直接刷新第一页
  /// 否则检查时间限制和次数限制
  Future<void> smartAppendLoad() async {
    print('🔍 CheckinViewModel: 开始智能追加加载');
    
    // 防抖检查
    if (_isAppendLoading) {
      print('🔍 CheckinViewModel: 正在追加加载中，跳过请求');
      return;
    }
    
    // 如果_products为空或null，直接刷新第一页
    if (_products.isEmpty) {
      print('🔍 CheckinViewModel: 产品列表为空，直接刷新第一页');
      await loadCheckinProducts(page: 1, size: _pageSize);
      return;
    }
    
    // 检查是否可以追加加载
    if (!canAppendLoad) {
      print('🔍 CheckinViewModel: 1小时内已达到最大追加加载次数(${_maxAppendLoads}次)，跳过');
      return;
    }
    
    // 检查是否还有下一页
    if (!_hasNextPage) {
      print('🔍 CheckinViewModel: 没有更多数据可加载');
      return;
    }
    
    // 执行追加加载
    _isAppendLoading = true;
    notifyListeners();
    
    try {
      print('🔍 CheckinViewModel: 执行追加加载，当前页: ${_currentPage + 1}');
      await loadCheckinProducts(
        page: _currentPage + 1,
        size: _pageSize,
        append: true,
      );
      
      // 更新追加加载统计
      _lastAppendLoadTime = DateTime.now();
      _appendLoadCount++;
      
      print('🔍 CheckinViewModel: 追加加载完成，当前总数量: ${_products.length}，追加次数: $_appendLoadCount');
    } catch (e) {
      print('❌ CheckinViewModel: 追加加载失败: $e');
    } finally {
      _isAppendLoading = false;
      notifyListeners();
    }
  }

  /// 检查是否可以追加加载（时间窗口和次数限制）
  bool _canAppendLoad() {
    // 首先检查是否还有下一页数据
    if (!_hasNextPage) {
      print('🔍 CheckinViewModel: 没有更多数据可加载');
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
      print('🔍 CheckinViewModel: 超过1小时窗口，重置追加加载计数器');
      return true;
    }
    
    // 在1小时窗口内，检查次数限制
    return _appendLoadCount < _maxAppendLoads;
  }

  /// 加载下一页
  Future<void> loadNextPage() async {
    if (_hasNextPage && !_isLoading) {
      await loadCheckinProducts(
        page: _currentPage + 1,
        size: _pageSize,
        append: true,
      );
    }
  }

  /// 加载上一页
  Future<void> loadPreviousPage() async {
    if (_hasPreviousPage && !_isLoading) {
      await loadCheckinProducts(
        page: _currentPage - 1,
        size: _pageSize,
        append: false,
      );
    }
  }

  /// 跳转到指定页
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages && !_isLoading) {
      await loadCheckinProducts(
        page: page,
        size: _pageSize,
        append: false,
      );
    }
  }

  /// 清除错误（保留方法以兼容现有代码）
  void clearError() {
    // 不再需要清除错误，因为错误处理已经简化
  }

  // 私有方法
  void _setProducts(List<CheckinProduct> products) {
    _products = products;
    print('CheckinViewModel: Products updated, count: ${products.length}');
    notifyListeners();
  }

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

  /// 清理所有数据（用于退出登录时）
  void clearAllData() {
    print('🔍 CheckinViewModel: 清理所有数据');
    
    // 清理产品数据
    _products = [];
    
    // 清理错误状态
    _error = null;
    
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
    _hasInitialized = false;
    _currentIndex = 0;
    
    print('🔍 CheckinViewModel: 所有数据已清理完成');
    
    // 通知监听器更新UI
    notifyListeners();
  }

} 