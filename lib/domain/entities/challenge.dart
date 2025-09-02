/// 挑战状态枚举
enum ChallengeStatus {
  ongoing,    // 进行中
  ended,      // 已结束
  upcoming    // 即将开始
}

/// 挑战业务实体 - 代表业务世界中的挑战对象
class Challenge {
  final String id;             // 挑战唯一ID
  final String name;           // 挑战名称/标题
  final String reward;         // 奖励内容描述
  final DateTime endDate;      // 结束时间
  final String status;         // 挑战状态 (字符串格式)
  final String? videoUrl;      // 视频URL (可选)
  final String? description;   // 挑战描述信息 (可选)

  Challenge({
    required this.id,
    required this.name,
    required this.reward,
    required this.endDate,
    required this.status,
    this.videoUrl,
    this.description,
  });

  /// 获取状态枚举值
  ChallengeStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return ChallengeStatus.ongoing;
      case 'ended':
        return ChallengeStatus.ended;
      case 'upcoming':
        return ChallengeStatus.upcoming;
      default:
        return ChallengeStatus.upcoming;
    }
  }

  /// 业务规则：检查挑战是否有效
  bool get isValid {
    // 基本字段验证：确保必要字段不为空
    return id.isNotEmpty && name.isNotEmpty && reward.isNotEmpty;
  }

  /// 业务规则：检查挑战是否已结束
  bool get isEnded {
    return DateTime.now().isAfter(endDate);
  }

  /// 业务规则：检查挑战是否即将开始
  bool get isUpcoming {
    return DateTime.now().isBefore(endDate) && 
           DateTime.now().isAfter(endDate.subtract(const Duration(days: 7)));
  }

  /// 业务规则：检查挑战是否正在进行
  bool get isOngoing {
    return !isEnded && !isUpcoming;
  }

  /// 业务规则：检查是否有视频资源
  bool get hasVideo => videoUrl != null && 
                      videoUrl!.isNotEmpty && 
                      videoUrl!.startsWith('https://');

  /// 业务规则：检查是否有描述信息
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// 业务规则：获取挑战显示名称（可扩展为多语言支持）
  String get displayName => name;

  /// 业务规则：获取挑战显示描述（可扩展为多语言支持）
  String get displayDescription => description ?? '';

  /// 业务规则：获取挑战唯一标识（用于缓存和比较）
  String get uniqueKey => "challenge_$id";

  /// 业务规则：获取挑战摘要信息
  String get summary {
    if (description == null || description!.isEmpty) return '';
    final words = description!.split(' ');
    if (words.length <= 15) return description!;
    return '${words.take(15).join(' ')}...';
  }

  /// 业务规则：获取剩余时间描述
  String get timeRemainingText {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.isNegative) {
      return 'Ended';
    }
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Less than 1m left';
    }
  }

  /// 业务规则：获取状态颜色
  String get statusColor {
    switch (statusEnum) {
      case ChallengeStatus.ongoing:
        return '#00C851'; // Green - Ongoing
      case ChallengeStatus.ended:
        return '#6C757D'; // Gray - Ended
      case ChallengeStatus.upcoming:
        return '#FF6B35'; // Orange - Upcoming
    }
  }

  /// 业务规则：获取状态文本
  String get statusText {
    switch (statusEnum) {
      case ChallengeStatus.ongoing:
        return 'Ongoing';
      case ChallengeStatus.ended:
        return 'Ended';
      case ChallengeStatus.upcoming:
        return 'Upcoming';
    }
  }

  /// 业务规则：检查挑战是否可以被参与
  bool get canParticipate {
    return statusEnum == ChallengeStatus.ongoing || 
           statusEnum == ChallengeStatus.upcoming;
  }

  /// 业务规则：检查挑战是否显示奖励
  bool get shouldShowReward {
    return reward.isNotEmpty && 
           (statusEnum == ChallengeStatus.ongoing || 
            statusEnum == ChallengeStatus.upcoming);
  }

  /// 业务规则：获取挑战优先级（用于排序）
  int get priority {
    switch (statusEnum) {
      case ChallengeStatus.ongoing:
        return 1; // 最高优先级
      case ChallengeStatus.upcoming:
        return 2; // 中等优先级
      case ChallengeStatus.ended:
        return 3; // 最低优先级
    }
  }

  /// 复制并修改挑战对象
  Challenge copyWith({
    String? id,
    String? name,
    String? reward,
    DateTime? endDate,
    String? status,
    String? videoUrl,
    String? description,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      reward: reward ?? this.reward,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
    );
  }

  /// 转换为Map（用于序列化）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reward': reward,
      'endDate': endDate.toIso8601String(),
      'status': status,
      'videoUrl': videoUrl,
      'description': description,
    };
  }

  /// 从Map创建挑战对象（用于反序列化）
  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      name: map['name'] as String,
      reward: map['reward'] as String,
      endDate: DateTime.parse(map['endDate'] as String),
      status: map['status'] as String,
      videoUrl: map['videoUrl'] as String?,
      description: map['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Challenge(id: $id, name: $name, status: $status, endDate: $endDate)';
  }
} 