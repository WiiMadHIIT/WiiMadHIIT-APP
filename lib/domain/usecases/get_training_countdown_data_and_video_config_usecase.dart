import '../../data/repository/training_countdown_repository.dart';
import '../../data/models/training_countdown_api_model.dart';
import '../entities/checkin_countdown/training_countdown_history_item.dart';
import '../entities/checkin_countdown/training_countdown_result.dart';

/// 获取倒计时训练数据和视频配置用例
class GetTrainingCountdownDataAndVideoConfigUseCase {
  final TrainingCountdownRepository repository;

  GetTrainingCountdownDataAndVideoConfigUseCase(this.repository);

  /// 执行用例：获取倒计时训练数据和视频配置
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

/// 获取倒计时训练历史数据用例
class GetTrainingCountdownHistoryUseCase {
  final TrainingCountdownRepository repository;

  GetTrainingCountdownHistoryUseCase(this.repository);

  /// 执行用例：获取倒计时训练历史数据
  Future<List<TrainingCountdownHistoryItem>> execute(
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

/// 提交倒计时训练结果用例
class SubmitTrainingCountdownResultUseCase {
  final TrainingCountdownRepository repository;

  SubmitTrainingCountdownResultUseCase(this.repository);

  /// 执行用例：提交倒计时训练结果
  Future<TrainingCountdownSubmitResponseApiModel> execute(TrainingCountdownResult result) {
    return repository.submitTrainingResult(result);
  }
}

/// 获取倒计时训练视频配置用例
class GetTrainingCountdownVideoConfigUseCase {
  final TrainingCountdownRepository repository;

  GetTrainingCountdownVideoConfigUseCase(this.repository);

  /// 执行用例：获取倒计时训练视频配置
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