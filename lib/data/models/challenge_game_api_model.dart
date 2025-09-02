/// 挑战游戏结果API模型
class ChallengeGameResultApiModel {
  final String challengeId; // 🎯 修改：使用challengeId
  final int maxCounts;

  ChallengeGameResultApiModel({
    required this.challengeId, // 🎯 修改：使用challengeId
    required this.maxCounts,
  });

  factory ChallengeGameResultApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeGameResultApiModel(
      challengeId: json['challengeId'] as String, // 🎯 修改：使用challengeId
      maxCounts: json['maxCounts'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'challengeId': challengeId, // 🎯 修改：使用challengeId
    'maxCounts': maxCounts,
  };
}

/// 挑战游戏提交响应API模型
class ChallengeGameSubmitResponseApiModel {
  final String id;
  final int rank;
  final int allowedTimes;

  ChallengeGameSubmitResponseApiModel({
    required this.id,
    required this.rank,
    required this.allowedTimes,
  });

  factory ChallengeGameSubmitResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeGameSubmitResponseApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      allowedTimes: json['allowedTimes'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'allowedTimes': allowedTimes,
  };
}

/// 挑战游戏历史数据API模型
class ChallengeGameHistoryApiModel {
  final String id;
  final int rank;
  final int counts;
  final int timestamp; // 毫秒时间戳
  final String? note;
  final String name; // 🎯 新增：用户名
  final String userId; // 🎯 新增：用户ID

  ChallengeGameHistoryApiModel({
    required this.id,
    required this.rank,
    required this.counts,
    required this.timestamp,
    this.note,
    required this.name, // 🎯 新增：用户名
    required this.userId, // 🎯 新增：用户ID
  });

  factory ChallengeGameHistoryApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeGameHistoryApiModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      counts: json['counts'] as int,
      timestamp: json['timestamp'] as int, // 毫秒时间戳
      note: json['note'] as String?,
      name: json['name'] as String, // 🎯 新增：用户名
      userId: json['userId'] as String, // 🎯 新增：用户ID
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rank': rank,
    'counts': counts,
    'timestamp': timestamp,
    'note': note,
    'name': name, // 🎯 新增：用户名
    'userId': userId, // 🎯 新增：用户ID
  };
}

/// 视频配置API模型
class ChallengeGameVideoConfigApiModel {
  final String? portraitUrl;
  final String? landscapeUrl;

  ChallengeGameVideoConfigApiModel({
    this.portraitUrl,
    this.landscapeUrl,
  });

  factory ChallengeGameVideoConfigApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeGameVideoConfigApiModel(
      portraitUrl: json['portraitUrl'] as String?,
      landscapeUrl: json['landscapeUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'portraitUrl': portraitUrl,
    'landscapeUrl': landscapeUrl,
  };
}

/// 挑战游戏数据和视频配置响应API模型
class ChallengeGameDataAndVideoConfigApiModel {
  final List<ChallengeGameHistoryApiModel> history;
  final ChallengeGameVideoConfigApiModel videoConfig;

  ChallengeGameDataAndVideoConfigApiModel({
    required this.history,
    required this.videoConfig,
  });

  factory ChallengeGameDataAndVideoConfigApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeGameDataAndVideoConfigApiModel(
      history: (json['history'] as List)
          .map((item) => ChallengeGameHistoryApiModel.fromJson(item))
          .toList(),
      videoConfig: ChallengeGameVideoConfigApiModel.fromJson(json['videoConfig'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'history': history.map((item) => item.toJson()).toList(),
    'videoConfig': videoConfig.toJson(),
  };
} 