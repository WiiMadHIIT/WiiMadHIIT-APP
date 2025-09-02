// API模型不应该导入领域实体，这里定义自己的API模型类

// 挑战基础信息API模型
class ChallengeBasicApiModel {
  final String challengeId;
  final String challengeName;
  final String backgroundImage;
  final String videoUrl;
  final String preseasonNotice;  // 新增：季前赛公告
  final ChallengeRulesApiModel rules;
  final GameTrackerDataApiModel gameTracker;

  ChallengeBasicApiModel({
    required this.challengeId,
    required this.challengeName,
    required this.backgroundImage,
    required this.videoUrl,
    required this.preseasonNotice,  // 新增
    required this.rules,
    required this.gameTracker,
  });

  factory ChallengeBasicApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeBasicApiModel(
      challengeId: json['challengeId'] as String,
      challengeName: json['challengeName'] as String,
      backgroundImage: json['backgroundImage'] as String,
      videoUrl: json['videoUrl'] as String,
      preseasonNotice: json['preseasonNotice'] as String? ?? '',  // 新增
      rules: ChallengeRulesApiModel.fromJson(json['rules']),
      gameTracker: GameTrackerDataApiModel.fromJson(json['gameTracker']),
    );
  }
}

// 季后赛数据API模型
class ChallengePlayoffsApiModel {
  final String challengeId;
  final Map<String, String> stages;
  final Map<String, List<PlayoffMatchApiModel>> matches;

  ChallengePlayoffsApiModel({
    required this.challengeId,
    required this.stages,
    required this.matches,
  });

  factory ChallengePlayoffsApiModel.fromJson(Map<String, dynamic> json) {
    final stagesMap = Map<String, String>.from(json['stages']);
    final matchesMap = <String, List<PlayoffMatchApiModel>>{};
    
    (json['matches'] as Map<String, dynamic>).forEach((key, value) {
      matchesMap[key] = (value as List)
          .map((item) => PlayoffMatchApiModel.fromJson(item))
          .toList();
    });

    return ChallengePlayoffsApiModel(
      challengeId: json['challengeId'] as String,
      stages: stagesMap,
      matches: matchesMap,
    );
  }
}

// 季前赛数据API模型
class ChallengePreseasonApiModel {
  final String challengeId;
  final List<PreseasonRecordApiModel> records;
  final PaginationInfoApiModel pagination;  // 新增：分页信息

  ChallengePreseasonApiModel({
    required this.challengeId,
    required this.records,
    required this.pagination,  // 新增
  });

  factory ChallengePreseasonApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengePreseasonApiModel(
      challengeId: json['challengeId'] as String,
      records: (json['records'] as List)
          .map((item) => PreseasonRecordApiModel.fromJson(item))
          .toList(),
      pagination: PaginationInfoApiModel.fromJson(json['pagination']),  // 新增
    );
  }
}

// 分页信息API模型
class PaginationInfoApiModel {
  final int total;
  final int currentPage;
  final int pageSize;
  final int totalPages;

  PaginationInfoApiModel({
    required this.total,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginationInfoApiModel.fromJson(Map<String, dynamic> json) {
    return PaginationInfoApiModel(
      total: json['total'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class ChallengeRulesApiModel {
  final String title;
  final List<String> items;
  final String details;

  ChallengeRulesApiModel({
    required this.title,
    required this.items,
    required this.details,
  });

  factory ChallengeRulesApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeRulesApiModel(
      title: json['title'] as String,
      items: List<String>.from(json['items']),
      details: json['details'] as String,
    );
  }
}

class PlayoffMatchApiModel {
  final String? userId1;
  final String? avatar1;
  final String? name1;
  final String? userId2;
  final String? avatar2;
  final String? name2;
  final int? score1;
  final int? score2;
  final bool finished;

  PlayoffMatchApiModel({
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

  factory PlayoffMatchApiModel.fromJson(Map<String, dynamic> json) {
    return PlayoffMatchApiModel(
      userId1: json['userId1'] as String?,
      avatar1: json['avatar1'] as String?,
      name1: json['name1'] as String?,
      userId2: json['userId2'] as String?,
      name2: json['name2'] as String?,
      score1: json['score1'] as int?,
      score2: json['score2'] as int?,
      finished: json['finished'] as bool? ?? false,
    );
  }
}

class PreseasonDataApiModel {
  final String notice;
  final List<PreseasonRecordApiModel> records;

  PreseasonDataApiModel({
    required this.notice,
    required this.records,
  });

  factory PreseasonDataApiModel.fromJson(Map<String, dynamic> json) {
    return PreseasonDataApiModel(
      notice: json['notice'] as String,
      records: (json['records'] as List)
          .map((item) => PreseasonRecordApiModel.fromJson(item))
          .toList(),
    );
  }
}

class PreseasonRecordApiModel {
  final String id;
  final int index;
  final String name;
  final String rank;
  final int counts;

  PreseasonRecordApiModel({
    required this.id,
    required this.index,
    required this.name,
    required this.rank,
    required this.counts,
  });

  factory PreseasonRecordApiModel.fromJson(Map<String, dynamic> json) {
    return PreseasonRecordApiModel(
      id: json['id'] as String,
      index: json['index'] as int,
      name: json['name'] as String,
      rank: json['rank'] as String,
      counts: json['counts'] as int? ?? 0,
    );
  }
}

class GameTrackerDataApiModel {
  final List<GameTrackerPostApiModel> posts;

  GameTrackerDataApiModel({
    required this.posts,
  });

  factory GameTrackerDataApiModel.fromJson(Map<String, dynamic> json) {
    return GameTrackerDataApiModel(
      posts: (json['posts'] as List)
          .map((item) => GameTrackerPostApiModel.fromJson(item))
          .toList(),
    );
  }
}

class GameTrackerPostApiModel {
  final String id;
  final String? announcement;
  final String? image;
  final String? desc;
  final int timestep;

  GameTrackerPostApiModel({
    required this.id,
    this.announcement,
    this.image,
    this.desc,
    required this.timestep,
  });

  factory GameTrackerPostApiModel.fromJson(Map<String, dynamic> json) {
    return GameTrackerPostApiModel(
      id: json['id'] as String,
      announcement: json['announcement'] as String?,
      image: json['image'] as String?,
      desc: json['desc'] as String?,
      timestep: json['timestep'] as int,
    );
  }
} 