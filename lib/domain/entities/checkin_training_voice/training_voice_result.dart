/// 语音训练结果实体
class TrainingVoiceResult {
  final String id;
  final String trainingId;
  final String? productId;
  final double countsPerMin; // 每分钟标准化计数
  final int totalSeconds; // 总训练时间（秒）
  final int counts; // 实际计数
  final int timestamp; // 毫秒时间戳

  TrainingVoiceResult({
    required this.id,
    required this.trainingId,
    this.productId,
    required this.countsPerMin,
    required this.totalSeconds,
    required this.counts,
    required this.timestamp,
  });

  /// 创建训练结果
  factory TrainingVoiceResult.create({
    required String trainingId,
    String? productId,
    required double countsPerMin,
    required int totalSeconds,
    required int counts,
  }) {
    return TrainingVoiceResult(
      id: '', // 提交后从响应中获取
      trainingId: trainingId,
      productId: productId,
      countsPerMin: countsPerMin,
      totalSeconds: totalSeconds,
      counts: counts,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 从API响应创建训练结果
  factory TrainingVoiceResult.fromResponse({
    required String id,
    required String trainingId,
    String? productId,
    required double countsPerMin,
    required int totalSeconds,
    required int counts,
    required int timestamp,
  }) {
    return TrainingVoiceResult(
      id: id,
      trainingId: trainingId,
      productId: productId,
      countsPerMin: countsPerMin,
      totalSeconds: totalSeconds,
      counts: counts,
      timestamp: timestamp,
    );
  }

  /// 复制并更新字段
  TrainingVoiceResult copyWith({
    String? id,
    String? trainingId,
    String? productId,
    double? countsPerMin,
    int? totalSeconds,
    int? counts,
    int? timestamp,
  }) {
    return TrainingVoiceResult(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      productId: productId ?? this.productId,
      countsPerMin: countsPerMin ?? this.countsPerMin,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      counts: counts ?? this.counts,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainingId': trainingId,
      'productId': productId,
      'countsPerMin': countsPerMin,
      'totalSeconds': totalSeconds,
      'counts': counts,
      'timestamp': timestamp,
    };
  }

  /// 从Map创建
  factory TrainingVoiceResult.fromMap(Map<String, dynamic> map) {
    return TrainingVoiceResult(
      id: map['id'] as String,
      trainingId: map['trainingId'] as String,
      productId: map['productId'] as String?,
      countsPerMin: (map['countsPerMin'] as num).toDouble(),
      totalSeconds: map['totalSeconds'] as int,
      counts: map['counts'] as int,
      timestamp: map['timestamp'] as int,
    );
  }

  @override
  String toString() {
    return 'TrainingVoiceResult(id: $id, trainingId: $trainingId, productId: $productId, countsPerMin: $countsPerMin, totalSeconds: $totalSeconds, counts: $counts, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingVoiceResult &&
        other.id == id &&
        other.trainingId == trainingId &&
        other.productId == productId &&
        other.countsPerMin == countsPerMin &&
        other.totalSeconds == totalSeconds &&
        other.counts == counts &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        trainingId.hashCode ^
        productId.hashCode ^
        countsPerMin.hashCode ^
        totalSeconds.hashCode ^
        counts.hashCode ^
        timestamp.hashCode;
  }
} 