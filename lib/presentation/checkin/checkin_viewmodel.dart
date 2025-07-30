import 'package:flutter/foundation.dart';
import '../../domain/entities/checkin_product.dart';
import '../../domain/usecases/get_checkin_products_usecase.dart';

class CheckinViewModel extends ChangeNotifier {
  final GetCheckinProductsUseCase _getCheckinProductsUseCase;

  CheckinViewModel(this._getCheckinProductsUseCase);

  // 状态变量
  List<CheckinProduct> _products = [];
  bool _isLoading = false;
  String? _error;
  int _currentIndex = 0;

  // Getters
  List<CheckinProduct> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentIndex => _currentIndex;
  bool get hasProducts => _products.isNotEmpty;
  bool get hasError => _error != null;

  /// 加载产品列表
  Future<void> loadCheckinProducts() async {
    _setLoading(true);
    _clearError();

    try {
      final products = await _getCheckinProductsUseCase.execute();
      _setProducts(products);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 搜索产品
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadCheckinProducts();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final products = await _getCheckinProductsUseCase.executeWithSearch(query);
      _setProducts(products);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 更新当前索引
  void updateCurrentIndex(int index) {
    if (index != _currentIndex && index >= 0 && index < _products.length) {
      _currentIndex = index;
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
      _setError(e.toString());
      return {};
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadCheckinProducts();
  }

  /// 清除错误
  void clearError() {
    _clearError();
  }

  // 私有方法
  void _setProducts(List<CheckinProduct> products) {
    _products = products;
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

  @override
  void dispose() {
    super.dispose();
  }
} 