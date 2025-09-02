import '../api/checkin_training_api.dart';
import '../models/checkin_training_api_model.dart';
import '../../domain/entities/checkin_training/checkin_training_result.dart';
import '../../domain/entities/checkin_training/checkin_training_history_item.dart';
import '../../domain/entities/checkin_training/checkin_training_session_config.dart';

/// 训练仓库接口
abstract class CheckinTrainingRepository {
  /// 获取训练数据和视频配置
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  });

  /// 提交训练结果
  Future<CheckinTrainingSubmitResponseApiModel> submitTrainingResult(
    CheckinTrainingResult result,
  );
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
  Future<CheckinTrainingSubmitResponseApiModel> submitTrainingResult(
    CheckinTrainingResult result,
  ) async {
    try {
      final apiModel = _mapToTrainingResultApiModel(result);
      return await _checkinTrainingApi.submitTrainingResult(apiModel);
    } catch (e) {
      throw Exception('Failed to submit training result: $e');
    }
  }

  /// 映射API模型到业务实体
  CheckinTrainingHistoryItem _mapToTrainingHistoryItem(
    CheckinTrainingHistoryApiModel apiModel,
  ) {
    return CheckinTrainingHistoryItem(
      id: apiModel.id,
      rank: apiModel.rank,
      counts: apiModel.counts,
      countsPerMin: apiModel.countsPerMin,
      timestamp: apiModel.timestamp,
      note: null, // note字段不从后端获取，可以为null
    );
  }

  /// 映射业务实体到API模型
  CheckinTrainingResultApiModel _mapToTrainingResultApiModel(
    CheckinTrainingResult result,
  ) {
    return CheckinTrainingResultApiModel(
      trainingId: result.trainingId,
      productId: result.productId,
      countsPerMin: result.countsPerMin,
      totalSeconds: result.totalSeconds, // 直接使用totalSeconds
    );
  }

  /// 映射API模型到业务实体
  CheckinTrainingResult _mapToTrainingResult(
    CheckinTrainingResultApiModel apiModel,
  ) {
    return CheckinTrainingResult(
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