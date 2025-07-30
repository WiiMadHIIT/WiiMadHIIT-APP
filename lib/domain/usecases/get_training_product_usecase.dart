import '../entities/training_product.dart';
import '../entities/training_item.dart';
import '../services/training_service.dart';
import '../../data/repository/training_repository.dart';

class GetTrainingProductUseCase {
  final TrainingRepository _repository;
  final TrainingService _service;

  GetTrainingProductUseCase(this._repository, this._service);

  /// 获取训练产品配置
  Future<TrainingProduct> execute(String productId) async {
    try {
      final product = await _repository.getTrainingProduct(productId);
      
      // 验证数据
      if (!_service.validateTrainingProduct(product)) {
        throw Exception('Invalid training product data received');
      }
      
      return product;
    } catch (e) {
      throw Exception('Failed to get training product: $e');
    }
  }

  /// 获取推荐训练项目
  Future<List<TrainingItem>> getRecommendedTrainings(String productId) async {
    try {
      final product = await execute(productId);
      return _service.getRecommendedTrainings(product.trainings);
    } catch (e) {
      throw Exception('Failed to get recommended trainings: $e');
    }
  }

  /// 根据难度等级获取训练项目
  Future<List<TrainingItem>> getTrainingsByLevel(String productId, String level) async {
    try {
      final product = await execute(productId);
      return _service.filterTrainingsByLevel(product.trainings, level);
    } catch (e) {
      throw Exception('Failed to get trainings by level: $e');
    }
  }

  /// 获取热门训练项目
  Future<List<TrainingItem>> getPopularTrainings(String productId) async {
    try {
      final product = await execute(productId);
      return _service.getPopularTrainings(product.trainings);
    } catch (e) {
      throw Exception('Failed to get popular trainings: $e');
    }
  }

  /// 获取高完成率训练项目
  Future<List<TrainingItem>> getHighCompletionTrainings(String productId) async {
    try {
      final product = await execute(productId);
      return _service.getHighCompletionTrainings(product.trainings);
    } catch (e) {
      throw Exception('Failed to get high completion trainings: $e');
    }
  }

  /// 搜索训练项目
  Future<List<TrainingItem>> searchTrainings(String productId, String query) async {
    try {
      final product = await execute(productId);
      return _service.searchTrainings(product.trainings, query);
    } catch (e) {
      throw Exception('Failed to search trainings: $e');
    }
  }

  /// 获取训练统计信息
  Future<Map<String, dynamic>> getTrainingStatistics(String productId) async {
    try {
      final product = await execute(productId);
      return _service.getTrainingStatistics(product.trainings);
    } catch (e) {
      throw Exception('Failed to get training statistics: $e');
    }
  }
} 