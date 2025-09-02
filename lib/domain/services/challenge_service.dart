import '../entities/challenge.dart';

class ChallengeService {
  /// 获取推荐挑战列表
  List<Challenge> getRecommendedChallenges(List<Challenge> challenges) {
    // 推荐逻辑：优先显示进行中的挑战，然后是即将开始的
    final sortedChallenges = List<Challenge>.from(challenges);
    sortedChallenges.sort((a, b) => a.priority.compareTo(b.priority));
    return sortedChallenges;
  }

  /// 根据挑战名称搜索
  List<Challenge> searchChallenges(List<Challenge> challenges, String query) {
    if (query.isEmpty) return challenges;
    
    final lowercaseQuery = query.toLowerCase();
    return challenges.where((challenge) => 
      challenge.name.toLowerCase().contains(lowercaseQuery) ||
      (challenge.description != null && 
       challenge.description!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  /// 根据状态筛选挑战
  List<Challenge> filterChallengesByStatus(List<Challenge> challenges, String status) {
    return challenges.where((challenge) => 
      challenge.status.toLowerCase() == status.toLowerCase()
    ).toList();
  }

  /// 获取进行中的挑战
  List<Challenge> getOngoingChallenges(List<Challenge> challenges) {
    return challenges.where((challenge) => challenge.isOngoing).toList();
  }

  /// 获取已结束的挑战
  List<Challenge> getEndedChallenges(List<Challenge> challenges) {
    return challenges.where((challenge) => challenge.isEnded).toList();
  }

  /// 获取即将开始的挑战
  List<Challenge> getUpcomingChallenges(List<Challenge> challenges) {
    return challenges.where((challenge) => challenge.isUpcoming).toList();
  }

  /// 获取有视频资源的挑战
  List<Challenge> getChallengesWithVideos(List<Challenge> challenges) {
    return challenges.where((challenge) => challenge.hasVideo).toList();
  }

  /// 获取有描述信息的挑战
  List<Challenge> getChallengesWithDescriptions(List<Challenge> challenges) {
    return challenges.where((challenge) => challenge.hasDescription).toList();
  }

  /// 获取可参与的挑战
  List<Challenge> getParticipatableChallenges(List<Challenge> challenges) {
    return challenges.where((challenge) => challenge.canParticipate).toList();
  }

  /// 获取显示奖励的挑战
  List<Challenge> getChallengesWithRewards(List<Challenge> challenges) {
    return challenges.where((challenge) => challenge.shouldShowReward).toList();
  }

  /// 验证挑战数据完整性
  bool validateChallengeData(List<Challenge> challenges) {
    return challenges.every((challenge) => challenge.isValid);
  }

  /// 获取挑战统计信息
  Map<String, int> getChallengeStatistics(List<Challenge> challenges) {
    return {
      'total': challenges.length,
      'ongoing': getOngoingChallenges(challenges).length,
      'ended': getEndedChallenges(challenges).length,
      'upcoming': getUpcomingChallenges(challenges).length,
      'withVideos': getChallengesWithVideos(challenges).length,
      'withDescriptions': getChallengesWithDescriptions(challenges).length,
      'participatable': getParticipatableChallenges(challenges).length,
      'withRewards': getChallengesWithRewards(challenges).length,
    };
  }

  /// 获取挑战优先级排序
  List<Challenge> getChallengesByPriority(List<Challenge> challenges) {
    final sortedChallenges = List<Challenge>.from(challenges);
    sortedChallenges.sort((a, b) => a.priority.compareTo(b.priority));
    return sortedChallenges;
  }

  /// 获取即将到期的挑战（7天内结束）
  List<Challenge> getExpiringSoonChallenges(List<Challenge> challenges) {
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    
    return challenges.where((challenge) => 
      challenge.endDate.isAfter(now) && 
      challenge.endDate.isBefore(sevenDaysFromNow)
    ).toList();
  }

  /// 获取热门挑战（基于参与度，这里用状态作为示例）
  List<Challenge> getPopularChallenges(List<Challenge> challenges) {
    // 优先显示进行中的挑战，然后是即将开始的
    return getChallengesByPriority(challenges);
  }

  /// 检查挑战是否过期
  bool isChallengeExpired(Challenge challenge) {
    return DateTime.now().isAfter(challenge.endDate);
  }

  /// 获取挑战剩余天数
  int getDaysRemaining(Challenge challenge) {
    final now = DateTime.now();
    final difference = challenge.endDate.difference(now);
    return difference.inDays;
  }

  /// 格式化挑战状态显示
  String formatChallengeStatus(Challenge challenge) {
    if (challenge.isEnded) {
      return 'Ended';
    } else if (challenge.isUpcoming) {
      final days = getDaysRemaining(challenge);
      if (days > 0) {
        return 'Starts in $days days';
      } else {
        return 'Starting soon';
      }
    } else {
      return 'Ongoing';
    }
  }
} 