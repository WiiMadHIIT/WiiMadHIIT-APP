import '../../data/repository/training_rule_repository.dart';
import '../entities/training_rule.dart';
import '../entities/projection_tutorial.dart';
import '../entities/training_config.dart';
import '../services/training_rule_service.dart';

class GetTrainingRuleUseCase {
  final TrainingRuleRepository _repository;
  final TrainingRuleService _service;

  GetTrainingRuleUseCase({
    TrainingRuleRepository? repository,
    TrainingRuleService? service,
  }) : _repository = repository ?? TrainingRuleRepository(),
       _service = service ?? TrainingRuleService();

  /// 执行获取训练规则用例
  Future<Map<String, dynamic>> execute(String trainingId, String productId) async {
    // 从仓库获取数据
    final data = await _repository.getTrainingRule(trainingId, productId);
    
    final trainingRules = data['trainingRules'] as List<TrainingRule>;
    final projectionTutorial = data['projectionTutorial'] as ProjectionTutorial;
    final trainingConfig = data['trainingConfig'] as TrainingConfig;

    // 验证数据完整性
    if (!_service.validateTrainingRuleData(
      trainingRules: trainingRules,
      projectionTutorial: projectionTutorial,
      trainingConfig: trainingConfig,
    )) {
      throw Exception('Invalid training rule data');
    }

    // 获取统计信息
    final ruleStatistics = _service.getTrainingRuleStatistics(trainingRules);
    final tutorialStatistics = _service.getTutorialStepStatistics(projectionTutorial);

    return {
      'trainingId': data['trainingId'],
      'productId': data['productId'],
      'trainingRules': trainingRules,
      'projectionTutorial': projectionTutorial,
      'trainingConfig': trainingConfig,
      'ruleStatistics': ruleStatistics,
      'tutorialStatistics': tutorialStatistics,
      'isValid': true,
    };
  }

  /// 获取训练规则统计信息
  Map<String, dynamic> getTrainingRuleStatistics(List<TrainingRule> rules) {
    return _service.getTrainingRuleStatistics(rules);
  }

  /// 获取教程步骤统计信息
  Map<String, dynamic> getTutorialStepStatistics(ProjectionTutorial tutorial) {
    return _service.getTutorialStepStatistics(tutorial);
  }

  /// 验证训练配置
  bool validateTrainingConfig(TrainingConfig config) {
    return _service.validateTrainingConfig(config);
  }

  /// 验证路由有效性
  bool isValidRoute(String route) {
    return _service.isValidRoute(route);
  }

  /// 获取路由显示名称
  String getRouteDisplayName(String route) {
    return _service.getRouteDisplayName(route);
  }
} 