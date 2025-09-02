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


} 