import '../entities/challenge_game/challenge_game_history_item.dart';
import '../entities/challenge_game/challenge_game_result.dart';

/// 挑战游戏领域服务
class ChallengeGameService {
  /// 判断挑战游戏历史是否完整
  bool isChallengeGameHistoryComplete(List<ChallengeGameHistoryItem> history) {
    return history.isNotEmpty && history.every((item) => item.rank != null);
  }

  /// 获取当前挑战游戏排名
  int? getCurrentChallengeGameRank(List<ChallengeGameHistoryItem> history) {
    final currentItem = history.firstWhere(
      (item) => item.isCurrent,
      orElse: () => ChallengeGameHistoryItem(
        id: '',
        rank: null,
        counts: 0,
        timestamp: 0,
        name: '',
        userId: '',
      ),
    );
    return currentItem.rank;
  }

  /// 计算挑战游戏历史统计信息
  Map<String, dynamic> calculateChallengeGameStats(List<ChallengeGameHistoryItem> history) {
    if (history.isEmpty) {
      return {
        'totalSessions': 0,
        'averageCounts': 0,
        'bestCounts': 0,
        'totalCounts': 0,
      };
    }

    final totalSessions = history.length;
    final totalCounts = history.fold(0, (sum, item) => sum + item.counts);
    final averageCounts = totalCounts / totalSessions;
    final bestCounts = history.fold(0, (max, item) => item.counts > max ? item.counts : max);

    return {
      'totalSessions': totalSessions,
      'averageCounts': averageCounts.round(),
      'bestCounts': bestCounts,
      'totalCounts': totalCounts,
    };
  }

  /// 验证挑战游戏结果数据
  bool isValidChallengeGameResult(ChallengeGameResult result) {
    return result.challengeId.isNotEmpty &&
           result.maxCounts >= 0 &&
           result.timestamp > 0;
  }

  /// 生成挑战游戏历史项
  ChallengeGameHistoryItem createChallengeGameHistoryItem({
    required String id,
    required int counts,
    required int timestamp,
    int? rank,
    String? note,
    required String name,
    required String userId,
  }) {
    return ChallengeGameHistoryItem(
      id: id,
      rank: rank,
      counts: counts,
      timestamp: timestamp,
      note: note,
      name: name,
      userId: userId,
    );
  }

  /// 格式化挑战游戏时间
  String formatChallengeGameTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// 判断是否为今天的挑战游戏
  bool isTodayChallengeGame(int timestamp) {
    final challengeDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final today = DateTime.now();
    return challengeDate.year == today.year &&
           challengeDate.month == today.month &&
           challengeDate.day == today.day;
  }

  /// 获取挑战游戏难度等级
  String getChallengeGameDifficulty(int counts) {
    if (counts >= 25) return 'Expert';
    if (counts >= 20) return 'Advanced';
    if (counts >= 15) return 'Intermediate';
    if (counts >= 10) return 'Beginner';
    return 'Novice';
  }

  /// 检查是否可以开始挑战游戏
  bool canStartChallengeGame(int allowedTimes) {
    return allowedTimes > 0;
  }

  /// 获取挑战游戏状态描述
  String getChallengeGameStatusDescription(int allowedTimes) {
    if (allowedTimes <= 0) {
      return 'Challenge completed! Check results in Profile > Challenges.';
    }
    return 'Ready to start challenge game! ($allowedTimes attempts left)';
  }
}