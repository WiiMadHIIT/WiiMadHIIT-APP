import '../entities/profile.dart';
import '../entities/activation_request.dart';

class ProfileService {
  // 检查用户资料是否完整
  bool isProfileComplete(Profile profile) {
    return profile.user.userId.isNotEmpty &&
           profile.user.username.isNotEmpty &&
           profile.user.email.isNotEmpty &&
           profile.stats.currentStreak >= 0 &&
           profile.stats.daysThisYear >= 0 &&
           profile.stats.daysAllTime >= 0;
  }

  // 获取高优先级荣誉
  List<Honor> getHighPriorityHonors(Profile profile) {
    return profile.honors
        .where((honor) => 
          honor.label.contains('Champion') || 
          honor.label.contains('Winner') ||
          honor.label.contains('Best'))
        .toList();
  }

  // 获取本周获得的荣誉
  List<Honor> getThisWeekHonors(Profile profile) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return profile.honors
        .where((honor) => honor.earnedAt.isAfter(weekStart))
        .toList();
  }

  // 获取本月获得的荣誉
  List<Honor> getThisMonthHonors(Profile profile) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    return profile.honors
        .where((honor) => honor.earnedAt.isAfter(monthStart))
        .toList();
  }

  // 获取最近完成的挑战
  List<ChallengeRecord> getRecentCompletedChallenges(Profile profile, {int limit = 5}) {
    final completed = profile.completedChallenges;
    completed.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return completed.take(limit).toList();
  }

  // 获取即将开始的挑战
  List<ChallengeRecord> getUpcomingChallenges(Profile profile, {int limit = 3}) {
    final ready = profile.readyChallenges;
    ready.sort((a, b) => a.timestep.compareTo(b.timestep));
    return ready.take(limit).toList();
  }

  // 获取最近完成的打卡记录
  List<CheckinRecord> getRecentCompletedCheckins(Profile profile, {int limit = 5}) {
    final completed = profile.completedCheckins;
    completed.sort((a, b) => b.checkinAt.compareTo(a.checkinAt));
    return completed.take(limit).toList();
  }

  // 获取即将开始的打卡记录
  List<CheckinRecord> getUpcomingCheckins(Profile profile, {int limit = 3}) {
    final ready = profile.readyCheckins;
    ready.sort((a, b) => a.timestep.compareTo(b.timestep));
    return ready.take(limit).toList();
  }

  // 计算用户成就分数
  double calculateAchievementScore(Profile profile) {
    double score = 0;
    
    // 荣誉权重
    score += profile.honors.length * 100;
    
    // 挑战完成权重
    score += profile.completedChallenges.length * 50;
    
    // 打卡完成权重
    score += profile.completedCheckins.length * 30;
    
    // 连续打卡权重
    score += profile.stats.currentStreak * 10;
    
    // 年度打卡权重
    score += profile.stats.daysThisYear * 5;
    
    return score;
  }

  // 检查是否解锁新成就
  List<String> checkNewAchievements(Profile profile) {
    final List<String> newAchievements = [];
    
    // 检查连续打卡成就
    if (profile.stats.currentStreak >= 7 && profile.stats.currentStreak < 14) {
      newAchievements.add('7-Day Streak Master');
    } else if (profile.stats.currentStreak >= 14 && profile.stats.currentStreak < 30) {
      newAchievements.add('14-Day Streak Expert');
    } else if (profile.stats.currentStreak >= 30) {
      newAchievements.add('30-Day Streak Legend');
    }
    
    // 检查年度打卡成就
    if (profile.stats.daysThisYear >= 100 && profile.stats.daysThisYear < 200) {
      newAchievements.add('100-Day Warrior');
    } else if (profile.stats.daysThisYear >= 200 && profile.stats.daysThisYear < 365) {
      newAchievements.add('200-Day Champion');
    } else if (profile.stats.daysThisYear >= 365) {
      newAchievements.add('365-Day Master');
    }
    
    // 检查挑战成就
    if (profile.completedChallenges.length >= 5) {
      newAchievements.add('Challenge Conqueror');
    }
    
    // 检查荣誉成就
    if (profile.honors.length >= 3) {
      newAchievements.add('Honor Collector');
    }
    
    // 检查激活关联成就
    if (profile.activate.length >= 3) {
      newAchievements.add('Product Activator');
    }
    
    // 检查挑战与产品关联成就
    final associatedChallenges = profile.challengeRecords
        .where((record) => profile.activate.any((activate) => activate.challengeId == record.challengeId))
        .length;
    if (associatedChallenges >= 2) {
      newAchievements.add('Challenge-Product Linker');
    }
    
    return newAchievements;
  }

  // 获取用户统计摘要
  Map<String, dynamic> getProfileSummary(Profile profile) {
    return {
      'totalHonors': profile.honors.length,
      'totalChallenges': profile.challengeRecords.length,
      'completedChallenges': profile.completedChallenges.length,
      'ongoingChallenges': profile.ongoingChallenges.length,
      'readyChallenges': profile.readyChallenges.length,
      'totalCheckins': profile.checkinRecords.length,
      'completedCheckins': profile.completedCheckins.length,
      'ongoingCheckins': profile.ongoingCheckins.length,
      'readyCheckins': profile.readyCheckins.length,
      'totalActivations': profile.activate.length,
      'associatedChallenges': profile.challengeRecords
          .where((record) => profile.activate.any((activate) => activate.challengeId == record.challengeId))
          .length,
      'associatedCheckins': profile.checkinRecords
          .where((record) => profile.activate.any((activate) => activate.productId == record.productId))
          .length,
      'achievementScore': calculateAchievementScore(profile),
      'level': profile.stats.level,
      'levelName': profile.stats.levelName,
      'nextLevelProgress': profile.stats.nextLevelProgress,
    };
  }

  // 验证挑战记录数据
  bool validateChallengeRecords(List<ChallengeRecord> records) {
    for (final record in records) {
      if (record.id.isEmpty || record.challengeId.isEmpty || record.name.isEmpty || record.status.isEmpty) {
        return false;
      }
      
      if (!['ended', 'ongoing', 'ready'].contains(record.status)) {
        return false;
      }
    }
    return true;
  }

  // 验证打卡记录数据
  bool validateCheckinRecords(List<CheckinRecord> records) {
    for (final record in records) {
      if (record.id.isEmpty || record.productId.isEmpty || record.name.isEmpty || record.status.isEmpty) {
        return false;
      }
      
      if (!['ended', 'ongoing', 'ready'].contains(record.status)) {
        return false;
      }
    }
    return true;
  }

  // 验证荣誉数据
  bool validateHonors(List<Honor> honors) {
    for (final honor in honors) {
      if (honor.id.isEmpty || honor.label.isEmpty || honor.description.isEmpty) {
        return false;
      }
    }
    return true;
  }

  // 新增：激活码相关业务逻辑

  // 验证激活码格式
  bool validateActivationCode(String activationCode) {
    if (activationCode.length < 6) return false;
    
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(activationCode);
    final hasDigit = RegExp(r'[0-9]').hasMatch(activationCode);
    
    return hasLetter && hasDigit;
  }

  // 检查产品是否可以激活
  bool canActivateProduct(Profile profile, String productId) {
    return profile.activate.any((activate) => activate.productId == productId);
  }

  // 获取可激活的产品信息
  List<Activate> getAvailableProducts(Profile profile) {
    return profile.activate.where((activate) => activate.isValid).toList();
  }

  // 处理激活成功后的业务逻辑
  void handleActivationSuccess(Profile profile, String productId) {
    // 这里可以添加激活成功后的业务逻辑
    // 比如更新本地状态、发送通知等
    print('Product $productId activated successfully');
  }

  // 处理激活失败后的业务逻辑
  void handleActivationFailure(String productId, String error) {
    // 这里可以添加激活失败后的业务逻辑
    // 比如记录错误日志、显示错误提示等
    print('Failed to activate product $productId: $error');
  }

  // 获取激活状态描述
  String getActivationStatusMessage(bool isSuccess) {
    if (isSuccess) {
      return 'Your activation request has been successfully submitted. Please wait 1-5 days for review. After approval, the corresponding challenge/check-in records will appear in the list with "Ready" status.';
    } else {
      return 'Activation code submission failed. Please check if the activation code is correct and resubmit.';
    }
  }

  // 检查用户是否有资格激活特定挑战
  bool canActivateChallenge(Profile profile, String challengeId) {
    // 检查挑战是否在可激活列表中
    final activateItem = profile.activate.firstWhere(
      (item) => item.challengeId == challengeId,
      orElse: () => Activate(
        challengeId: '',
        challengeName: '',
        productId: '',
        productName: '',
      ),
    );
    
    return activateItem.isValid;
  }

  // 获取激活关联信息
  Map<String, dynamic> getActivationInfo(Profile profile, String productId) {
    final activateItem = profile.activate.firstWhere(
      (item) => item.productId == productId,
      orElse: () => Activate(
        challengeId: '',
        challengeName: '',
        productId: '',
        productName: '',
      ),
    );
    
    return {
      'challengeId': activateItem.challengeId,
      'challengeName': activateItem.challengeName,
      'productName': activateItem.productName,
      'canActivate': activateItem.isValid,
    };
  }

  // 根据挑战ID获取挑战记录
  ChallengeRecord? getChallengeRecordById(Profile profile, String challengeId) {
    try {
      return profile.challengeRecords.firstWhere(
        (record) => record.challengeId == challengeId,
      );
    } catch (e) {
      return null;
    }
  }

  // 根据产品ID获取打卡记录
  CheckinRecord? getCheckinRecordByProductId(Profile profile, String productId) {
    try {
      return profile.checkinRecords.firstWhere(
        (record) => record.productId == productId,
      );
    } catch (e) {
      return null;
    }
  }

  // 获取挑战与产品的关联状态
  Map<String, dynamic> getChallengeProductAssociation(Profile profile, String challengeId) {
    final activateItem = profile.activate.firstWhere(
      (item) => item.challengeId == challengeId,
      orElse: () => Activate(
        challengeId: '',
        challengeName: '',
        productId: '',
        productName: '',
      ),
    );
    
    return {
      'challengeId': activateItem.challengeId,
      'challengeName': activateItem.challengeName,
      'productId': activateItem.productId,
      'productName': activateItem.productName,
      'isAssociated': activateItem.isValid,
    };
  }

  // 新增：用户信息更新相关业务逻辑

  // 验证用户信息更新
  bool validateProfileUpdate({
    String? username,
    String? email,
  }) {
    // 验证用户名
    if (username != null) {
      if (username.trim().isEmpty || username.length < 2) {
        return false;
      }
    }
    
    // 验证邮箱
    if (email != null) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email.trim())) {
        return false;
      }
    }
    
    return true;
  }

  // 处理用户信息更新成功
  void handleProfileUpdateSuccess(Profile profile, {
    String? username,
    String? email,
  }) {
    // 这里可以添加更新成功后的业务逻辑
    // 比如记录更新日志、发送通知等
    print('Profile updated successfully');
    if (username != null) print('Username updated to: $username');
    if (email != null) print('Email updated to: $email');
  }

  // 处理用户信息更新失败
  void handleProfileUpdateFailure({
    String? username,
    String? email,
    required Map<String, String> errors,
  }) {
    // 这里可以添加更新失败后的业务逻辑
    // 比如记录错误日志、显示错误提示等
    print('Profile update failed');
    print('Errors: $errors');
  }

  // 获取用户信息更新状态消息
  String getProfileUpdateStatusMessage(bool isSuccess) {
    if (isSuccess) {
      return 'Profile updated successfully!';
    } else {
      return 'Unable to update profile. Please check your information and try again.';
    }
  }

  // 新增：将分页结果合并进现有 Profile（仅替换 activate 列表）
  Profile mergeActivateIntoProfile(Profile profile, ActivatePage page) {
    return profile.copyWith(activate: page.activate);
  }

  // 新增：将打卡分页结果合并进现有 Profile（仅替换 checkinRecords 列表）
  Profile mergeCheckinsIntoProfile(Profile profile, CheckinPage page) {
    return profile.copyWith(checkinRecords: page.checkinRecords);
  }

  // 新增：将挑战分页结果合并进现有 Profile（仅替换 challengeRecords 列表）
  Profile mergeChallengesIntoProfile(Profile profile, ChallengePage page) {
    return profile.copyWith(challengeRecords: page.challengeRecords);
  }

  // 新增：删除账号相关业务逻辑

  // 验证删除账号操作
  bool validateAccountDeletion(Profile profile) {
    // 检查是否有未完成的挑战或打卡
    final hasOngoingChallenges = profile.ongoingChallenges.isNotEmpty;
    final hasOngoingCheckins = profile.ongoingCheckins.isNotEmpty;
    
    // 如果有进行中的活动，建议用户先完成
    if (hasOngoingChallenges || hasOngoingCheckins) {
      return false;
    }
    
    return true;
  }

  // 处理账号删除成功
  void handleAccountDeletionSuccess() {
    // 这里可以添加删除成功后的业务逻辑
    // 比如记录删除日志、清理本地缓存等
    print('Account deleted successfully');
  }

  // 处理账号删除失败
  void handleAccountDeletionFailure(String error) {
    // 这里可以添加删除失败后的业务逻辑
    // 比如记录错误日志、显示错误提示等
    print('Failed to delete account: $error');
  }

  // 获取删除账号状态消息
  String getAccountDeletionStatusMessage(bool isSuccess) {
    if (isSuccess) {
      return 'Account vanished into thin air! ✨ All data has been wiped clean.';
    } else {
      return 'Oops! Account deletion failed. The server is being stubborn today. 😅';
    }
  }

  // 清理用户数据
  void clearUserData() {
    // 这里可以添加清理用户数据的逻辑
    // 比如清除本地存储、重置状态等
    print('User data cleared');
  }
}
