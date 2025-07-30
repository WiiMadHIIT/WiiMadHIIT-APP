import '../entities/training_rule.dart';
import '../entities/projection_tutorial.dart';
import '../entities/training_config.dart';

class TrainingRuleService {
  /// 验证训练规则数据的完整性
  bool validateTrainingRuleData({
    required List<TrainingRule> trainingRules,
    required ProjectionTutorial projectionTutorial,
    required TrainingConfig trainingConfig,
  }) {
    return trainingRules.isNotEmpty &&
           projectionTutorial.hasTutorialSteps &&
           trainingConfig.isValid;
  }

  /// 获取排序后的训练规则
  List<TrainingRule> getSortedTrainingRules(List<TrainingRule> rules) {
    final sortedRules = List<TrainingRule>.from(rules);
    sortedRules.sort((a, b) => a.order.compareTo(b.order));
    return sortedRules;
  }

  /// 获取有效的训练规则
  List<TrainingRule> getValidTrainingRules(List<TrainingRule> rules) {
    return rules.where((rule) => rule.isValid).toList();
  }

  /// 验证训练配置的有效性
  bool validateTrainingConfig(TrainingConfig config) {
    return config.isValid && config.isRouteValid;
  }

  /// 获取训练规则统计信息
  Map<String, dynamic> getTrainingRuleStatistics(List<TrainingRule> rules) {
    final validRules = getValidTrainingRules(rules);
    final sortedRules = getSortedTrainingRules(validRules);
    
    return {
      'totalRules': rules.length,
      'validRules': validRules.length,
      'sortedRules': sortedRules,
      'hasRules': validRules.isNotEmpty,
      'firstRule': sortedRules.isNotEmpty ? sortedRules.first : null,
      'lastRule': sortedRules.isNotEmpty ? sortedRules.last : null,
    };
  }

  /// 验证投影教程的完整性
  bool validateProjectionTutorial(ProjectionTutorial tutorial) {
    return tutorial.hasVideo && tutorial.hasTutorialSteps;
  }

  /// 获取教程步骤统计信息
  Map<String, dynamic> getTutorialStepStatistics(ProjectionTutorial tutorial) {
    final sortedSteps = tutorial.sortedSteps;
    
    return {
      'totalSteps': tutorial.stepCount,
      'sortedSteps': sortedSteps,
      'hasSteps': tutorial.hasTutorialSteps,
      'firstStep': tutorial.firstStep,
      'lastStep': tutorial.lastStep,
      'hasVideo': tutorial.hasVideo,
    };
  }

  /// 验证跳转路由的有效性
  bool isValidRoute(String route) {
    final validRoutes = [
      '/checkin_countdown',
      '/checkin_training_voice',
      '/checkin_training',
    ];
    return validRoutes.contains(route);
  }

  /// 获取路由显示名称
  String getRouteDisplayName(String route) {
    switch (route) {
      case '/checkin_countdown':
        return 'Countdown Training';
      case '/checkin_training_voice':
        return 'Voice Training';
      case '/checkin_training':
        return 'Direct Training';
      default:
        return 'Unknown Training';
    }
  }
} 