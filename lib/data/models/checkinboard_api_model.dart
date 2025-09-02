class CheckinboardApiItemModel {
  final String activity;
  final int totalCheckins;
  final TopUserApiModel topUser;
  final List<CheckinRankingApiModel> rankings;

  CheckinboardApiItemModel({
    required this.activity,
    required this.totalCheckins,
    required this.topUser,
    required this.rankings,
  });

  factory CheckinboardApiItemModel.fromJson(Map<String, dynamic> json) {
    return CheckinboardApiItemModel(
      activity: json['activity'] as String,
      totalCheckins: json['totalCheckins'] as int,
      topUser: TopUserApiModel.fromJson(json['topUser'] as Map<String, dynamic>),
      rankings: (json['rankings'] as List<dynamic>)
          .map((e) => CheckinRankingApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'activity': activity,
        'totalCheckins': totalCheckins,
        'topUser': topUser.toJson(),
        'rankings': rankings.map((e) => e.toJson()).toList(),
      };
}

class TopUserApiModel {
  final String name;
  final String? country;
  final int streak;
  final int year;
  final int allTime;

  TopUserApiModel({
    required this.name,
    required this.country,
    required this.streak,
    required this.year,
    required this.allTime,
  });

  factory TopUserApiModel.fromJson(Map<String, dynamic> json) {
    return TopUserApiModel(
      name: json['name'] as String,
      country: json['country'] as String?,
      streak: json['streak'] as int,
      year: json['year'] as int,
      allTime: json['allTime'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'streak': streak,
        'year': year,
        'allTime': allTime,
      };
}

class CheckinRankingApiModel {
  final int rank;
  final String user;
  final int streak;
  final int year;
  final int allTime;

  CheckinRankingApiModel({
    required this.rank,
    required this.user,
    required this.streak,
    required this.year,
    required this.allTime,
  });

  factory CheckinRankingApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinRankingApiModel(
      rank: json['rank'] as int,
      user: json['user'] as String,
      streak: json['streak'] as int,
      year: json['year'] as int,
      allTime: json['allTime'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'user': user,
        'streak': streak,
        'year': year,
        'allTime': allTime,
      };
}

class CheckinboardPageApiModel {
  final List<CheckinboardApiItemModel> items;
  final int total;
  final int currentPage;
  final int pageSize;

  CheckinboardPageApiModel({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory CheckinboardPageApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinboardPageApiModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => CheckinboardApiItemModel.fromJson(e as Map<String, dynamic>))
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

class CheckinboardRankingsPageApiModel {
  final List<CheckinRankingApiModel> items;
  final int total;
  final int currentPage;
  final int pageSize;

  CheckinboardRankingsPageApiModel({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory CheckinboardRankingsPageApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinboardRankingsPageApiModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => CheckinRankingApiModel.fromJson(e as Map<String, dynamic>))
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
