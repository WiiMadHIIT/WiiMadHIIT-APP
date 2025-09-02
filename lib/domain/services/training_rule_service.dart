import '../entities/training_rule.dart';
import '../entities/training_config.dart';

class TrainingRuleService {
  /// 验证训练规则数据的完整性
  bool validateTrainingRuleData({
    required List<TrainingRule> trainingRules,
    required TrainingConfig trainingConfig,
  }) {
    // 允许trainingRules为空，只要trainingConfig有效即可
    return trainingConfig.isValid;
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

  /// 验证训练是否可以开始
  bool canStartTraining(TrainingConfig config) {
    return config.canStartTraining;
  }

  /// 获取训练激活状态信息
  Map<String, dynamic> getTrainingActivationInfo(TrainingConfig config) {
    return {
      'isActivated': config.isActivated,
      'canStart': config.canStartTraining,
      'statusText': config.activationStatusText,
      'isValid': config.isValid,
    };
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