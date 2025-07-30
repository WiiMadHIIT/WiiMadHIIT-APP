import '../api/bonus_api.dart';
import '../models/bonus_api_model.dart';
import '../../domain/entities/bonus_activity.dart';

class BonusRepository {
  final BonusApi _bonusApi;

  BonusRepository(this._bonusApi);

  /// 获取奖励活动列表
  Future<List<BonusActivity>> getBonusActivities() async {
    final BonusListApiModel apiModel = await _bonusApi.fetchBonusActivities();
    
    // 转换为业务实体
    return apiModel.activities.map((activity) => BonusActivity(
      id: activity.id,
      name: activity.name,
      description: activity.description,
      reward: activity.reward,
      regionLimit: activity.regionLimit,
      videoUrl: activity.videoUrl,
      thumbnailUrl: activity.thumbnailUrl,
      status: activity.status,
      startDate: activity.startDate,
      endDate: activity.endDate,
      isClaimed: activity.isClaimed,
      isEligible: activity.isEligible,
      claimCount: activity.claimCount,
      maxClaimCount: activity.maxClaimCount,
      category: activity.category,
      difficulty: activity.difficulty,
    )).toList();
  }

  /// 获取单个奖励活动
  Future<BonusActivity> getBonusActivity(String activityId) async {
    final BonusApiModel apiModel = await _bonusApi.fetchBonusActivity(activityId);
    
    // 转换为业务实体
    return BonusActivity(
      id: apiModel.id,
      name: apiModel.name,
      description: apiModel.description,
      reward: apiModel.reward,
      regionLimit: apiModel.regionLimit,
      videoUrl: apiModel.videoUrl,
      thumbnailUrl: apiModel.thumbnailUrl,
      status: apiModel.status,
      startDate: apiModel.startDate,
      endDate: apiModel.endDate,
      isClaimed: apiModel.isClaimed,
      isEligible: apiModel.isEligible,
      claimCount: apiModel.claimCount,
      maxClaimCount: apiModel.maxClaimCount,
      category: apiModel.category,
      difficulty: apiModel.difficulty,
    );
  }

  /// 领取奖励
  Future<Map<String, dynamic>> claimBonus(String activityId) async {
    return await _bonusApi.claimBonus(activityId);
  }
} 