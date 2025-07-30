import '../entities/checkin_product.dart';
import '../services/checkin_service.dart';
import '../../data/repository/checkin_repository.dart';

class GetCheckinProductsUseCase {
  final CheckinRepository _repository;
  final CheckinService _service;

  GetCheckinProductsUseCase(this._repository, this._service);

  /// 执行获取产品列表的业务流程
  Future<List<CheckinProduct>> execute() async {
    try {
      // 从仓库获取数据
      final products = await _repository.getCheckinProducts();
      
      // 通过业务服务验证和处理数据
      if (!_service.validateProductData(products)) {
        throw Exception('Invalid product data received');
      }
      
      // 返回推荐的产品列表
      return _service.getRecommendedProducts(products);
    } catch (e) {
      throw Exception('Failed to get checkin products: $e');
    }
  }

  /// 根据搜索查询获取产品
  Future<List<CheckinProduct>> executeWithSearch(String query) async {
    try {
      final products = await _repository.getCheckinProducts();
      return _service.searchProducts(products, query);
    } catch (e) {
      throw Exception('Failed to search checkin products: $e');
    }
  }

  /// 获取产品统计信息
  Future<Map<String, int>> getProductStatistics() async {
    try {
      final products = await _repository.getCheckinProducts();
      return _service.getProductStatistics(products);
    } catch (e) {
      throw Exception('Failed to get product statistics: $e');
    }
  }
} 