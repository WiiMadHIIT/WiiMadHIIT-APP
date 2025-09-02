import '../entities/challenge_details/challenge_details.dart';
import '../entities/challenge_details/playoff_match.dart';

class ChallengeDetailsService {
  /// 检查挑战是否已完成（使用独立实体）
  bool isChallengeCompletedWithPlayoffs(PlayoffData playoffs) {
    // 检查所有季后赛阶段是否都已完成
    final matches = playoffs.matches;
    for (final stageMatches in matches.values) {
      for (final match in stageMatches) {
        if (!match.finished) {
          return false;
        }
      }
    }
    return true;
  }

  /// 获取当前活跃的季后赛阶段（使用独立实体）
  String? getCurrentPlayoffStageWithPlayoffs(PlayoffData playoffs) {
    final matches = playoffs.matches;
    
    // 按优先级检查各阶段
    if (matches['finalMatch']?.isNotEmpty == true) {
      return 'finalMatch';
    } else if (matches['semi']?.isNotEmpty == true) {
      return 'semi';
    } else if (matches['round4']?.isNotEmpty == true) {
      return 'round4';
    } else if (matches['round8']?.isNotEmpty == true) {
      return 'round8';
    } else if (matches['round16']?.isNotEmpty == true) {
      return 'round16';
    } else if (matches['round32']?.isNotEmpty == true) {
      return 'round32';
    }
    
    return null;
  }

  /// 检查用户是否参与挑战（使用独立实体）
  bool isUserParticipatingWithPlayoffs(PlayoffData playoffs, String userId) {
    final matches = playoffs.matches;
    
    // 检查所有阶段的对阵中是否包含该用户
    for (final stageMatches in matches.values) {
      for (final match in stageMatches) {
        if (match.userId1 == userId || match.userId2 == userId) {
          return true;
        }
      }
    }
    
    return false;
  }

  /// 获取用户的挑战统计信息（使用独立实体）
  Map<String, dynamic> getUserChallengeStatsWithPlayoffs(PlayoffData playoffs, String userId) {
    int totalMatches = 0;
    int wins = 0;
    int losses = 0;
    
    final matches = playoffs.matches;
    
    for (final stageMatches in matches.values) {
      for (final match in stageMatches) {
        if (match.userId1 == userId || match.userId2 == userId) {
          if (match.finished) {
            totalMatches++;
            if (match.userId1 == userId) {
              if ((match.score1 ?? 0) > (match.score2 ?? 0)) {
                wins++;
              } else {
                losses++;
              }
            } else {
              if ((match.score2 ?? 0) > (match.score1 ?? 0)) {
                wins++;
              } else {
                losses++;
              }
            }
          }
        }
      }
    }
    
    return {
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'winRate': totalMatches > 0 ? (wins / totalMatches * 100).roundToDouble() : 0.0,
    };
  }
} 