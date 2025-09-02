import '../api/training_countdown_api.dart';
import '../models/training_countdown_api_model.dart';
import '../../domain/entities/checkin_countdown/training_countdown_result.dart';
import '../../domain/entities/checkin_countdown/training_countdown_history_item.dart';
import '../../domain/entities/checkin_countdown/training_countdown_session_config.dart';

/// 倒计时训练仓库接口
abstract class TrainingCountdownRepository {
  /// 获取倒计时训练数据和视频配置
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  });

  /// 获取倒计时训练历史数据
  Future<List<TrainingCountdownHistoryItem>> getTrainingHistory(
    String trainingId, {
    String? productId,
    int? limit,
  });

  /// 提交倒计时训练结果
  Future<TrainingCountdownSubmitResponseApiModel> submitTrainingResult(
    TrainingCountdownResult result,
  );

  /// 获取视频配置
  Future<Map<String, dynamic>> getVideoConfig(
    String trainingId, {
    String? productId,
  });
}

/// 倒计时训练仓库实现
class TrainingCountdownRepositoryImpl implements TrainingCountdownRepository {
  final TrainingCountdownApi _trainingCountdownApi;

  TrainingCountdownRepositoryImpl(this._trainingCountdownApi);

  @override
  Future<Map<String, dynamic>> getTrainingDataAndVideoConfig(
    String trainingId, {
    String? productId,
    int? limit,
  }) async {
    try {
      final result = await _trainingCountdownApi.getTrainingDataAndVideoConfig(
        trainingId,
        productId: productId,
        limit: limit,
      );

      // 转换历史数据为业务实体
      final historyItems = (result['history'] as List<TrainingCountdownHistoryApiModel>)
          .map((apiModel) => _mapToTrainingHistoryItem(apiModel))
          .toList();

      return {
        'history': historyItems,
        'videoConfig': result['videoConfig'],
      };
    } catch (e) {
      throw Exception('Failed to get countdown training data and video config: $e');
    }
  }

  @override
  Future<List<TrainingCountdownHistoryItem>> getTrainingHistory(
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
      return result['history'] as List<TrainingCountdownHistoryItem>;
    } catch (e) {
      throw Exception('Failed to get countdown training history: $e');
    }
  }

  @override
  Future<TrainingCountdownSubmitResponseApiModel> submitTrainingResult(
    TrainingCountdownResult result,
  ) async {
    try {
      final apiModel = _mapToTrainingResultApiModel(result);
      return await _trainingCountdownApi.submitTrainingResult(apiModel);
    } catch (e) {
      throw Exception('Failed to submit countdown training result: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getVideoConfig(
    String trainingId, {
    String? productId,
  }) async {
    try {
      return await _trainingCountdownApi.getVideoConfig(
        trainingId,
        productId: productId,
      );
    } catch (e) {
      throw Exception('Failed to get countdown training video config: $e');
    }
  }

  /// 映射API模型到业务实体
  TrainingCountdownHistoryItem _mapToTrainingHistoryItem(
    TrainingCountdownHistoryApiModel apiModel,
  ) {
    return TrainingCountdownHistoryItem(
      id: apiModel.id,
      rank: apiModel.rank,
      daySeconds: apiModel.daySeconds,
      seconds: apiModel.seconds,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      note: apiModel.note,
    );
  }

  /// 映射业务实体到API模型
  TrainingCountdownResultApiModel _mapToTrainingResultApiModel(
    TrainingCountdownResult result,
  ) {
    return TrainingCountdownResultApiModel(
      trainingId: result.trainingId,
      productId: result.productId,
      seconds: result.seconds,
    );
  }

  /// 映射API模型到业务实体
  TrainingCountdownResult _mapToTrainingResult(
    TrainingCountdownResultApiModel apiModel,
  ) {
    return TrainingCountdownResult(
      id: '', // API模型中没有id字段，需要从响应中获取
      trainingId: apiModel.trainingId,
      productId: apiModel.productId,
      seconds: apiModel.seconds,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 映射提交响应到业务实体（新增方法）
  TrainingCountdownResult _mapSubmitResponseToResult(
    TrainingCountdownSubmitResponseApiModel response,
    TrainingCountdownResult originalResult,
  ) {
    return TrainingCountdownResult(
      id: response.id,
      trainingId: originalResult.trainingId,
      productId: originalResult.productId,
      totalRounds: originalResult.totalRounds,
      roundDuration: originalResult.roundDuration,
      seconds: response.daySeconds, // 使用返回的 daySeconds
      timestamp: originalResult.timestamp,
    );
  }
} 