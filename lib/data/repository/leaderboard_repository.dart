import '../api/leaderboard_api.dart';
import '../models/leaderboard_api_model.dart';
import '../../domain/entities/leaderboard/leaderboard.dart';

abstract class LeaderboardRepository {
  Future<LeaderboardListPage> getLeaderboards({int page, int size});
  Future<LeaderboardRankingsPage> getRankings({required String challengeId, int page, int pageSize});
}

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardApi _api;

  LeaderboardRepositoryImpl(this._api);

  @override
  Future<LeaderboardListPage> getLeaderboards({int page = 1, int size = 10}) async {
    final apiPage = await _api.fetchLeaderboards(page: page, size: size);
    return LeaderboardListPage(
      items: apiPage.items
          .map(
            (e) => LeaderboardBoard(
              challengeId: e.challengeId,
              activity: e.activity,
              participants: e.participants,
              topUser: TopUser(name: e.topUser.name, counts: e.topUser.counts),
              rankings: e.rankings
                  .map((r) => RankingItem(rank: r.rank, userId: r.userId, user: r.user, counts: r.counts))
                  .toList(),
            ),
          )
          .toList(),
      total: apiPage.total,
      currentPage: apiPage.currentPage,
      pageSize: apiPage.pageSize,
    );
  }

  @override
  Future<LeaderboardRankingsPage> getRankings({
    required String challengeId,
    int page = 1,
    int pageSize = 16,
  }) async {
    final apiPage = await _api.fetchRankings(challengeId: challengeId, page: page, pageSize: pageSize);
    return LeaderboardRankingsPage(
      items: apiPage.items
          .map((r) => RankingItem(rank: r.rank, userId: r.userId, user: r.user, counts: r.counts))
          .toList(),
      total: apiPage.total,
      currentPage: apiPage.currentPage,
      pageSize: apiPage.pageSize,
    );
  }
}


