import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/training_api_model.dart';

class TrainingApi {
  final Dio _dio = DioClient().dio;

  /// 获取训练产品配置
  /// 包含页面配置和训练列表
  Future<TrainingProductApiModel> fetchTrainingProduct(String productId) async {
    final response = await _dio.get('/api/checkin/products/$productId');
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return TrainingProductApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch training product');
    }
  }

  /// 获取模拟训练产品配置（临时使用）
  /// 参考 CheckinServiceImpl.java 中的 createMockTrainingProduct
  Future<TrainingProductApiModel> fetchTrainingProduct_MOCK(String productId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 根据产品ID匹配对应的训练配置
    switch (productId) {
      case "hiit_pro_001":
        return _createHIITProTraining(productId);
      case "yoga_flex_002":
        return _createYogaFlexTraining(productId);
      default:
        return _createDefaultTraining(productId);
    }
  }

  /// 创建HIIT Pro训练配置
  TrainingProductApiModel _createHIITProTraining(String productId) {
    final List<TrainingItemApiModel> trainings = [
      TrainingItemApiModel(
        id: "training_001",
        name: "HIIT Beginner 01",
        level: 1,
        description: "Perfect introduction to HIIT training",
        participantCount: 1250,
        status: "ACTIVE",
      ),
      TrainingItemApiModel(
        id: "training_002",
        name: "HIIT Intermediate 02",
        level: 2,
        description: "Classic Tabata protocol for maximum fat burn",
        participantCount: 890,
        status: "ACTIVE",
      ),
    ];

    final pageConfig = TrainingPageConfigApiModel(
      pageTitle: "HIIT Pro Training",
      pageSubtitle: "High-intensity interval training for maximum results",
      videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video2.mp4",
      thumbnailUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/player_cover.png",
    );

    return TrainingProductApiModel(
      productId: productId,
      pageConfig: pageConfig,
      trainings: trainings,
    );
  }

  /// 创建Yoga Flex训练配置
  TrainingProductApiModel _createYogaFlexTraining(String productId) {
    final List<TrainingItemApiModel> trainings = [
      TrainingItemApiModel(
        id: "training_004",
        name: "Yoga Basics",
        level: 1,
        description: "Gentle yoga flow for beginners",
        participantCount: 980,
        status: "ACTIVE",
      ),
      TrainingItemApiModel(
        id: "training_005",
        name: "Power Yoga",
        level: 2,
        description: "Dynamic vinyasa flow for strength building",
        participantCount: 756,
        status: "ACTIVE",
      ),
    ];

    final pageConfig = TrainingPageConfigApiModel(
      pageTitle: "Yoga Flex Training",
      pageSubtitle: "Find your inner peace and flexibility",
      videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video1.mp4",
      thumbnailUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/player_cover.png",
    );

    return TrainingProductApiModel(
      productId: productId,
      pageConfig: pageConfig,
      trainings: trainings,
    );
  }

  /// 创建默认训练配置
  TrainingProductApiModel _createDefaultTraining(String productId) {
    final List<TrainingItemApiModel> trainings = [
      TrainingItemApiModel(
        id: "default_001",
        name: "Default Training",
        level: 1,
        description: "Default training session",
        participantCount: 100,
        status: "ACTIVE",
      ),
    ];

    final pageConfig = TrainingPageConfigApiModel(
      pageTitle: "Default Training",
      pageSubtitle: "Choose your workout",
      videoUrl: null,  // 使用本地默认视频
      thumbnailUrl: "", // 使用本地默认图片
    );

    return TrainingProductApiModel(
      productId: productId,
      pageConfig: pageConfig,
      trainings: trainings,
    );
  }
} 