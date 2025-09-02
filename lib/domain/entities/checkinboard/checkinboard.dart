class CheckinboardPage {
  final List<CheckinboardItem> items;
  final int total;
  final int currentPage;
  final int pageSize;

  CheckinboardPage({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });
}

class CheckinboardItem {
  final String activity;
  final int totalCheckins;
  final TopCheckinUser topUser;
  final List<CheckinRanking> rankings;

  CheckinboardItem({
    required this.activity,
    required this.totalCheckins,
    required this.topUser,
    required this.rankings,
  });
}

class TopCheckinUser {
  final String name;
  final String? country;
  final int streak;
  final int year;
  final int allTime;

  TopCheckinUser({
    required this.name,
    required this.country,
    required this.streak,
    required this.year,
    required this.allTime,
  });
}

class CheckinRanking {
  final int rank;
  final String user;
  final int streak;
  final int year;
  final int allTime;

  CheckinRanking({
    required this.rank,
    required this.user,
    required this.streak,
    required this.year,
    required this.allTime,
  });
}

class CheckinboardRankingsPage {
  final List<CheckinRanking> items;
  final int total;
  final int currentPage;
  final int pageSize;

  CheckinboardRankingsPage({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });
}


