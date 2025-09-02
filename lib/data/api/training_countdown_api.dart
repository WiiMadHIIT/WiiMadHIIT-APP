import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/training_countdown_api_model.dart';

class TrainingCountdownApi {
  final Dio _dio = DioClient().dio;

  /// 获取倒计时训练数据和视频配置
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/checkin/training/countdown/data',
        queryParameters: {
          'trainingId': trainingId,
          if (productId != null) 'productId': productId,
          if (limit != null) 'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        final data = response.data['data'];
        return {
          'history': (data['history'] as List)
              .map((item) => TrainingCountdownHistoryApiModel.fromJson(item))
              .toList(),
          'videoConfig': data['videoConfig'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get countdown training data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 获取倒计时训练历史数据
  Future<List<TrainingCountdownHistoryApiModel>> getTrainingHistory(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    try {
      final result = await getTrainingDataAndVideoConfig(
        trainingId,
        productId: productId,
        limit: limit,
      );
      return result['history'] as List<TrainingCountdownHistoryApiModel>;
    } catch (e) {
      throw Exception('Failed to get countdown training history: $e');
    }
  }

  /// 提交倒计时训练结果
  Future<TrainingCountdownSubmitResponseApiModel> submitTrainingResult(
    TrainingCountdownResultApiModel result,
  ) async {
    try {
      final response = await _dio.post(
        '/api/checkin/training/countdown/submit',
        data: result.toJson(),
      );

      if (response.statusCode == 200 && (response.data['code'] == 'A200' || response.data['code'] == '0')) {
        return TrainingCountdownSubmitResponseApiModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit countdown training result');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 获取倒计时训练视频配置
  Future<Map<String, dynamic>> getVideoConfig(
    String trainingId, {
    String? productId,
  }) async {
    try {
      final result = await getTrainingDataAndVideoConfig(
        trainingId,
        productId: productId,
      );
      return result['videoConfig'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get countdown training video config: $e');
    }
  }

  /// 创建伪数据用于测试
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig_MOCK(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final history = _createMockTrainingHistory(trainingId, productId, limit);
    final videoConfig = _createMockVideoConfig(trainingId, productId);
    
    return {
      'history': history.map((item) => TrainingCountdownHistoryApiModel.fromJson(item)).toList(),
      'videoConfig': videoConfig,
    };
  }

  /// 创建模拟倒计时训练历史记录
  List<Map<String, dynamic>> _createMockTrainingHistory(String trainingId, String? productId, int? limit) {
    final history = <Map<String, dynamic>>[];
    final maxLimit = (limit != null) ? (limit < 10 ? limit : 10) : 10;
    
    int baseSeconds = 900; // 15分钟
    if (productId == "hiit_pro_001") {
      baseSeconds = 1200; // 20分钟
    } else if (productId == "yoga_flex_002") {
      baseSeconds = 600; // 10分钟
    }
    
    for (int i = 0; i < maxLimit; i++) {
      final seconds = baseSeconds + (DateTime.now().millisecondsSinceEpoch % 300).toInt();
      final daySeconds = seconds; // 倒计时训练中，daySeconds 和 seconds 相同
      final rank = i + 1;
      final note = (i == 0) ? "current" : null;
      
      history.add({
        "id": "countdown_history_${trainingId}_$i",
        "rank": rank,
        "daySeconds": daySeconds,
        "seconds": seconds,
        "note": note,
      });
    }
    
    return history;
  }

  /// 创建模拟倒计时训练视频配置
  Map<String, dynamic> _createMockVideoConfig(String trainingId, String? productId) {
    String portraitUrl;
    String landscapeUrl;
    
    switch (productId) {
      case "hiit_pro_001":
        portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/countdown_training_portrait.mp4";
        landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/countdown_training_landscape.mp4";
        break;
      case "yoga_flex_002":
        portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/countdown_training_portrait.mp4";
        landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/countdown_training_landscape.mp4";
        break;
      default:
        portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/countdown_training_portrait.mp4";
        landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/countdown_training_landscape.mp4";
        break;
    }
    
    return {
      "portraitUrl": portraitUrl,
      "landscapeUrl": landscapeUrl,
    };
  }
} 