// 公告栏API模型
class HomeAnnouncementsApiModel {
  final List<AnnouncementApiModel> announcements;

  HomeAnnouncementsApiModel({
    required this.announcements,
  });

  factory HomeAnnouncementsApiModel.fromJson(Map<String, dynamic> json) {
    return HomeAnnouncementsApiModel(
      announcements: (json['announcements'] as List<dynamic>)
          .map((e) => AnnouncementApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'announcements': announcements.map((e) => e.toJson()).toList(),
  };
}

// 最近冠军API模型
class HomeChampionsApiModel {
  final List<ChampionApiModel> recentChampions;

  HomeChampionsApiModel({
    required this.recentChampions,
  });

  factory HomeChampionsApiModel.fromJson(Map<String, dynamic> json) {
    return HomeChampionsApiModel(
      recentChampions: (json['recentChampions'] as List<dynamic>)
          .map((e) => ChampionApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'recentChampions': recentChampions.map((e) => e.toJson()).toList(),
  };
}

// 活跃用户API模型
class HomeActiveUsersApiModel {
  final List<ActiveUserApiModel> activeUsers;

  HomeActiveUsersApiModel({
    required this.activeUsers,
  });

  factory HomeActiveUsersApiModel.fromJson(Map<String, dynamic> json) {
    return HomeActiveUsersApiModel(
      activeUsers: (json['activeUsers'] as List<dynamic>)
          .map((e) => ActiveUserApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'activeUsers': activeUsers.map((e) => e.toJson()).toList(),
  };
}

class AnnouncementApiModel {
  final String id;
  final String title;
  final String subtitle;
  final int priority;

  AnnouncementApiModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
  });

  factory AnnouncementApiModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementApiModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      priority: json['priority'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'priority': priority,
  };
}

class ChampionApiModel {
  final String userId;
  final String username;
  final String challengeName;
  final String challengeId;
  final int rank;
  final int counts;
  final int completedAt;
  final String avatar;

  ChampionApiModel({
    required this.userId,
    required this.username,
    required this.challengeName,
    required this.challengeId,
    required this.rank,
    required this.counts,
    required this.completedAt,
    required this.avatar,
  });

  factory ChampionApiModel.fromJson(Map<String, dynamic> json) {
    return ChampionApiModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      challengeName: json['challengeName'] as String,
      challengeId: json['challengeId'] as String,
      rank: json['rank'] as int,
      counts: json['counts'] as int,
      completedAt: json['completedAt'] as int,
      avatar: json['avatar'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'challengeName': challengeName,
    'challengeId': challengeId,
    'rank': rank,
    'counts': counts,
    'completedAt': completedAt,
    'avatar': avatar,
  };
}

class ActiveUserApiModel {
  final String userId;
  final String username;
  final int streakDays;
  final String lastCheckinDate;
  final int yearlyCheckins;
  final String latestActivityName;
  final String avatar;

  ActiveUserApiModel({
    required this.userId,
    required this.username,
    required this.streakDays,
    required this.lastCheckinDate,
    required this.yearlyCheckins,
    required this.latestActivityName,
    required this.avatar,
  });

  factory ActiveUserApiModel.fromJson(Map<String, dynamic> json) {
    return ActiveUserApiModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      streakDays: json['streakDays'] as int,
      lastCheckinDate: json['lastCheckinDate'] as String,
      yearlyCheckins: json['yearlyCheckins'] as int,
      latestActivityName: json['latestActivityName'] as String,
      avatar: json['avatar'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'streakDays': streakDays,
    'lastCheckinDate': lastCheckinDate,
    'yearlyCheckins': yearlyCheckins,
    'latestActivityName': latestActivityName,
    'avatar': avatar,
  };
}
