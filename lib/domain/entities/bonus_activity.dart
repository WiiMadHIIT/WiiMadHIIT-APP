class BonusActivity {
  final String id;
  final String name;
  final String description;
  final String reward;
  final String regionLimit;
  final String videoUrl;
  final String activityName;
  final String activityDescription;
  final String activityCode;
  final String activityUrl;
  final int startTimeStep;
  final int endTimeStep;

  BonusActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.reward,
    required this.regionLimit,
    required this.videoUrl,
    required this.activityName,
    required this.activityDescription,
    required this.activityCode,
    required this.activityUrl,
    required this.startTimeStep,
    required this.endTimeStep,
  });

  // 业务规则示例
  bool get isActive {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= startTimeStep && now <= endTimeStep;
  }
  
  bool get isExpired => DateTime.now().millisecondsSinceEpoch > endTimeStep;
  bool get isNotStarted => DateTime.now().millisecondsSinceEpoch < startTimeStep;
  bool get isGlobal => regionLimit == 'Global';
  
  // 检查活动是否在有效期内
  bool get isInValidPeriod {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= startTimeStep && now <= endTimeStep;
  }

  // 获取活动状态描述
  String get statusDescription {
    if (isExpired) return 'Expired';
    if (isNotStarted) return 'Not Started';
    if (isActive) return 'Active';
    return 'Unknown';
  }

  // 获取剩余时间（毫秒）
  int get remainingTime {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > endTimeStep) return 0;
    return endTimeStep - now;
  }

  // 获取剩余天数
  int get remainingDays {
    final remainingMs = remainingTime;
    return (remainingMs / (1000 * 60 * 60 * 24)).ceil();
  }

  // 获取活动持续时间（天）
  int get durationDays {
    final durationMs = endTimeStep - startTimeStep;
    return (durationMs / (1000 * 60 * 60 * 24)).ceil();
  }

  // 检查用户是否符合地区限制
  bool isEligibleForRegion(String userRegion) {
    if (isGlobal) return true;
    return regionLimit.contains(userRegion);
  }

  // 获取活动进度百分比
  double get progressPercentage {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now < startTimeStep) return 0.0;
    if (now > endTimeStep) return 100.0;
    
    final totalDuration = endTimeStep - startTimeStep;
    final elapsed = now - startTimeStep;
    return (elapsed / totalDuration) * 100;
  }
} 