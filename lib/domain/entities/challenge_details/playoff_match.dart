import 'package:flutter/foundation.dart';

class PlayoffMatch {
  final String? userId1;
  final String? avatar1;
  final String? name1;
  final String? userId2;
  final String? avatar2;
  final String? name2;
  final int? score1;
  final int? score2;
  final bool finished;

  PlayoffMatch({
    this.userId1,
    this.avatar1,
    this.name1,
    this.userId2,
    this.avatar2,
    this.name2,
    this.score1,
    this.score2,
    this.finished = false,
  });

  /// 检查比赛是否已结束
  bool get isCompleted => finished;

  /// 获取获胜者ID
  String? get winnerId {
    if (!finished || score1 == null || score2 == null) return null;
    return score1! > score2! ? userId1 : userId2;
  }

  /// 获取失败者ID
  String? get loserId {
    if (!finished || score1 == null || score2 == null) return null;
    return score1! > score2! ? userId2 : userId1;
  }

  /// 获取获胜者分数
  int? get winnerScore {
    if (!finished || score1 == null || score2 == null) return null;
    return score1! > score2! ? score1 : score2;
  }

  /// 获取失败者分数
  int? get loserScore {
    if (!finished || score1 == null || score2 == null) return null;
    return score1! > score2! ? score2 : score1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayoffMatch &&
          runtimeType == other.runtimeType &&
          userId1 == other.userId1 &&
          avatar1 == other.avatar1 &&
          name1 == other.name1 &&
          userId2 == other.userId2 &&
          avatar2 == other.avatar2 &&
          name2 == other.name2 &&
          score1 == other.score1 &&
          score2 == other.score2 &&
          finished == other.finished;

  @override
  int get hashCode =>
      userId1.hashCode ^
      avatar1.hashCode ^
      name1.hashCode ^
      userId2.hashCode ^
      avatar2.hashCode ^
      name2.hashCode ^
      score1.hashCode ^
      score2.hashCode ^
      finished.hashCode;

  @override
  String toString() {
    return 'PlayoffMatch{userId1: $userId1, avatar1: $avatar1, name1: $name1, userId2: $userId2, avatar2: $avatar2, name2: $name2, score1: $score1, score2: $score2, finished: $finished}';
  }
} 