/// 训练结果API模型
class CheckinTrainingResultApiModel {
  final String trainingId;
  final String? productId;
  final int totalRounds;
  final int roundDuration;
  final int maxCounts;
  final int timestamp; // 毫秒时间戳

  CheckinTrainingResultApiModel({
    required this.trainingId,
    this.productId,
    required this.totalRounds,
    required this.roundDuration,
    required this.maxCounts,
    required this.timestamp,
  });

  factory CheckinTrainingResultApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingResultApiModel(
      trainingId: json['trainingId'] as String,
      productId: json['productId'] as String?,
      totalRounds: json['totalRounds'] as int,
      roundDuration: json['roundDuration'] as int,
      maxCounts: json['maxCounts'] as int,
      timestamp: json['timestamp'] as int, // 毫秒时间戳
    );
  }

  Map<String, dynamic> toJson() => {
    'trainingId': trainingId,
    if (productId != null) 'productId': productId,
    'totalRounds': totalRounds,
    'roundDuration': roundDuration,
    'maxCounts': maxCounts,
    'timestamp': timestamp,
  };
}

/// 训练提交响应API模型
class CheckinTrainingSubmitResponseApiModel {
  final String id;
  final int rank;
  final int totalRounds;
  final int roundDuration;

  CheckinTrainingSubmitResponseApiModel({
    required this.id,
    required this.rank,
    required this.totalRounds,
    required this.roundDuration,
  });

  factory CheckinTrainingSubmitResponseApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingSubmitResponseApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      totalRounds: json['totalRounds'] as int,
      roundDuration: json['roundDuration'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'totalRounds': totalRounds,
    'roundDuration': roundDuration,
  };
}

/// 训练历史数据API模型
class CheckinTrainingHistoryApiModel {
  final String id;
  final int rank;
  final int counts;
  final int timestamp; // 毫秒时间戳
  final String? note;

  CheckinTrainingHistoryApiModel({
    required this.id,
    required this.rank,
    required this.counts,
    required this.timestamp,
    this.note,
  });

  factory CheckinTrainingHistoryApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingHistoryApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      counts: json['counts'] as int,
      timestamp: json['timestamp'] as int, // 毫秒时间戳
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'counts': counts,
    'timestamp': timestamp,
    'note': note,
  };
}

/// 视频配置API模型
class CheckinTrainingVideoConfigApiModel {
  final String? portraitUrl;
  final String? landscapeUrl;

  CheckinTrainingVideoConfigApiModel({
    this.portraitUrl,
    this.landscapeUrl,
  });

  factory CheckinTrainingVideoConfigApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingVideoConfigApiModel(
      portraitUrl: json['portraitUrl'] as String?,
      landscapeUrl: json['landscapeUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'portraitUrl': portraitUrl,
    'landscapeUrl': landscapeUrl,
  };
}

/// 训练数据和视频配置响应API模型
class CheckinTrainingDataAndVideoConfigApiModel {
  final List<CheckinTrainingHistoryApiModel> history;
  final CheckinTrainingVideoConfigApiModel videoConfig;

  CheckinTrainingDataAndVideoConfigApiModel({
    required this.history,
    required this.videoConfig,
  });

  factory CheckinTrainingDataAndVideoConfigApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingDataAndVideoConfigApiModel(
      history: (json['history'] as List)
          .map((item) => CheckinTrainingHistoryApiModel.fromJson(item))
          .toList(),
      videoConfig: CheckinTrainingVideoConfigApiModel.fromJson(json['videoConfig'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'history': history.map((item) => item.toJson()).toList(),
    'videoConfig': videoConfig.toJson(),
  };
} 