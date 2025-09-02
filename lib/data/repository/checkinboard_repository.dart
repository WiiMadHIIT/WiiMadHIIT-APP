import '../api/checkinboard_api.dart';
import '../models/checkinboard_api_model.dart';
import '../../domain/entities/checkinboard/checkinboard.dart';

class CheckinboardRepository {
  final CheckinboardApi _api;

  CheckinboardRepository(this._api);

  Future<CheckinboardPage> getCheckinboards({int page = 1, int pageSize = 10}) async {
    final CheckinboardPageApiModel apiPage = await _api.fetchCheckinboards(page: page, pageSize: pageSize);
    return _mapPage(apiPage);
  }

  Future<CheckinboardPage> getRankings({String? activity, String? activityId, int page = 1, int pageSize = 16}) async {
    final CheckinboardRankingsPageApiModel apiPage = await _api.fetchRankings(activity: activity, activityId: activityId, page: page, pageSize: pageSize);
    return CheckinboardPage(
      items: [
        CheckinboardItem(
          activity: activity ?? (activityId ?? ''),
          totalCheckins: 0,
          topUser: TopCheckinUser(name: '', country: null, streak: 0, year: 0, allTime: 0),
          rankings: apiPage.items
              .map((r) => CheckinRanking(rank: r.rank, user: r.user, streak: r.streak, year: r.year, allTime: r.allTime))
              .toList(),
        )
      ],
      total: apiPage.total,
      currentPage: apiPage.currentPage,
      pageSize: apiPage.pageSize,
    );
  }

  Future<CheckinboardRankingsPage> getRankingsPage({String? activity, String? activityId, int page = 1, int pageSize = 16}) async {
    final CheckinboardRankingsPageApiModel apiPage = await _api.fetchRankings(
      activity: activity,
      activityId: activityId,
      page: page,
      pageSize: pageSize,
    );
    return mapRankingsPage(apiPage);
  }

  CheckinboardPage _mapPage(CheckinboardPageApiModel apiPage) {
    return CheckinboardPage(
      items: apiPage.items.map(_mapItem).toList(),
      total: apiPage.total,
      currentPage: apiPage.currentPage,
      pageSize: apiPage.pageSize,
    );
  }

  CheckinboardItem _mapItem(CheckinboardApiItemModel m) {
    return CheckinboardItem(
      activity: m.activity,
      totalCheckins: m.totalCheckins,
      topUser: TopCheckinUser(
        name: m.topUser.name,
        country: m.topUser.country,
        streak: m.topUser.streak,
        year: m.topUser.year,
        allTime: m.topUser.allTime,
      ),
      rankings: m.rankings
          .map((r) => CheckinRanking(
                rank: r.rank,
                user: r.user,
                streak: r.streak,
                year: r.year,
                allTime: r.allTime,
              ))
          .toList(),
    );
  }

  CheckinboardRankingsPage mapRankingsPage(CheckinboardRankingsPageApiModel apiPage) {
    return CheckinboardRankingsPage(
      items: apiPage.items
          .map((r) => CheckinRanking(rank: r.rank, user: r.user, streak: r.streak, year: r.year, allTime: r.allTime))
          .toList(),
      total: apiPage.total,
      currentPage: apiPage.currentPage,
      pageSize: apiPage.pageSize,
    );
  }
}
