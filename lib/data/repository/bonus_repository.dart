import '../api/bonus_api.dart';
import '../models/bonus_api_model.dart';
import '../../domain/entities/bonus_activity.dart';

class BonusRepository {
  final BonusApi _bonusApi;

  BonusRepository(this._bonusApi);

  /// 获取奖励活动列表（支持分页）
  Future<BonusActivityPage> getBonusActivities({
    int page = 1,
    int size = 10,
  }) async {
    final BonusListApiModel apiModel = await _bonusApi.fetchBonusActivities(
      page: page,
      size: size,
    );
    
    // 转换为业务实体
    final activities = apiModel.activities.map((activity) => BonusActivity(
      id: activity.id,
      name: activity.name,
      description: activity.description,
      reward: activity.reward,
      regionLimit: activity.regionLimit,
      videoUrl: activity.videoUrl,
      activityName: activity.activityName,
      activityDescription: activity.activityDescription,
      activityCode: activity.activityCode,
      activityUrl: activity.activityUrl,
      startTimeStep: activity.startTimeStep,
      endTimeStep: activity.endTimeStep,
    )).toList();

    return BonusActivityPage(
      activities: activities,
      total: apiModel.total,
      currentPage: apiModel.currentPage,
      pageSize: apiModel.pageSize,
    );
  }

  /// 获取所有奖励活动（向后兼容）
  Future<List<BonusActivity>> getAllBonusActivities() async {
    final page = await getBonusActivities(page: 1, size: 1000); // 获取大量数据
    return page.activities;
  }
}

/// 分页数据包装类
class BonusActivityPage {
  final List<BonusActivity> activities;
  final int total;
  final int currentPage;
  final int pageSize;

  BonusActivityPage({
    required this.activities,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  // 分页信息计算
  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;
} 