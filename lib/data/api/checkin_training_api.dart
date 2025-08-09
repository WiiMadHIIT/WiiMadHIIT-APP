import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/checkin_training_api_model.dart';

class CheckinTrainingApi {
  final Dio _dio = DioClient().dio;

  /// 获取训练数据和视频配置
  /// 包含历史排名数据和视频配置信息
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/checkin/training/data',
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
              .map((item) => CheckinTrainingHistoryApiModel.fromJson(item))
              .toList(),
          'videoConfig': data['videoConfig'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get training data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 获取训练历史数据
  Future<List<CheckinTrainingHistoryApiModel>> getTrainingHistory(
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
      return result['history'] as List<CheckinTrainingHistoryApiModel>;
    } catch (e) {
      throw Exception('Failed to get training history: $e');
    }
  }

  /// 提交训练结果
  Future<CheckinTrainingSubmitResponseApiModel> submitTrainingResult(
    CheckinTrainingResultApiModel result,
  ) async {
    try {
      final response = await _dio.post(
        '/api/checkin/training/submit',
        data: result.toJson(),
      );

      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        return CheckinTrainingSubmitResponseApiModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit training result');
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
} 