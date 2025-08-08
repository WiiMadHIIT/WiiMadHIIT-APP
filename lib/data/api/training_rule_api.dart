import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/training_rule_api_model.dart';

class TrainingRuleApi {
  final Dio _dio = DioClient().dio;

  Future<TrainingRuleApiModel> fetchTrainingRule(String trainingId, String productId) async {
    final response = await _dio.get('/api/checkin/rules/$trainingId', queryParameters: {
      'productId': productId,
    });
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return TrainingRuleApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }

  /// 获取模拟训练规则（临时使用）
  /// 参考 CheckinServiceImpl.java 中的 createMockTrainingRule
  // Future<TrainingRuleApiModel> fetchTrainingRule(String trainingId, String productId) async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 500));
    
  //   // 根据产品ID分配不同的训练规则类型
  //   switch (productId) {
  //     case "hiit_pro_001":
  //       // HIIT Pro 产品使用直接训练规则
  //       return _createDirectTrainingRule(trainingId, productId);
  //     case "yoga_flex_002":
  //       // Yoga Flex 产品使用倒计时训练规则
  //       return _createCountdownTrainingRule(trainingId, productId);
  //     default:
  //       // 默认使用语音训练规则
  //       return _createVoiceTrainingRule(trainingId, productId);
  //   }
  // }

  /// 创建语音训练规则
  // TrainingRuleApiModel _createVoiceTrainingRule(String trainingId, String productId) {
  //   final trainingRules = [
  //     TrainingRuleItemApiModel(
  //       id: "rule_007",
  //       title: "Voice Setup",
  //       description: "Enable voice guidance in settings",
  //       order: 1,
  //     ),
  //     TrainingRuleItemApiModel(
  //       id: "rule_008",
  //       title: "Microphone Check",
  //       description: "Test your microphone before starting",
  //       order: 2,
  //     ),
  //     TrainingRuleItemApiModel(
  //       id: "rule_009",
  //       title: "Environment Setup",
  //       description: "Find a quiet space for voice training",
  //       order: 3,
  //     ),
  //   ];

  //   final tutorialSteps = [
  //     TutorialStepApiModel(
  //       number: 1,
  //       title: "Enable Voice",
  //       description: "Turn on voice guidance in app settings",
  //     ),
  //     TutorialStepApiModel(
  //       number: 2,
  //       title: "Test Microphone",
  //       description: "Speak clearly to test voice recognition",
  //     ),
  //     TutorialStepApiModel(
  //       number: 3,
  //       title: "Start Training",
  //       description: "Begin your voice-guided workout",
  //     ),
  //   ];

  //   final videoInfo = VideoInfoApiModel(
  //     videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video3.mp4",
  //     title: "Voice Training Tutorial",
  //   );

  //   final projectionTutorial = ProjectionTutorialApiModel(
  //     videoInfo: videoInfo,
  //     tutorialSteps: tutorialSteps,
  //   );

  //   final trainingConfig = TrainingConfigApiModel(
  //     nextPageRoute: "/checkin_training_voice",
  //   );

  //   return TrainingRuleApiModel(
  //     trainingId: trainingId,
  //     productId: productId,
  //     trainingRules: trainingRules,
  //     projectionTutorial: projectionTutorial,
  //     trainingConfig: trainingConfig,
  //   );
  // }

  /// 创建直接训练规则
  // TrainingRuleApiModel _createDirectTrainingRule(String trainingId, String productId) {
  //   final trainingRules = [
  //     TrainingRuleItemApiModel(
  //       id: "rule_001",
  //       title: "HIIT Setup",
  //       description: "Switch to P10 mode and P9 speed for optimal HIIT training",
  //       order: 1,
  //     ),
  //     TrainingRuleItemApiModel(
  //       id: "rule_002",
  //       title: "Safety Check",
  //       description: "Ensure you have enough space for high-intensity movements",
  //       order: 2,
  //     ),
  //     TrainingRuleItemApiModel(
  //       id: "rule_003",
  //       title: "Ready Position",
  //       description: "Get into starting position for immediate HIIT training",
  //       order: 3,
  //     ),
  //   ];

  //   final tutorialSteps = [
  //     TutorialStepApiModel(
  //       number: 1,
  //       title: "HIIT Preparation",
  //       description: "Prepare for high-intensity interval training",
  //     ),
  //     TutorialStepApiModel(
  //       number: 2,
  //       title: "Safety First",
  //       description: "Check your surroundings for safe HIIT movements",
  //     ),
  //     TutorialStepApiModel(
  //       number: 3,
  //       title: "Start HIIT",
  //       description: "Begin your high-intensity workout immediately",
  //     ),
  //   ];

  //   final videoInfo = VideoInfoApiModel(
  //     videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video1.mp4",
  //     title: "HIIT Training Tutorial",
  //   );

  //   final projectionTutorial = ProjectionTutorialApiModel(
  //     videoInfo: videoInfo,
  //     tutorialSteps: tutorialSteps,
  //   );

  //   final trainingConfig = TrainingConfigApiModel(
  //     nextPageRoute: "/checkin_training",
  //   );

  //   return TrainingRuleApiModel(
  //     trainingId: trainingId,
  //     productId: productId,
  //     trainingRules: trainingRules,
  //     projectionTutorial: projectionTutorial,
  //     trainingConfig: trainingConfig,
  //   );
  // }

  /// 创建倒计时训练规则
  // TrainingRuleApiModel _createCountdownTrainingRule(String trainingId, String productId) {
  //   final trainingRules = [
  //     TrainingRuleItemApiModel(
  //       id: "rule_004",
  //       title: "Yoga Setup",
  //       description: "Find a quiet space and prepare your yoga mat",
  //       order: 1,
  //     ),
  //     TrainingRuleItemApiModel(
  //       id: "rule_005",
  //       title: "Breathing Check",
  //       description: "Take a moment to center your breath",
  //       order: 2,
  //     ),
  //     TrainingRuleItemApiModel(
  //       id: "rule_006",
  //       title: "Ready Position",
  //       description: "Get into comfortable seated position for yoga",
  //       order: 3,
  //     ),
  //   ];

  //   final tutorialSteps = [
  //     TutorialStepApiModel(
  //       number: 1,
  //       title: "Yoga Preparation",
  //       description: "Set up your yoga space and mat",
  //     ),
  //     TutorialStepApiModel(
  //       number: 2,
  //       title: "Mindful Breathing",
  //       description: "Take deep breaths to center yourself",
  //     ),
  //     TutorialStepApiModel(
  //       number: 3,
  //       title: "Begin Yoga",
  //       description: "Start your yoga session with mindfulness",
  //     ),
  //   ];

  //   final videoInfo = VideoInfoApiModel(
  //     videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video2.mp4",
  //     title: "Yoga Training Tutorial",
  //   );

  //   final projectionTutorial = ProjectionTutorialApiModel(
  //     videoInfo: videoInfo,
  //     tutorialSteps: tutorialSteps,
  //   );

  //   final trainingConfig = TrainingConfigApiModel(
  //     nextPageRoute: "/checkin_countdown",
  //   );

  //   return TrainingRuleApiModel(
  //     trainingId: trainingId,
  //     productId: productId,
  //     trainingRules: trainingRules,
  //     projectionTutorial: projectionTutorial,
  //     trainingConfig: trainingConfig,
  //   );
  // }
} 