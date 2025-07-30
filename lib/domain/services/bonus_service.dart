import '../entities/bonus_activity.dart';

class BonusService {
  /// 检查用户是否符合地区限制
  bool isEligibleForRegion(String userRegion, String activityRegion) {
    if (activityRegion == "Global") return true;
    return activityRegion.contains(userRegion);
  }

  /// 检查用户是否符合活动资格
  bool isUserEligible(BonusActivity activity, String userRegion) {
    // 检查地区限制
    if (!isEligibleForRegion(userRegion, activity.regionLimit)) {
      return false;
    }
    
    // 检查活动状态
    if (!activity.isActive) {
      return false;
    }
    
    // 检查是否已领取
    if (activity.isClaimed) {
      return false;
    }
    
    // 检查活动是否在有效期内
    if (!activity.isInValidPeriod) {
      return false;
    }
    
    return true;
  }

  /// 过滤可用的活动
  List<BonusActivity> filterAvailableActivities(
    List<BonusActivity> activities,
    String userRegion,
  ) {
    return activities.where((activity) => 
      isUserEligible(activity, userRegion)
    ).toList();
  }

  /// 按分类过滤活动
  List<BonusActivity> filterByCategory(
    List<BonusActivity> activities,
    String category,
  ) {
    return activities.where((activity) => 
      activity.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  /// 按难度过滤活动
  List<BonusActivity> filterByDifficulty(
    List<BonusActivity> activities,
    String difficulty,
  ) {
    return activities.where((activity) => 
      activity.difficulty.toLowerCase() == difficulty.toLowerCase()
    ).toList();
  }

  /// 获取活动统计信息
  Map<String, dynamic> getActivityStats(List<BonusActivity> activities) {
    final totalActivities = activities.length;
    final activeActivities = activities.where((a) => a.isActive).length;
    final claimedActivities = activities.where((a) => a.isClaimed).length;
    final availableActivities = activities.where((a) => a.canClaim).length;

    return {
      'total': totalActivities,
      'active': activeActivities,
      'claimed': claimedActivities,
      'available': availableActivities,
    };
  }
} 