import '../entities/checkin_product.dart';
import '../services/checkin_service.dart';
import '../../data/repository/checkin_repository.dart';

class GetCheckinProductsUseCase {
  final CheckinRepository _repository;
  final CheckinService _service;

  GetCheckinProductsUseCase(this._repository, this._service);

  /// 获取分页产品列表
  Future<CheckinProductPage> execute({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final pageData = await _repository.getCheckinProducts(page: page, size: size);
      
      // 验证数据
      if (!_service.validateProductData(pageData.products)) {
        throw Exception('Invalid product data received');
      }
      
      // 返回按优先级排序的产品列表
      final sortedProducts = _service.getRecommendedProducts(pageData.products);
      
      return CheckinProductPage(
        products: sortedProducts,
        total: pageData.total,
        currentPage: pageData.currentPage,
        pageSize: pageData.pageSize,
      );
    } catch (e) {
      throw Exception('Failed to get checkin products: $e');
    }
  }

  /// 获取所有产品列表（向后兼容）
  Future<List<CheckinProduct>> getAllProducts() async {
    try {
      final products = await _repository.getAllCheckinProducts();
      
      // 验证数据
      if (!_service.validateProductData(products)) {
        throw Exception('Invalid product data received');
      }
      
      // 返回按优先级排序的产品列表
      return _service.getRecommendedProducts(products);
    } catch (e) {
      throw Exception('Failed to get checkin products: $e');
    }
  }

  /// 根据搜索查询获取产品
  Future<List<CheckinProduct>> executeWithSearch(String query) async {
    try {
      final products = await _repository.getAllCheckinProducts();
      return _service.searchProducts(products, query);
    } catch (e) {
      throw Exception('Failed to search checkin products: $e');
    }
  }

  /// 获取产品统计信息
  Future<Map<String, int>> getProductStatistics() async {
    try {
      final products = await _repository.getAllCheckinProducts();
      return _service.getProductStatistics(products);
    } catch (e) {
      throw Exception('Failed to get product statistics: $e');
    }
  }
} 