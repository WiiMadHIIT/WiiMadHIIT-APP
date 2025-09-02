import '../../data/repository/checkin_training_voice_repository.dart';
import '../../data/models/checkin_training_voice_api_model.dart';
import '../entities/checkin_training_voice/training_voice_history_item.dart';
import '../entities/checkin_training_voice/training_voice_result.dart';

/// 获取语音训练数据和视频配置用例
class GetTrainingVoiceDataAndVideoConfigUseCase {
  final CheckinTrainingVoiceRepository repository;

  GetTrainingVoiceDataAndVideoConfigUseCase(this.repository);

  /// 执行用例：获取语音训练数据和视频配置
  Future<Map<String, dynamic>> execute(
    String trainingId, {
    String? productId,
    int? limit,
  }) {
    return repository.getTrainingDataAndVideoConfig(
      trainingId,
      productId: productId,
      limit: limit,
    );
  }
}

/// 获取语音训练历史数据用例
class GetTrainingVoiceHistoryUseCase {
  final CheckinTrainingVoiceRepository repository;

  GetTrainingVoiceHistoryUseCase(this.repository);

  /// 执行用例：获取语音训练历史数据
  Future<List<TrainingVoiceHistoryItem>> execute(
    String trainingId, {
    String? productId,
    int? limit,
  }) {
    return repository.getTrainingHistory(
      trainingId,
      productId: productId,
      limit: limit,
    );
  }
}

/// 提交语音训练结果用例
class SubmitTrainingVoiceResultUseCase {
  final CheckinTrainingVoiceRepository repository;

  SubmitTrainingVoiceResultUseCase(this.repository);

  /// 执行用例：提交语音训练结果
  Future<CheckinTrainingVoiceSubmitResponseApiModel> execute(TrainingVoiceResult result) {
    return repository.submitTrainingResult(result);
  }
}

/// 获取语音训练视频配置用例
class GetTrainingVoiceVideoConfigUseCase {
  final CheckinTrainingVoiceRepository repository;

  GetTrainingVoiceVideoConfigUseCase(this.repository);

  /// 执行用例：获取语音训练视频配置
  Future<Map<String, dynamic>> execute(
    String trainingId, {
    String? productId,
  }) {
    return repository.getVideoConfig(
      trainingId,
      productId: productId,
    );
  }
} 