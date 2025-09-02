import '../entities/bonus_activity.dart';
import '../../data/repository/bonus_repository.dart';

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

  /// 按活动代码过滤活动
  List<BonusActivity> filterByActivityCode(
    List<BonusActivity> activities,
    String activityCode,
  ) {
    return activities.where((activity) => 
      activity.activityCode.toLowerCase() == activityCode.toLowerCase()
    ).toList();
  }

  /// 按活动名称过滤活动
  List<BonusActivity> filterByActivityName(
    List<BonusActivity> activities,
    String activityName,
  ) {
    return activities.where((activity) => 
      activity.activityName.toLowerCase().contains(activityName.toLowerCase())
    ).toList();
  }

  /// 获取活动统计信息
  Map<String, dynamic> getActivityStats(List<BonusActivity> activities) {
    final totalActivities = activities.length;
    final activeActivities = activities.where((a) => a.isActive).length;
    final expiredActivities = activities.where((a) => a.isExpired).length;
    final notStartedActivities = activities.where((a) => a.isNotStarted).length;

    return {
      'total': totalActivities,
      'active': activeActivities,
      'expired': expiredActivities,
      'notStarted': notStartedActivities,
    };
  }

  /// 获取即将开始的活动（7天内）
  List<BonusActivity> getUpcomingActivities(List<BonusActivity> activities) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final sevenDaysInMs = 7 * 24 * 60 * 60 * 1000;
    
    return activities.where((activity) {
      final timeUntilStart = activity.startTimeStep - now;
      return timeUntilStart > 0 && timeUntilStart <= sevenDaysInMs;
    }).toList();
  }

  /// 获取即将结束的活动（3天内）
  List<BonusActivity> getEndingSoonActivities(List<BonusActivity> activities) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final threeDaysInMs = 3 * 24 * 60 * 60 * 1000;
    
    return activities.where((activity) {
      final timeUntilEnd = activity.endTimeStep - now;
      return timeUntilEnd > 0 && timeUntilEnd <= threeDaysInMs;
    }).toList();
  }

  /// 按时间排序活动（即将开始 -> 进行中 -> 已结束）
  List<BonusActivity> sortByTime(List<BonusActivity> activities) {
    final sorted = List<BonusActivity>.from(activities);
    sorted.sort((a, b) {
      // 首先按状态排序：即将开始 > 进行中 > 已结束
      if (a.isNotStarted && !b.isNotStarted) return -1;
      if (!a.isNotStarted && b.isNotStarted) return 1;
      if (a.isActive && b.isExpired) return -1;
      if (a.isExpired && b.isActive) return 1;
      
      // 然后按开始时间排序
      return a.startTimeStep.compareTo(b.startTimeStep);
    });
    return sorted;
  }


} 