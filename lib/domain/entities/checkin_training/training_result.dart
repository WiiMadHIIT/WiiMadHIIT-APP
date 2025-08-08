/// 训练结果实体
class TrainingResult {
  final String id;
  final String trainingId;
  final String? productId;
  final int totalRounds;
  final int roundDuration;
  final int maxCounts;
  final int timestamp; // 毫秒时间戳

  TrainingResult({
    required this.id,
    required this.trainingId,
    this.productId,
    required this.totalRounds,
    required this.roundDuration,
    required this.maxCounts,
    required this.timestamp,
  });

  /// 创建训练结果
  factory TrainingResult.create({
    required String trainingId,
    String? productId,
    required int totalRounds,
    required int roundDuration,
    required int maxCounts,
  }) {
    return TrainingResult(
      id: '', // 提交后从响应中获取
      trainingId: trainingId,
      productId: productId,
      totalRounds: totalRounds,
      roundDuration: roundDuration,
      maxCounts: maxCounts,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 从API响应创建训练结果
  factory TrainingResult.fromResponse({
    required String id,
    required String trainingId,
    String? productId,
    required int totalRounds,
    required int roundDuration,
    required int maxCounts,
    required int timestamp,
  }) {
    return TrainingResult(
      id: id,
      trainingId: trainingId,
      productId: productId,
      totalRounds: totalRounds,
      roundDuration: roundDuration,
      maxCounts: maxCounts,
      timestamp: timestamp,
    );
  }

  /// 复制并更新字段
  TrainingResult copyWith({
    String? id,
    String? trainingId,
    String? productId,
    int? totalRounds,
    int? roundDuration,
    int? maxCounts,
    int? timestamp,
  }) {
    return TrainingResult(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      productId: productId ?? this.productId,
      totalRounds: totalRounds ?? this.totalRounds,
      roundDuration: roundDuration ?? this.roundDuration,
      maxCounts: maxCounts ?? this.maxCounts,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainingId': trainingId,
      'productId': productId,
      'totalRounds': totalRounds,
      'roundDuration': roundDuration,
      'maxCounts': maxCounts,
      'timestamp': timestamp,
    };
  }

  /// 从Map创建
  factory TrainingResult.fromMap(Map<String, dynamic> map) {
    return TrainingResult(
      id: map['id'] as String,
      trainingId: map['trainingId'] as String,
      productId: map['productId'] as String?,
      totalRounds: map['totalRounds'] as int,
      roundDuration: map['roundDuration'] as int,
      maxCounts: map['maxCounts'] as int,
      timestamp: map['timestamp'] as int,
    );
  }

  @override
  String toString() {
    return 'TrainingResult(id: $id, trainingId: $trainingId, productId: $productId, totalRounds: $totalRounds, roundDuration: $roundDuration, maxCounts: $maxCounts, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingResult &&
        other.id == id &&
        other.trainingId == trainingId &&
        other.productId == productId &&
        other.totalRounds == totalRounds &&
        other.roundDuration == roundDuration &&
        other.maxCounts == maxCounts &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        trainingId.hashCode ^
        productId.hashCode ^
        totalRounds.hashCode ^
        roundDuration.hashCode ^
        maxCounts.hashCode ^
        timestamp.hashCode;
  }
} 