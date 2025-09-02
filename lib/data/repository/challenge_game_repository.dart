import '../api/challenge_game_api.dart';
import '../models/challenge_game_api_model.dart';
import '../../domain/entities/challenge_game/challenge_game_result.dart';
import '../../domain/entities/challenge_game/challenge_game_history_item.dart';
import '../../domain/entities/challenge_game/challenge_game_session_config.dart';

/// 挑战游戏仓库接口
abstract class ChallengeGameRepository {
  /// 获取挑战游戏数据和视频配置
  Future<Map<String, dynamic>> getChallengeGameDataAndVideoConfig(
    String challengeId, // 🎯 修改：使用challengeId
    {
    int? limit,
  });

  /// 提交挑战游戏结果
  Future<ChallengeGameSubmitResponseApiModel> submitChallengeGameResult(
    ChallengeGameResult result,
  );
}

/// 挑战游戏仓库实现
class ChallengeGameRepositoryImpl implements ChallengeGameRepository {
  final ChallengeGameApi _challengeGameApi;

  ChallengeGameRepositoryImpl(this._challengeGameApi);

  @override
  Future<Map<String, dynamic>> getChallengeGameDataAndVideoConfig(
    String challengeId, // 🎯 修改：使用challengeId
    {
    int? limit,
  }) async {
    try {
      final result = await _challengeGameApi.getChallengeGameDataAndVideoConfig(
        challengeId, // 🎯 修改：使用challengeId
        limit: limit,
      );

      // 转换历史数据为业务实体
      final historyItems = (result['history'] as List<ChallengeGameHistoryApiModel>)
          .map((apiModel) => _mapToChallengeGameHistoryItem(apiModel))
          .toList();

      return {
        'history': historyItems,
        'videoConfig': result['videoConfig'],
      };
    } catch (e) {
      throw Exception('Failed to get challenge game data and video config: $e');
    }
  }

  @override
  Future<ChallengeGameSubmitResponseApiModel> submitChallengeGameResult(
    ChallengeGameResult result,
  ) async {
    try {
      final apiModel = _mapToChallengeGameResultApiModel(result);
      return await _challengeGameApi.submitChallengeGameResult(apiModel);
    } catch (e) {
      throw Exception('Failed to submit challenge game result: $e');
    }
  }

  /// 映射API模型到业务实体
  ChallengeGameHistoryItem _mapToChallengeGameHistoryItem(
    ChallengeGameHistoryApiModel apiModel,
  ) {
    return ChallengeGameHistoryItem(
      id: apiModel.id,
      rank: apiModel.rank,
      counts: apiModel.counts,
      timestamp: apiModel.timestamp,
      note: apiModel.note,
      name: apiModel.name, // 🎯 新增：用户名
      userId: apiModel.userId, // 🎯 新增：用户ID
    );
  }

  /// 映射业务实体到API模型
  ChallengeGameResultApiModel _mapToChallengeGameResultApiModel(
    ChallengeGameResult result,
  ) {
    return ChallengeGameResultApiModel(
      challengeId: result.challengeId, // 🎯 修改：使用challengeId
      maxCounts: result.maxCounts,
    );
  }

  /// 映射API模型到业务实体
  ChallengeGameResult _mapToChallengeGameResult(
    ChallengeGameResultApiModel apiModel,
  ) {
    return ChallengeGameResult(
      id: '', // API模型中没有id字段，需要从响应中获取
      challengeId: apiModel.challengeId, // 🎯 修改：使用challengeId
      maxCounts: apiModel.maxCounts,
      // API结果模型没有时间戳，上层仅在需要时使用本地时间
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
} 