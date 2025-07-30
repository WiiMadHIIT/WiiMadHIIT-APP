import '../api/training_api.dart';
import '../models/training_api_model.dart';
import '../../domain/entities/training_product.dart';
import '../../domain/entities/training_item.dart';

class TrainingRepository {
  final TrainingApi _trainingApi;

  TrainingRepository(this._trainingApi);

  /// 获取训练产品配置
  /// 包含页面配置和训练列表
  Future<TrainingProduct> getTrainingProduct(String productId) async {
    try {
      final TrainingProductApiModel apiModel = await _trainingApi.fetchTrainingProduct(productId);
      
      // 转换为业务实体
      return TrainingProduct(
        productId: apiModel.productId,
        pageConfig: TrainingPageConfig(
          pageTitle: apiModel.pageConfig.pageTitle,
          pageSubtitle: apiModel.pageConfig.pageSubtitle,
          videoUrl: apiModel.pageConfig.videoUrl,
          thumbnailUrl: apiModel.pageConfig.thumbnailUrl,
          lastUpdated: apiModel.pageConfig.lastUpdated,
        ),
        trainings: apiModel.trainings.map((training) => TrainingItem(
          id: training.id,
          name: training.name,
          level: training.level,
          description: training.description,
          participantCount: training.participantCount,
          completionRate: training.completionRate,
          status: training.status,
        )).toList(),
      );
    } catch (e) {
      throw Exception('Failed to get training product: $e');
    }
  }
} 