import '../api/home_api.dart';
import '../models/home_api_model.dart';
import '../../domain/entities/home/home_entities.dart';

class HomeRepository {
  final HomeApi _homeApi;

  HomeRepository(this._homeApi);

  // 新增：获取公告栏数据
  Future<List<Announcement>> getHomeAnnouncements() async {
    final HomeAnnouncementsApiModel apiModel = await _homeApi.fetchHomeAnnouncements_MOCK();

    return apiModel.announcements
        .map((e) => Announcement(
              id: e.id,
              title: e.title,
              subtitle: e.subtitle,
              priority: e.priority,
            ))
        .toList();
  }

  // 新增：获取最近冠军数据
  Future<List<Champion>> getHomeChampions() async {
    final HomeChampionsApiModel apiModel = await _homeApi.fetchHomeChampions_MOCK();

    return apiModel.recentChampions
        .map((e) => Champion(
              userId: e.userId,
              username: e.username,
              challengeName: e.challengeName,
              challengeId: e.challengeId,
              rank: e.rank,
              counts: e.counts,
              completedAt: DateTime.fromMillisecondsSinceEpoch(e.completedAt),
              avatar: e.avatar,
            ))
        .toList();
  }

  // 新增：获取活跃用户数据
  Future<List<ActiveUser>> getHomeActiveUsers() async {
    final HomeActiveUsersApiModel apiModel = await _homeApi.fetchHomeActiveUsers_MOCK();

    return apiModel.activeUsers
        .map((e) => ActiveUser(
              userId: e.userId,
              username: e.username,
              streakDays: e.streakDays,
              lastCheckinDate: DateTime.parse(e.lastCheckinDate),
              yearlyCheckins: e.yearlyCheckins,
              latestActivityName: e.latestActivityName,
              avatar: e.avatar,
            ))
        .toList();
  }


}
