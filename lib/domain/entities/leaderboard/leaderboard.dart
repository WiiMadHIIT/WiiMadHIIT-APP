class LeaderboardBoard {
  final String challengeId;
  final String activity;
  final int participants;
  final TopUser topUser;
  final List<RankingItem> rankings;

  LeaderboardBoard({
    required this.challengeId,
    required this.activity,
    required this.participants,
    required this.topUser,
    required this.rankings,
  });
}

class TopUser {
  final String name;
  final int counts;

  TopUser({
    required this.name,
    required this.counts,
  });
}

class RankingItem {
  final int rank;
  final String userId;
  final String user;
  final int counts;

  RankingItem({
    required this.rank,
    required this.userId,
    required this.user,
    required this.counts,
  });
}

class LeaderboardRankingsPage {
  final List<RankingItem> items;
  final int total;
  final int currentPage;
  final int pageSize;

  LeaderboardRankingsPage({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });
}

// 新增：排行榜列表分页实体
class LeaderboardListPage {
  final List<LeaderboardBoard> items;
  final int total;
  final int currentPage;
  final int pageSize;

  LeaderboardListPage({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });
}


