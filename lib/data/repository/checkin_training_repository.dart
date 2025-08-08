import '../api/checkin_training_api.dart';
import '../models/checkin_training_api_model.dart';
import '../../domain/entities/checkin_training/training_result.dart';
import '../../domain/entities/checkin_training/training_history_item.dart';
import '../../domain/entities/checkin_training/training_session_config.dart';

/// 训练仓库接口
abstract class CheckinTrainingRepository {
  /// 获取训练数据和视频配置
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  });

  /// 获取训练历史数据
  Future<List<TrainingHistoryItem>> getTrainingHistory(
    String trainingId, {
    String? productId,
    int? limit,
  });

  /// 提交训练结果
  Future<CheckinTrainingSubmitResponseApiModel> submitTrainingResult(
    TrainingResult result,
  );

  /// 获取视频配置
  Future<Map<String, dynamic>> getVideoConfig(
    String trainingId, {
    String? productId,
  });
}

/// 训练仓库实现
class CheckinTrainingRepositoryImpl implements CheckinTrainingRepository {
  final CheckinTrainingApi _checkinTrainingApi;

  CheckinTrainingRepositoryImpl(this._checkinTrainingApi);

  @override
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    try {
      final result = await _checkinTrainingApi.getTrainingDataAndVideoConfig(
        trainingId,
        productId: productId,
        limit: limit,
      );

      // 转换历史数据为业务实体
      final historyItems = (result['history'] as List<CheckinTrainingHistoryApiModel>)
          .map((apiModel) => _mapToTrainingHistoryItem(apiModel))
          .toList();

      return {
        'history': historyItems,
        'videoConfig': result['videoConfig'],
      };
    } catch (e) {
      throw Exception('Failed to get training data and video config: $e');
    }
  }

  @override
  Future<List<TrainingHistoryItem>> getTrainingHistory(
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
      return result['history'] as List<TrainingHistoryItem>;
    } catch (e) {
      throw Exception('Failed to get training history: $e');
    }
  }

  @override
  Future<CheckinTrainingSubmitResponseApiModel> submitTrainingResult(
    TrainingResult result,
  ) async {
    try {
      final apiModel = _mapToTrainingResultApiModel(result);
      return await _checkinTrainingApi.submitTrainingResult(apiModel);
    } catch (e) {
      throw Exception('Failed to submit training result: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getVideoConfig(
    String trainingId, {
    String? productId,
  }) async {
    try {
      return await _checkinTrainingApi.getVideoConfig(
        trainingId,
        productId: productId,
      );
    } catch (e) {
      throw Exception('Failed to get video config: $e');
    }
  }

  /// 映射API模型到业务实体
  TrainingHistoryItem _mapToTrainingHistoryItem(
    CheckinTrainingHistoryApiModel apiModel,
  ) {
    return TrainingHistoryItem(
      id: apiModel.id,
      rank: apiModel.rank,
      counts: apiModel.counts,
      timestamp: apiModel.timestamp,
      note: apiModel.note,
    );
  }

  /// 映射业务实体到API模型
  CheckinTrainingResultApiModel _mapToTrainingResultApiModel(
    TrainingResult result,
  ) {
    return CheckinTrainingResultApiModel(
      trainingId: result.trainingId,
      productId: result.productId,
      totalRounds: result.totalRounds,
      roundDuration: result.roundDuration,
      maxCounts: result.maxCounts,
      timestamp: result.timestamp,
    );
  }

  /// 映射API模型到业务实体
  TrainingResult _mapToTrainingResult(
    CheckinTrainingResultApiModel apiModel,
  ) {
    return TrainingResult(
      id: '', // API模型中没有id字段，需要从响应中获取
      trainingId: apiModel.trainingId,
      productId: apiModel.productId,
      totalRounds: apiModel.totalRounds,
      roundDuration: apiModel.roundDuration,
      maxCounts: apiModel.maxCounts,
      timestamp: apiModel.timestamp,
    );
  }
} 