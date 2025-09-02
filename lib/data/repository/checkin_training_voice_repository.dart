import '../api/checkin_training_voice_api.dart';
import '../models/checkin_training_voice_api_model.dart';
import '../../domain/entities/checkin_training_voice/training_voice_result.dart';
import '../../domain/entities/checkin_training_voice/training_voice_history_item.dart';
import '../../domain/entities/checkin_training_voice/training_voice_session_config.dart';

/// 语音训练仓库接口
abstract class CheckinTrainingVoiceRepository {
  /// 获取语音训练数据和视频配置
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  });

  /// 获取语音训练历史数据
  Future<List<TrainingVoiceHistoryItem>> getTrainingHistory(
    String trainingId, {
    String? productId,
    int? limit,
  });

  /// 提交语音训练结果
  Future<CheckinTrainingVoiceSubmitResponseApiModel> submitTrainingResult(
    TrainingVoiceResult result,
  );

  /// 获取视频配置
  Future<Map<String, dynamic>> getVideoConfig(
    String trainingId, {
    String? productId,
  });
}

/// 语音训练仓库实现
class CheckinTrainingVoiceRepositoryImpl implements CheckinTrainingVoiceRepository {
  final CheckinTrainingVoiceApi _checkinTrainingVoiceApi;

  CheckinTrainingVoiceRepositoryImpl(this._checkinTrainingVoiceApi);

  @override
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    try {
      final result = await _checkinTrainingVoiceApi.getTrainingDataAndVideoConfig(
        trainingId,
        productId: productId,
        limit: limit,
      );

      // 转换历史数据为业务实体
      final historyItems = (result['history'] as List<CheckinTrainingVoiceHistoryApiModel>)
          .map((apiModel) => _mapToTrainingHistoryItem(apiModel))
          .toList();

      return {
        'history': historyItems,
        'videoConfig': result['videoConfig'],
      };
    } catch (e) {
      throw Exception('Failed to get voice training data and video config: $e');
    }
  }

  @override
  Future<List<TrainingVoiceHistoryItem>> getTrainingHistory(
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
      return result['history'] as List<TrainingVoiceHistoryItem>;
    } catch (e) {
      throw Exception('Failed to get voice training history: $e');
    }
  }

  @override
  Future<CheckinTrainingVoiceSubmitResponseApiModel> submitTrainingResult(
    TrainingVoiceResult result,
  ) async {
    try {
      final apiModel = _mapToTrainingResultApiModel(result);
      return await _checkinTrainingVoiceApi.submitTrainingResult(apiModel);
    } catch (e) {
      throw Exception('Failed to submit voice training result: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getVideoConfig(
    String trainingId, {
    String? productId,
  }) async {
    try {
      return await _checkinTrainingVoiceApi.getVideoConfig(
        trainingId,
        productId: productId,
      );
    } catch (e) {
      throw Exception('Failed to get voice training video config: $e');
    }
  }

  /// 映射API模型到业务实体
  TrainingVoiceHistoryItem _mapToTrainingHistoryItem(
    CheckinTrainingVoiceHistoryApiModel apiModel,
  ) {
    return TrainingVoiceHistoryItem(
      id: apiModel.id,
      rank: apiModel.rank,
      counts: apiModel.counts,
      countsPerMin: apiModel.countsPerMin,
      timestamp: apiModel.timestamp,
      note: null, // note字段不从后端获取，可以为null
    );
  }

  /// 映射业务实体到API模型
  CheckinTrainingVoiceResultApiModel _mapToTrainingResultApiModel(
    TrainingVoiceResult result,
  ) {
    return CheckinTrainingVoiceResultApiModel(
      trainingId: result.trainingId,
      productId: result.productId,
      countsPerMin: result.countsPerMin,
      totalSeconds: result.totalSeconds,
    );
  }

  /// 映射API模型到业务实体
  TrainingVoiceResult _mapToTrainingResult(
    CheckinTrainingVoiceResultApiModel apiModel,
  ) {
    return TrainingVoiceResult(
      id: '', // API模型中没有id字段，需要从响应中获取
      trainingId: apiModel.trainingId,
      productId: apiModel.productId,
      countsPerMin: apiModel.countsPerMin,
      totalSeconds: apiModel.totalSeconds,
      counts: 0, // 从countsPerMin和totalSeconds计算counts
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
} 