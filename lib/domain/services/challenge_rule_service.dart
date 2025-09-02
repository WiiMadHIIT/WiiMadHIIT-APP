import '../entities/challenge_rule/challenge_rule.dart';
import '../entities/challenge_rule/challenge_config.dart';

class ChallengeRuleService {
  /// 验证挑战规则数据的完整性
  bool validateChallengeRuleData({
    required List<ChallengeRule> challengeRules,
    required ChallengeConfig challengeConfig,
  }) {
    return challengeRules.isNotEmpty &&
           challengeConfig.isValid;
  }

  /// 获取排序后的挑战规则
  List<ChallengeRule> getSortedChallengeRules(List<ChallengeRule> rules) {
    final sortedRules = List<ChallengeRule>.from(rules);
    sortedRules.sort((a, b) => a.order.compareTo(b.order));
    return sortedRules;
  }

  /// 获取有效的挑战规则
  List<ChallengeRule> getValidChallengeRules(List<ChallengeRule> rules) {
    return rules.where((rule) => rule.isValid).toList();
  }

  /// 验证挑战配置的有效性
  bool validateChallengeConfig(ChallengeConfig config) {
    return config.isValid && config.isActivated;
  }

  /// 获取挑战规则统计信息
  Map<String, dynamic> getChallengeRuleStatistics(List<ChallengeRule> rules) {
    final validRules = getValidChallengeRules(rules);
    final sortedRules = getSortedChallengeRules(validRules);
    
    return {
      'totalRules': rules.length,
      'validRules': validRules.length,
      'sortedRules': sortedRules,
      'hasRules': validRules.isNotEmpty,
      'firstRule': sortedRules.isNotEmpty ? sortedRules.first : null,
      'lastRule': sortedRules.isNotEmpty ? sortedRules.last : null,
    };
  }

  /// 获取挑战配置统计信息
  Map<String, dynamic> getChallengeConfigStatistics(ChallengeConfig config) {
    return {
      'totalRounds': config.totalRounds,
      'roundDuration': config.roundDuration,
      'totalDurationInSeconds': config.totalDurationInSeconds,
      'totalDurationDisplayText': config.totalDurationDisplayText,
      'roundsDisplayText': config.roundsDisplayText,
      'durationDisplayText': config.durationDisplayText,
      'isActivated': config.isActivated,
      'isQualified': config.isQualified,
      'allowedTimes': config.allowedTimes,
      'canStartChallenge': config.canStartChallenge,
    };
  }

  // 远程投影教程已移除（本地弹层保留），不再校验或统计

  /// 验证跳转路由的有效性
  bool isValidRoute(String route) {
    final validRoutes = [
      '/challenge_game',
      '/challenge_game_advanced',
      '/challenge_game_basic',
    ];
    return validRoutes.contains(route);
  }

  /// 获取路由显示名称
  String getRouteDisplayName(String route) {
    switch (route) {
      case '/challenge_game':
        return 'Challenge Game';
      case '/challenge_game_advanced':
        return 'Advanced Challenge';
      case '/challenge_game_basic':
        return 'Basic Challenge';
      default:
        return 'Unknown Challenge';
    }
  }

  /// 检查挑战是否可以开始
  bool canStartChallenge(ChallengeConfig config) {
    return config.canStartChallenge;
  }

  /// 获取挑战状态描述
  String getChallengeStatusDescription(ChallengeConfig config) {
    if (!config.isActivated) {
      return 'Challenge is not activated yet. Please wait for activation.';
    }
    if (!config.isQualified) {
      return 'You need to qualify for this challenge before starting.';
    }
    if (config.allowedTimes <= 0) {
      return 'Challenge completed! Check results in Profile > Challenges.';
    }
    return 'Challenge is ready to start! ${config.totalDurationDisplayText}';
  }

  /// 获取挑战配置摘要
  String getChallengeConfigSummary(ChallengeConfig config) {
    return '${config.roundsDisplayText}, ${config.durationDisplayText} (${config.totalDurationDisplayText})';
  }
} 