import '../api/training_rule_api.dart';
import '../models/training_rule_api_model.dart';
import '../../domain/entities/training_rule.dart';
import '../../domain/entities/training_config.dart';

class TrainingRuleRepository {
  final TrainingRuleApi _api = TrainingRuleApi();

  Future<Map<String, dynamic>> getTrainingRule(String trainingId, String productId) async {
    try {
      final apiModel = await _api.fetchTrainingRule(trainingId, productId);
      
      // 转换为领域实体
      final trainingRules = apiModel.trainingRules.map((rule) => TrainingRule(
        id: rule.id,
        title: rule.title,
        description: rule.description,
        order: rule.order,
      )).toList();



      final trainingConfig = TrainingConfig(
        nextPageRoute: apiModel.trainingConfig.nextPageRoute,
        isActivated: apiModel.trainingConfig.isActivated,
      );

      return {
        'trainingId': apiModel.trainingId,
        'productId': apiModel.productId,
        'trainingRules': trainingRules,
        'trainingConfig': trainingConfig,
      };
    } catch (e) {
      // 记录错误但不抛出异常，让UseCase处理默认配置
      // print('❌ [TrainingRuleRepository] API调用失败: $e');
      throw Exception('Failed to fetch training rule: $e');
    }
  }
} 