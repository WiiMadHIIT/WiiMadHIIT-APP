/// 倒计时训练结果实体
class TrainingCountdownResult {
  final String id;
  final String trainingId;
  final String? productId;
  final int? totalRounds; // 本地配置（可选，提交接口不需要）
  final int? roundDuration; // 本地配置（可选，提交接口不需要）
  final int seconds; // 总训练秒数
  final int timestamp; // 毫秒时间戳

  TrainingCountdownResult({
    required this.id,
    required this.trainingId,
    this.productId,
    this.totalRounds,
    this.roundDuration,
    required this.seconds,
    required this.timestamp,
  });

  /// 创建倒计时训练结果
  factory TrainingCountdownResult.create({
    required String trainingId,
    String? productId,
    required int totalRounds,
    required int roundDuration,
    required int seconds,
  }) {
    return TrainingCountdownResult(
      id: '', // 提交后从响应中获取
      trainingId: trainingId,
      productId: productId,
      totalRounds: totalRounds,
      roundDuration: roundDuration,
      seconds: seconds,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 从API响应创建倒计时训练结果
  factory TrainingCountdownResult.fromResponse({
    required String id,
    required String trainingId,
    String? productId,
    required int seconds,
    required int timestamp,
  }) {
    return TrainingCountdownResult(
      id: id,
      trainingId: trainingId,
      productId: productId,
      totalRounds: null,
      roundDuration: null,
      seconds: seconds,
      timestamp: timestamp,
    );
  }

  /// 复制并更新字段
  TrainingCountdownResult copyWith({
    String? id,
    String? trainingId,
    String? productId,
    int? totalRounds,
    int? roundDuration,
    int? seconds,
    int? timestamp,
  }) {
    return TrainingCountdownResult(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      productId: productId ?? this.productId,
      totalRounds: totalRounds ?? this.totalRounds,
      roundDuration: roundDuration ?? this.roundDuration,
      seconds: seconds ?? this.seconds,
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
      'seconds': seconds,
      'timestamp': timestamp,
    };
  }

  /// 从Map创建
  factory TrainingCountdownResult.fromMap(Map<String, dynamic> map) {
    return TrainingCountdownResult(
      id: map['id'] as String,
      trainingId: map['trainingId'] as String,
      productId: map['productId'] as String?,
      totalRounds: map['totalRounds'] as int?,
      roundDuration: map['roundDuration'] as int?,
      seconds: map['seconds'] as int,
      timestamp: map['timestamp'] as int,
    );
  }

  @override
  String toString() {
    return 'TrainingCountdownResult(id: $id, trainingId: $trainingId, productId: $productId, totalRounds: $totalRounds, roundDuration: $roundDuration, seconds: $seconds, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingCountdownResult &&
        other.id == id &&
        other.trainingId == trainingId &&
        other.productId == productId &&
        other.totalRounds == totalRounds &&
        other.roundDuration == roundDuration &&
        other.seconds == seconds &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        trainingId.hashCode ^
        productId.hashCode ^
        totalRounds.hashCode ^
        roundDuration.hashCode ^
        seconds.hashCode ^
        timestamp.hashCode;
  }
} 