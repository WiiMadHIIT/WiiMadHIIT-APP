class LeaderboardApiModel {
  final String challengeId;
  final String activity;
  final int participants;
  final TopUserApiModel topUser;
  final List<RankingItemApiModel> rankings;

  LeaderboardApiModel({
    required this.challengeId,
    required this.activity,
    required this.participants,
    required this.topUser,
    required this.rankings,
  });

  factory LeaderboardApiModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardApiModel(
      challengeId: json['challengeId'] as String,
      activity: json['activity'] as String,
      participants: json['participants'] as int,
      topUser: TopUserApiModel.fromJson(json['topUser'] as Map<String, dynamic>),
      rankings: (json['rankings'] as List<dynamic>)
          .map((e) => RankingItemApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'challengeId': challengeId,
        'activity': activity,
        'participants': participants,
        'topUser': topUser.toJson(),
        'rankings': rankings.map((e) => e.toJson()).toList(),
      };
}

class TopUserApiModel {
  final String name;
  final int counts;

  TopUserApiModel({
    required this.name,
    required this.counts,
  });

  factory TopUserApiModel.fromJson(Map<String, dynamic> json) {
    return TopUserApiModel(
      name: json['name'] as String,
      counts: json['counts'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'counts': counts,
      };
}

class RankingItemApiModel {
  final int rank;
  final String userId;
  final String user;
  final int counts;

  RankingItemApiModel({
    required this.rank,
    required this.userId,
    required this.user,
    required this.counts,
  });

  factory RankingItemApiModel.fromJson(Map<String, dynamic> json) {
    return RankingItemApiModel(
      rank: json['rank'] as int,
      userId: json['userId'] as String,
      user: json['user'] as String,
      counts: json['counts'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'userId': userId,
        'user': user,
        'counts': counts,
      };
}

class LeaderboardRankingsPageApiModel {
  final List<RankingItemApiModel> items;
  final int total;
  final int currentPage;
  final int pageSize;

  LeaderboardRankingsPageApiModel({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory LeaderboardRankingsPageApiModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardRankingsPageApiModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => RankingItemApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'currentPage': currentPage,
        'pageSize': pageSize,
      };
}

// 新增：排行榜列表分页模型
class LeaderboardListPageApiModel {
  final List<LeaderboardApiModel> items;
  final int total;
  final int currentPage;
  final int pageSize;

  LeaderboardListPageApiModel({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory LeaderboardListPageApiModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardListPageApiModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => LeaderboardApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'currentPage': currentPage,
        'pageSize': pageSize,
      };
}


