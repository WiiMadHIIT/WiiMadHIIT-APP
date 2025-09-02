import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/challenge_rule_api_model.dart';

class ChallengeRuleApi {
  final Dio _dio = DioClient().dio;

  /// 获取挑战规则
  Future<ChallengeRuleApiModel> fetchChallengeRule(String challengeId) async {
    try {
      final response = await _dio.get('/api/challenge/rules/$challengeId');
      
      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        final result = ChallengeRuleApiModel.fromJson(response.data['data']);
        return result;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch challenge rule');
      }
    } catch (e) {
      print('ChallengeRuleApi: 请求失败: $e');
      rethrow;
    }
  }

  /// 模拟数据方法 - 根据Java后端的伪数据实现
  Future<ChallengeRuleApiModel> fetchChallengeRule_MOCK(String challengeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));
    
    // 根据挑战ID生成对应的规则数据
    return _generateMockChallengeRules(challengeId);
  }

  /// 生成模拟挑战规则数据
  /// 根据Java后端ChallengeServiceImpl.generateMockChallengeRules的实现
  ChallengeRuleApiModel _generateMockChallengeRules(String challengeId) {
    // 根据挑战ID生成不同的挑战规则
    List<ChallengeRuleItemApiModel> challengeRules;
    String nextPageRoute;
    bool isActivated;
    bool isQualified;
    int allowedTimes;
    int totalRounds;
    int roundDuration;
    
    switch (challengeId) {
      case "pk1":
        // 7-Day HIIT Showdown
        challengeRules = [
          ChallengeRuleItemApiModel(
            id: "rule_001",
            title: "Device Setup",
            description: "Switch to P10 mode and P9 speed for optimal HIIT training",
            order: 1
          ),
          ChallengeRuleItemApiModel(
            id: "rule_002",
            title: "Safety Check",
            description: "Ensure you have enough space for high-intensity movements",
            order: 2
          ),
          ChallengeRuleItemApiModel(
            id: "rule_003",
            title: "Ready Position",
            description: "Get into starting position for immediate HIIT training",
            order: 3
          )
        ];
        nextPageRoute = "/challenge_game";
        isActivated = true;
        isQualified = true;
        allowedTimes = 5; // 5次机会
        totalRounds = 3;
        roundDuration = 8;
        break;
        
      case "pk2":
        // 30-Day Fitness Marathon
        challengeRules = [
          ChallengeRuleItemApiModel(
            id: "rule_004",
            title: "Basic Setup",
            description: "Complete basic device setup and safety checks",
            order: 1
          ),
          ChallengeRuleItemApiModel(
            id: "rule_005",
            title: "Simple Check",
            description: "Verify basic functionality and environment safety",
            order: 2
          ),
          ChallengeRuleItemApiModel(
            id: "rule_006",
            title: "Ready Position",
            description: "Get into starting position for basic challenge",
            order: 3
          )
        ];
        nextPageRoute = "/challenge_game";
        isActivated = true;
        isQualified = false; // 需要资格验证
        allowedTimes = 3; // 3次机会
        totalRounds = 3;
        roundDuration = 145;
        break;
        
      case "pk3":
        // Strength Training Challenge
        challengeRules = [
          ChallengeRuleItemApiModel(
            id: "rule_007",
            title: "Advanced Setup",
            description: "Configure advanced settings for professional challenge mode",
            order: 1
          ),
          ChallengeRuleItemApiModel(
            id: "rule_008",
            title: "Performance Check",
            description: "Verify system performance and calibration accuracy",
            order: 2
          ),
          ChallengeRuleItemApiModel(
            id: "rule_009",
            title: "Safety Protocol",
            description: "Complete all safety checks before starting advanced challenge",
            order: 3
          )
        ];
        nextPageRoute = "/challenge_game";
        isActivated = false; // 未激活
        isQualified = false;
        allowedTimes = 0; // 无机会（用于测试已完成状态）
        totalRounds = 2;
        roundDuration = 90;
        break;
        
      default:
        // 默认挑战规则
        challengeRules = [
          ChallengeRuleItemApiModel(
            id: "rule_010",
            title: "Standard Setup",
            description: "Complete standard device setup and safety checks",
            order: 1
          ),
          ChallengeRuleItemApiModel(
            id: "rule_011",
            title: "Standard Check",
            description: "Verify standard functionality and environment safety",
            order: 2
          ),
          ChallengeRuleItemApiModel(
            id: "rule_012",
            title: "Ready Position",
            description: "Get into starting position for standard challenge",
            order: 3
          )
        ];
        nextPageRoute = "/challenge_game";
        isActivated = true;
        isQualified = true;
        allowedTimes = 0; // 已用完次数（用于测试已完成状态）
        totalRounds = 3;
        roundDuration = 80;
        break;
    }

    // 生成挑战配置
    final challengeConfig = ChallengeConfigApiModel(
      nextPageRoute: nextPageRoute,
      isActivated: isActivated,
      isQualified: isQualified,
      allowedTimes: allowedTimes
    );

    return ChallengeRuleApiModel(
      challengeId: challengeId,
      totalRounds: totalRounds,
      roundDuration: roundDuration,
      challengeRules: challengeRules,
      challengeConfig: challengeConfig
    );
  }
} 