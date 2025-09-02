/// 挑战游戏结果实体
class ChallengeGameResult {
  final String id;
  final String challengeId; // 🎯 修改：使用challengeId而不是trainingId
  final int maxCounts;
  final int timestamp; // 毫秒时间戳（不再上送，保留用于本地）

  ChallengeGameResult({
    required this.id,
    required this.challengeId, // 🎯 修改：使用challengeId
    required this.maxCounts,
    required this.timestamp,
  });

  /// 创建挑战游戏结果
  factory ChallengeGameResult.create({
    required String challengeId, // 🎯 修改：使用challengeId
    required int maxCounts,
  }) {
    return ChallengeGameResult(
      id: '', // 提交后从响应中获取
      challengeId: challengeId, // 🎯 修改：使用challengeId
      maxCounts: maxCounts,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 从API响应创建挑战游戏结果
  factory ChallengeGameResult.fromResponse({
    required String id,
    required String challengeId, // 🎯 修改：使用challengeId
    required int maxCounts,
    required int timestamp,
  }) {
    return ChallengeGameResult(
      id: id,
      challengeId: challengeId, // 🎯 修改：使用challengeId
      maxCounts: maxCounts,
      timestamp: timestamp,
    );
  }

  /// 复制并更新字段
  ChallengeGameResult copyWith({
    String? id,
    String? challengeId, // 🎯 修改：使用challengeId
    int? maxCounts,
    int? timestamp,
  }) {
    return ChallengeGameResult(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId, // 🎯 修改：使用challengeId
      maxCounts: maxCounts ?? this.maxCounts,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'challengeId': challengeId, // 🎯 修改：使用challengeId
      'maxCounts': maxCounts,
      'timestamp': timestamp,
    };
  }

  /// 从Map创建
  factory ChallengeGameResult.fromMap(Map<String, dynamic> map) {
    return ChallengeGameResult(
      id: map['id'] as String,
      challengeId: map['challengeId'] as String, // 🎯 修改：使用challengeId
      maxCounts: map['maxCounts'] as int,
      timestamp: map['timestamp'] as int,
    );
  }

  @override
  String toString() {
    return 'ChallengeGameResult(id: $id, challengeId: $challengeId, maxCounts: $maxCounts, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeGameResult &&
        other.id == id &&
        other.challengeId == challengeId && // 🎯 修改：使用challengeId
        other.maxCounts == maxCounts &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        challengeId.hashCode ^ // 🎯 修改：使用challengeId
        maxCounts.hashCode ^
        timestamp.hashCode;
  }
} 