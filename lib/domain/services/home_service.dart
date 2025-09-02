import '../entities/home/home_entities.dart';

class HomeService {
  // 新增：检查公告栏数据是否有效
  bool isAnnouncementsValid(List<Announcement> announcements) {
    return announcements.isNotEmpty;
  }

  // 新增：检查冠军数据是否有效
  bool isChampionsValid(List<Champion> champions) {
    return champions.isNotEmpty;
  }

  // 新增：检查活跃用户数据是否有效
  bool isActiveUsersValid(List<ActiveUser> activeUsers) {
    return activeUsers.isNotEmpty;
  }

  // 获取高优先级公告
  List<Announcement> getHighPriorityAnnouncements(List<Announcement> announcements) {
    return announcements
        .where((announcement) => announcement.priority <= 2)
        .toList();
  }

  // 获取本周冠军
  List<Champion> getThisWeekChampions(List<Champion> champions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return champions
        .where((champion) => champion.completedAt.isAfter(weekStart))
        .toList();
  }

  // 获取连续打卡用户
  List<ActiveUser> getStreakUsers(List<ActiveUser> activeUsers) {
    return activeUsers
        .where((user) => user.streakDays >= 7)
        .toList();
  }

  // 计算用户活跃度分数
  double calculateUserActivityScore(ActiveUser user) {
    double score = 0;
    
    // 连续打卡天数权重
    score += user.streakDays * 2;
    
    // 年度打卡次数权重
    score += user.yearlyCheckins * 0.5;
    
    // 最近活动时间权重
    final daysSinceLastActivity = DateTime.now().difference(user.lastCheckinDate).inDays;
    if (daysSinceLastActivity == 0) {
      score += 10; // 今天打卡
    } else if (daysSinceLastActivity == 1) {
      score += 5;  // 昨天打卡
    } else if (daysSinceLastActivity < 7) {
      score += 2;  // 一周内打卡
    }
    
    return score;
  }

  // 获取用户排名
  List<ActiveUser> getRankedActiveUsers(List<ActiveUser> activeUsers) {
    final users = List<ActiveUser>.from(activeUsers);
    users.sort((a, b) => calculateUserActivityScore(b).compareTo(calculateUserActivityScore(a)));
    return users;
  }
}
