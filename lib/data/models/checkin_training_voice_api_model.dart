/// 语音训练结果API模型
class CheckinTrainingVoiceResultApiModel {
  final String trainingId;
  final String? productId;
  final double countsPerMin; // 每分钟标准化计数
  final int totalSeconds; // 总训练时间（秒）

  CheckinTrainingVoiceResultApiModel({
    required this.trainingId,
    this.productId,
    required this.countsPerMin,
    required this.totalSeconds,
  });

  factory CheckinTrainingVoiceResultApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingVoiceResultApiModel(
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

/// 语音训练提交响应API模型
class CheckinTrainingVoiceSubmitResponseApiModel {
  final String id;
  final int rank;

  CheckinTrainingVoiceSubmitResponseApiModel({
    required this.id,
    required this.rank,
  });

  factory CheckinTrainingVoiceSubmitResponseApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingVoiceSubmitResponseApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
  };
}

/// 语音训练历史数据API模型
class CheckinTrainingVoiceHistoryApiModel {
  final String id;
  final int rank;
  final int counts;
  final double countsPerMin; // 每分钟标准化计数
  final int timestamp; // 毫秒时间戳

  CheckinTrainingVoiceHistoryApiModel({
    required this.id,
    required this.rank,
    required this.counts,
    required this.countsPerMin,
    required this.timestamp,
  });

  factory CheckinTrainingVoiceHistoryApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingVoiceHistoryApiModel(
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

/// 语音训练视频配置API模型
class CheckinTrainingVoiceVideoConfigApiModel {
  final String? portraitUrl;
  final String? landscapeUrl;

  CheckinTrainingVoiceVideoConfigApiModel({
    this.portraitUrl,
    this.landscapeUrl,
  });

  factory CheckinTrainingVoiceVideoConfigApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingVoiceVideoConfigApiModel(
      portraitUrl: json['portraitUrl'] as String?,
      landscapeUrl: json['landscapeUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'portraitUrl': portraitUrl,
    'landscapeUrl': landscapeUrl,
  };
}

/// 语音训练数据和视频配置响应API模型
class CheckinTrainingVoiceDataAndVideoConfigApiModel {
  final List<CheckinTrainingVoiceHistoryApiModel> history;
  final CheckinTrainingVoiceVideoConfigApiModel videoConfig;

  CheckinTrainingVoiceDataAndVideoConfigApiModel({
    required this.history,
    required this.videoConfig,
  });

  factory CheckinTrainingVoiceDataAndVideoConfigApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinTrainingVoiceDataAndVideoConfigApiModel(
      history: (json['history'] as List)
          .map((item) => CheckinTrainingVoiceHistoryApiModel.fromJson(item))
          .toList(),
      videoConfig: CheckinTrainingVoiceVideoConfigApiModel.fromJson(json['videoConfig'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'history': history.map((item) => item.toJson()).toList(),
    'videoConfig': videoConfig.toJson(),
  };
} 