import '../api/challenge_rule_api.dart';
import '../models/challenge_rule_api_model.dart';
import '../../domain/entities/challenge_rule/challenge_rule.dart';
import '../../domain/entities/challenge_rule/challenge_config.dart';

class ChallengeRuleRepository {
  final ChallengeRuleApi _api = ChallengeRuleApi();

  Future<Map<String, dynamic>> getChallengeRule(String challengeId) async {
    try {
      final apiModel = await _api.fetchChallengeRule(challengeId);
      
      // 转换为领域实体（不再依赖远程投影教程）
      final challengeRules = apiModel.challengeRules.map((rule) => ChallengeRule(
        id: rule.id,
        title: rule.title,
        description: rule.description,
        order: rule.order,
      )).toList();

      final challengeConfig = ChallengeConfig(
        nextPageRoute: apiModel.challengeConfig.nextPageRoute,
        isActivated: apiModel.challengeConfig.isActivated,
        isQualified: apiModel.challengeConfig.isQualified,
        allowedTimes: apiModel.challengeConfig.allowedTimes,
        totalRounds: apiModel.totalRounds,
        roundDuration: apiModel.roundDuration,
      );

      return {
        'challengeId': apiModel.challengeId,
        'totalRounds': apiModel.totalRounds,
        'roundDuration': apiModel.roundDuration,
        'challengeRules': challengeRules,
        'challengeConfig': challengeConfig,
      };
    } catch (e) {
      // 记录错误但不抛出异常，让UseCase处理默认配置
      print('❌ [ChallengeRuleRepository] API调用失败: $e');
      throw Exception('Failed to fetch challenge rule: $e');
    }
  }
} 