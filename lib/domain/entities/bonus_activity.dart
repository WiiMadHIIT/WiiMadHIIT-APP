class BonusActivity {
  final String id;
  final String name;
  final String description;
  final String reward;
  final String regionLimit;
  final String videoUrl; // 改为 videoUrl
  final String? thumbnailUrl;
  final String status;
  final String startDate;
  final String endDate;
  final bool isClaimed;
  final bool isEligible;
  final int claimCount;
  final int maxClaimCount;
  final String category;
  final String difficulty;

  BonusActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.reward,
    required this.regionLimit,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.isClaimed,
    required this.isEligible,
    required this.claimCount,
    required this.maxClaimCount,
    required this.category,
    required this.difficulty,
  });

  // 业务规则示例
  bool get isActive => status == 'ACTIVE';
  bool get isExpired => status == 'EXPIRED';
  bool get canClaim => isActive && isEligible && !isClaimed;
  bool get isGlobal => regionLimit == 'Global';
  
  // 计算剩余可领取数量
  int get remainingCount => maxClaimCount - claimCount;
  
  // 检查活动是否在有效期内
  bool get isInValidPeriod {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return now.isAfter(start) && now.isBefore(end);
  }

  // 获取活动状态描述
  String get statusDescription {
    if (isExpired) return 'Expired';
    if (!isInValidPeriod) return 'Not Started';
    if (isClaimed) return 'Claimed';
    if (!isEligible) return 'Not Eligible';
    return 'Available';
  }

  // 获取难度等级显示
  String get difficultyDisplay {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return difficulty;
    }
  }

  // 获取分类显示
  String get categoryDisplay {
    switch (category.toLowerCase()) {
      case 'challenge':
        return 'Challenge';
      case 'marathon':
        return 'Marathon';
      case 'limited':
        return 'Limited Time';
      default:
        return category;
    }
  }
} 