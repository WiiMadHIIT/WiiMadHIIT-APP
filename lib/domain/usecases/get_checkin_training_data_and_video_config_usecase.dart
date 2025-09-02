import '../../data/repository/checkin_training_repository.dart';
import '../../data/models/checkin_training_api_model.dart';
import '../entities/checkin_training/checkin_training_history_item.dart';
import '../entities/checkin_training/checkin_training_result.dart';

/// 获取训练数据和视频配置用例
class GetCheckinTrainingDataAndVideoConfigUseCase {
  final CheckinTrainingRepository repository;

  GetCheckinTrainingDataAndVideoConfigUseCase(this.repository);

  /// 执行用例：获取训练数据和视频配置
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

/// 提交训练结果用例
class SubmitCheckinTrainingResultUseCase {
  final CheckinTrainingRepository repository;

  SubmitCheckinTrainingResultUseCase(this.repository);

  /// 执行用例：提交训练结果
  Future<CheckinTrainingSubmitResponseApiModel> execute(CheckinTrainingResult result) {
    return repository.submitTrainingResult(result);
  }
} 