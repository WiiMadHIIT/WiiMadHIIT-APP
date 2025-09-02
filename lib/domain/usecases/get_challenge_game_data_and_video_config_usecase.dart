import '../../data/repository/challenge_game_repository.dart';
import '../../data/models/challenge_game_api_model.dart';
import '../entities/challenge_game/challenge_game_history_item.dart';
import '../entities/challenge_game/challenge_game_result.dart';

/// 获取挑战游戏数据和视频配置用例
class GetChallengeGameDataAndVideoConfigUseCase {
  final ChallengeGameRepository repository;

  GetChallengeGameDataAndVideoConfigUseCase(this.repository);

  /// 执行用例：获取挑战游戏数据和视频配置
  Future<Map<String, dynamic>> execute(
    String challengeId, // 🎯 修改：使用challengeId
    {
    int? limit,
  }) {
    return repository.getChallengeGameDataAndVideoConfig(
      challengeId, // 🎯 修改：使用challengeId
      limit: limit,
    );
  }
}

/// 提交挑战游戏结果用例
class SubmitChallengeGameResultUseCase {
  final ChallengeGameRepository repository;

  SubmitChallengeGameResultUseCase(this.repository);

  /// 执行用例：提交挑战游戏结果
  Future<ChallengeGameSubmitResponseApiModel> execute(ChallengeGameResult result) {
    return repository.submitChallengeGameResult(result);
  }
} 