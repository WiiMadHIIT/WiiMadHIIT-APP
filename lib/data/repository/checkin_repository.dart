import '../api/checkin_api.dart';
import '../models/checkin_api_model.dart';
import '../../domain/entities/checkin_product.dart';

class CheckinRepository {
  final CheckinApi _checkinApi;

  CheckinRepository(this._checkinApi);

  /// 获取Checkin产品列表
  Future<List<CheckinProduct>> getCheckinProducts() async {
    final CheckinListApiModel apiModel = await _checkinApi.fetchCheckinProducts();
    
    // 转换为业务实体
    return apiModel.products.map((product) => CheckinProduct(
      id: product.id,
      name: product.name,
      description: product.description,
      iconUrl: product.iconUrl,
      videoUrl: product.videoUrl,
    )).toList();
  }
} 