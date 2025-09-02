import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/checkin_training_voice_api_model.dart';

class CheckinTrainingVoiceApi {
  final Dio _dio = DioClient().dio;

  /// 获取语音训练数据和视频配置
  /// 包含历史排名数据和视频配置信息
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/checkin/training/voice/data',
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
              .map((item) => CheckinTrainingVoiceHistoryApiModel.fromJson(item))
              .toList(),
          'videoConfig': data['videoConfig'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get voice training data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 获取语音训练历史数据
  Future<List<CheckinTrainingVoiceHistoryApiModel>> getTrainingHistory(
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
      return result['history'] as List<CheckinTrainingVoiceHistoryApiModel>;
    } catch (e) {
      throw Exception('Failed to get voice training history: $e');
    }
  }

  /// 提交语音训练结果
  Future<CheckinTrainingVoiceSubmitResponseApiModel> submitTrainingResult(
    CheckinTrainingVoiceResultApiModel result,
  ) async {
    try {
      final response = await _dio.post(
        '/api/checkin/training/voice/submit',
        data: result.toJson(),
      );

      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        return CheckinTrainingVoiceSubmitResponseApiModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit voice training result');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 获取视频配置
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
      throw Exception('Failed to get video config: $e');
    }
  }

  /// 创建伪数据用于测试 - 对应后端 createMockTrainingData 方法
  /// 模拟后端 CheckinServiceImpl.createMockTrainingData 的数据结构
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig_MOCK(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 创建历史训练记录 - 对应后端 createMockTrainingHistory
    final history = _createMockTrainingHistory(trainingId, productId, limit);
    
    // 创建视频配置 - 对应后端 createMockVideoConfig
    final videoConfig = _createMockVideoConfig(trainingId, productId);
    
    return {
      'history': history.map((item) => CheckinTrainingVoiceHistoryApiModel.fromJson(item)).toList(),
      'videoConfig': videoConfig,
    };
  }

  /// 创建模拟训练历史记录 - 对应后端方法
  List<Map<String, dynamic>> _createMockTrainingHistory(String trainingId, String? productId, int? limit) {
    final history = <Map<String, dynamic>>[];
    
    // 设置默认限制 - 对应后端逻辑
    final maxLimit = (limit != null) ? (limit < 10 ? limit : 10) : 10;
    
    // 根据产品ID生成不同的历史数据 - 对应后端逻辑
    int baseCounts = 15;
    if (productId == "hiit_pro_001") {
      baseCounts = 25; // HIIT训练通常有更高的次数
    } else if (productId == "yoga_flex_002") {
      baseCounts = 10; // 瑜伽训练次数相对较少
    }
    
    // 生成历史记录 - 对应后端逻辑
    for (int i = 0; i < maxLimit; i++) {
      final timestamp = DateTime.now().millisecondsSinceEpoch - (i * 24 * 60 * 60 * 1000); // 每天一条记录
      final counts = baseCounts + (DateTime.now().millisecondsSinceEpoch % 10).toInt(); // 随机变化
      final rank = i + 1;
      
      // 计算每分钟标准化计数：使用合理的默认训练时长30秒
      final countsPerMin = double.parse(((counts * 60.0) / 30.0).toStringAsFixed(2));
      
      history.add({
        "id": "voice_history_${trainingId}_$i",
        "rank": rank,
        "counts": counts,
        "countsPerMin": countsPerMin,
        "timestamp": timestamp,
      });
    }
    
    return history;
  }

  /// 创建模拟视频配置 - 对应后端方法
  Map<String, dynamic> _createMockVideoConfig(String trainingId, String? productId) {
    String portraitUrl;
    String landscapeUrl;
    
    // 根据产品ID设置不同的视频URL - 对应后端逻辑
    switch (productId) {
      case "hiit_pro_001":
        portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/hiit_voice_portrait.mp4";
        landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/hiit_voice_landscape.mp4";
        break;
      case "yoga_flex_002":
        portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/yoga_voice_portrait.mp4";
        landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/yoga_voice_landscape.mp4";
        break;
      default:
        portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/voice_default_portrait.mp4";
        landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/voice_default_landscape.mp4";
        break;
    }
    
    return {
      "portraitUrl": portraitUrl,
      "landscapeUrl": landscapeUrl,
    };
  }
} 