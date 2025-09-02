/// 训练结果API模型
class CheckinTrainingResultApiModel {
  final String trainingId;
  final String? productId;
  final double countsPerMin;
  final int totalSeconds;

  CheckinTrainingResultApiModel({
    required this.trainingId,
    this.productId,
    required this.countsPerMin,
    required this.totalSeconds,
  });

  factory CheckinTrainingResultApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingResultApiModel(
      trainingId: json['trainingId'] as String,
      productId: json['productId'] as String?,
      countsPerMin: (json['countsPerMin'] as num).toDouble(),
      totalSeconds: json['totalSeconds'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'trainingId': trainingId,
    if (productId != null) 'productId': productId,
    'countsPerMin': countsPerMin,
    'totalSeconds': totalSeconds,
  };
}

/// 训练提交响应API模型
class CheckinTrainingSubmitResponseApiModel {
  final String id;
  final int rank;

  CheckinTrainingSubmitResponseApiModel({
    required this.id,
    required this.rank,
  });

  factory CheckinTrainingSubmitResponseApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingSubmitResponseApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
  };
}

/// 训练历史数据API模型
class CheckinTrainingHistoryApiModel {
  final String id;
  final int rank;
  final int counts;
  final double countsPerMin;
  final int timestamp; // 毫秒时间戳

  CheckinTrainingHistoryApiModel({
    required this.id,
    required this.rank,
    required this.counts,
    required this.countsPerMin,
    required this.timestamp,
  });

  factory CheckinTrainingHistoryApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingHistoryApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      counts: json['counts'] as int,
      countsPerMin: (json['countsPerMin'] as num).toDouble(),
      timestamp: json['timestamp'] as int, // 毫秒时间戳
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'counts': counts,
    'countsPerMin': countsPerMin,
    'timestamp': timestamp,
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