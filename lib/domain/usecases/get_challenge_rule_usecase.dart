import '../../data/repository/challenge_rule_repository.dart';
import '../entities/challenge_rule/challenge_rule.dart';
import '../entities/challenge_rule/challenge_config.dart';
import '../services/challenge_rule_service.dart';

class GetChallengeRuleUseCase {
  final ChallengeRuleRepository _repository;
  final ChallengeRuleService _service;

  GetChallengeRuleUseCase({
    ChallengeRuleRepository? repository,
    ChallengeRuleService? service,
  }) : _repository = repository ?? ChallengeRuleRepository(),
       _service = service ?? ChallengeRuleService();

  /// 执行获取挑战规则用例
  Future<Map<String, dynamic>> execute(String challengeId) async {
    // 从仓库获取数据
    final data = await _repository.getChallengeRule(challengeId);
    
    final challengeRules = data['challengeRules'] as List<ChallengeRule>;
    final challengeConfig = data['challengeConfig'] as ChallengeConfig;
    final totalRounds = data['totalRounds'] as int;
    final roundDuration = data['roundDuration'] as int;

    // 验证数据完整性
    if (!_service.validateChallengeRuleData(
      challengeRules: challengeRules,
      challengeConfig: challengeConfig,
    )) {
      throw Exception('Invalid challenge rule data');
    }

    // 获取统计信息
    final ruleStatistics = _service.getChallengeRuleStatistics(challengeRules);
    final configStatistics = _service.getChallengeConfigStatistics(challengeConfig);

    return {
      'challengeId': data['challengeId'],
      'totalRounds': totalRounds,
      'roundDuration': roundDuration,
      'challengeRules': challengeRules,
      'challengeConfig': challengeConfig,
      'ruleStatistics': ruleStatistics,
      'configStatistics': configStatistics,
      'isValid': true,
    };
  }

  /// 获取挑战规则统计信息
  Map<String, dynamic> getChallengeRuleStatistics(List<ChallengeRule> rules) {
    return _service.getChallengeRuleStatistics(rules);
  }

  // 远程投影教程已移除（保留本地弹层），不再提供教程统计

  /// 获取挑战配置统计信息
  Map<String, dynamic> getChallengeConfigStatistics(ChallengeConfig config) {
    return _service.getChallengeConfigStatistics(config);
  }

  /// 验证挑战配置
  bool validateChallengeConfig(ChallengeConfig config) {
    return _service.validateChallengeConfig(config);
  }

  /// 验证路由有效性
  bool isValidRoute(String route) {
    return _service.isValidRoute(route);
  }

  /// 获取路由显示名称
  String getRouteDisplayName(String route) {
    return _service.getRouteDisplayName(route);
  }

  /// 检查挑战是否可以开始
  bool canStartChallenge(ChallengeConfig config) {
    return _service.canStartChallenge(config);
  }

  /// 获取挑战状态描述
  String getChallengeStatusDescription(ChallengeConfig config) {
    return _service.getChallengeStatusDescription(config);
  }

  /// 获取挑战配置摘要
  String getChallengeConfigSummary(ChallengeConfig config) {
    return _service.getChallengeConfigSummary(config);
  }
} 