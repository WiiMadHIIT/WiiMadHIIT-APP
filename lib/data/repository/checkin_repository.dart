import '../api/checkin_api.dart';
import '../models/checkin_api_model.dart';
import '../../domain/entities/checkin_product.dart';

class CheckinRepository {
  final CheckinApi _checkinApi;

  CheckinRepository(this._checkinApi);

  /// 获取Checkin产品列表（支持分页）
  Future<CheckinProductPage> getCheckinProducts({
    int page = 1,
    int size = 10,
  }) async {
    final CheckinListApiModel apiModel = await _checkinApi.fetchCheckinProducts(
      page: page,
      size: size,
    );
    
    // 转换为业务实体
    final products = apiModel.products.map((product) => CheckinProduct(
      id: product.id,
      name: product.name,
      description: product.description,
      videoUrl: product.videoUrl,
    )).toList();

    return CheckinProductPage(
      products: products,
      total: apiModel.total,
      currentPage: apiModel.currentPage,
      pageSize: apiModel.pageSize,
    );
  }

  /// 获取所有Checkin产品列表（向后兼容）
  Future<List<CheckinProduct>> getAllCheckinProducts() async {
    final page = await getCheckinProducts(page: 1, size: 1000); // 获取大量数据
    return page.products;
  }
}

/// 分页数据包装类
class CheckinProductPage {
  final List<CheckinProduct> products;
  final int total;
  final int currentPage;
  final int pageSize;

  CheckinProductPage({
    required this.products,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  // 分页信息计算
  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;
} 