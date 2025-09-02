/// 倒计时训练结果API模型
class TrainingCountdownResultApiModel {
  final String trainingId;
  final String? productId;
  final int seconds; // 总训练秒数

  TrainingCountdownResultApiModel({
    required this.trainingId,
    this.productId,
    required this.seconds,
  });

  factory TrainingCountdownResultApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingCountdownResultApiModel(
      trainingId: json['trainingId'] as String,
      productId: json['productId'] as String?,
      seconds: json['seconds'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'trainingId': trainingId,
    if (productId != null) 'productId': productId,
    'seconds': seconds,
  };
}

/// 倒计时训练提交响应API模型
class TrainingCountdownSubmitResponseApiModel {
  final String id;
  final int rank;
  final int daySeconds; // 新增：每日总秒数

  TrainingCountdownSubmitResponseApiModel({
    required this.id,
    required this.rank,
    required this.daySeconds, // 新增：每日总秒数
  });

  factory TrainingCountdownSubmitResponseApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingCountdownSubmitResponseApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      daySeconds: json['daySeconds'] as int, // 新增：每日总秒数
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'daySeconds': daySeconds, // 新增：每日总秒数
  };
}

/// 倒计时训练历史数据API模型
class TrainingCountdownHistoryApiModel {
  final String id;
  final int rank;
  final int daySeconds; // 每日总秒数
  final int seconds; // 训练秒数
  final String? note;

  TrainingCountdownHistoryApiModel({
    required this.id,
    required this.rank,
    required this.daySeconds,
    required this.seconds,
    this.note,
  });

  factory TrainingCountdownHistoryApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingCountdownHistoryApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      daySeconds: json['daySeconds'] as int,
      seconds: json['seconds'] as int,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'daySeconds': daySeconds,
    'seconds': seconds,
    'note': note,
  };
}

/// 倒计时训练视频配置API模型
class TrainingCountdownVideoConfigApiModel {
  final String? portraitUrl;
  final String? landscapeUrl;

  TrainingCountdownVideoConfigApiModel({
    this.portraitUrl,
    this.landscapeUrl,
  });

  factory TrainingCountdownVideoConfigApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingCountdownVideoConfigApiModel(
      portraitUrl: json['portraitUrl'] as String?,
      landscapeUrl: json['landscapeUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'portraitUrl': portraitUrl,
    'landscapeUrl': landscapeUrl,
  };
}

/// 倒计时训练数据和视频配置响应API模型
class TrainingCountdownDataAndVideoConfigApiModel {
  final List<TrainingCountdownHistoryApiModel> history;
  final TrainingCountdownVideoConfigApiModel videoConfig;

  TrainingCountdownDataAndVideoConfigApiModel({
    required this.history,
    required this.videoConfig,
  });

  factory TrainingCountdownDataAndVideoConfigApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingCountdownDataAndVideoConfigApiModel(
      history: (json['history'] as List)
          .map((item) => TrainingCountdownHistoryApiModel.fromJson(item))
          .toList(),
      videoConfig: TrainingCountdownVideoConfigApiModel.fromJson(json['videoConfig'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'history': history.map((item) => item.toJson()).toList(),
    'videoConfig': videoConfig.toJson(),
  };
} 