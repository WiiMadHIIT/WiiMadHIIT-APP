import 'package:flutter/material.dart';

class Profile {
  final User user;
  final UserStats stats;
  final List<Honor> honors;
  final List<ChallengeRecord> challengeRecords;
  final List<CheckinRecord> checkinRecords;
  final List<Activate> activate;

  Profile({
    required this.user,
    required this.stats,
    required this.honors,
    required this.challengeRecords,
    required this.checkinRecords,
    required this.activate,
  });

  // 新增：创建更新后的Profile对象
  Profile copyWith({
    User? user,
    UserStats? stats,
    List<Honor>? honors,
    List<ChallengeRecord>? challengeRecords,
    List<CheckinRecord>? checkinRecords,
    List<Activate>? activate,
  }) {
    return Profile(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      honors: honors ?? this.honors,
      challengeRecords: challengeRecords ?? this.challengeRecords,
      checkinRecords: checkinRecords ?? this.checkinRecords,
      activate: activate ?? this.activate,
    );
  }

  // 业务方法
  List<ChallengeRecord> get sortedChallengeRecords {
    final sorted = List<ChallengeRecord>.from(challengeRecords);
    sorted.sort((a, b) => a.index.compareTo(b.index));
    return sorted;
  }

  List<CheckinRecord> get sortedCheckinRecords {
    final sorted = List<CheckinRecord>.from(checkinRecords);
    sorted.sort((a, b) => a.index.compareTo(b.index));
    return sorted;
  }

  List<Honor> get sortedHonors {
    final sorted = List<Honor>.from(honors);
    sorted.sort((a, b) => a.timestep.compareTo(b.timestep));
    return sorted;
  }

  // 获取进行中的挑战
  List<ChallengeRecord> get ongoingChallenges {
    return challengeRecords.where((record) => record.status == 'ongoing').toList();
  }

  // 获取已完成的挑战
  List<ChallengeRecord> get completedChallenges {
    return challengeRecords.where((record) => record.status == 'ended').toList();
  }

  // 获取准备就绪的挑战
  List<ChallengeRecord> get readyChallenges {
    return challengeRecords.where((record) => record.status == 'ready').toList();
  }

  // 获取进行中的打卡记录
  List<CheckinRecord> get ongoingCheckins {
    return checkinRecords.where((record) => record.status == 'ongoing').toList();
  }

  // 获取已完成的打卡记录
  List<CheckinRecord> get completedCheckins {
    return checkinRecords.where((record) => record.status == 'ended').toList();
  }

  // 获取准备就绪的打卡记录
  List<CheckinRecord> get readyCheckins {
    return checkinRecords.where((record) => record.status == 'ready').toList();
  }
}

class User {
  final String userId;
  final String username;
  final String email;
  final String avatarUrl;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.avatarUrl,
  });

  // 业务方法
  bool get hasAvatar => avatarUrl.isNotEmpty;
  String get displayName => username.isNotEmpty ? username : 'Guest User';

  // 新增：创建更新后的用户对象
  User copyWith({
    String? username,
    String? email,
  }) {
    return User(
      userId: userId,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl,
    );
  }
}

class UserStats {
  final int currentStreak;
  final int daysThisYear;
  final int daysAllTime;

  UserStats({
    required this.currentStreak,
    required this.daysThisYear,
    required this.daysAllTime,
  });

  // 业务方法
  String get currentStreakText => '$currentStreak days';
  String get daysThisYearText => '$daysThisYear days';
  String get daysAllTimeText => '$daysAllTime days';
  
  // 计算等级
  int get level {
    if (daysThisYear >= 365) return 5; // 大师级
    if (daysThisYear >= 200) return 4; // 专家级
    if (daysThisYear >= 100) return 3; // 进阶级
    if (daysThisYear >= 50) return 2;  // 初级
    return 1; // 新手
  }

  // 获取等级名称
  String get levelName {
    switch (level) {
      case 5:
        return 'Master';
      case 4:
        return 'Expert';
      case 3:
        return 'Advanced';
      case 2:
        return 'Intermediate';
      case 1:
      default:
        return 'Newcomer';
    }
  }

  // 计算下一等级进度
  double get nextLevelProgress {
    switch (level) {
      case 1:
        return daysThisYear / 50.0;
      case 2:
        return (daysThisYear - 50) / 50.0;
      case 3:
        return (daysThisYear - 100) / 100.0;
      case 4:
        return (daysThisYear - 200) / 165.0;
      case 5:
      default:
        return 1.0;
    }
  }
}

class Honor {
  final String id;
  final IconData icon;
  final String label;
  final String description;
  final int timestep;

  Honor({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.timestep,
  });

  // 业务方法
  DateTime get earnedAt => DateTime.fromMillisecondsSinceEpoch(timestep);
  String get timeAgo => _getTimeAgo();
  Color get color => _getColor();

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(earnedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Color _getColor() {
    if (label.contains('Champion') || label.contains('Winner')) {
      return Colors.amber;
    } else if (label.contains('Streak')) {
      return Colors.orange;
    } else if (label.contains('Best')) {
      return Colors.blue;
    }
    return Colors.grey;
  }
}

class ChallengeRecord {
  final String id;
  final String challengeId;
  final int index;
  final String name;
  final String status;
  final int timestep;
  final String rank;

  ChallengeRecord({
    required this.id,
    required this.challengeId,
    required this.index,
    required this.name,
    required this.status,
    required this.timestep,
    required this.rank,
  });

  // 业务方法
  DateTime get completedAt => DateTime.fromMillisecondsSinceEpoch(timestep);
  String get timeAgo => _getTimeAgo();
  bool get isCompleted => status == 'ended';
  bool get isOngoing => status == 'ongoing';
  bool get isReady => status == 'ready';
  Color get statusColor => _getStatusColor();

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(completedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'ended':
        return Colors.grey;
      case 'ongoing':
        return Colors.green;
      case 'ready':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class CheckinRecord {
  final String id;
  final String productId;
  final int index;
  final String name;
  final String status;
  final int timestep;
  final String rank;

  CheckinRecord({
    required this.id,
    required this.productId,
    required this.index,
    required this.name,
    required this.status,
    required this.timestep,
    required this.rank,
  });

  // 业务方法
  DateTime get checkinAt => DateTime.fromMillisecondsSinceEpoch(timestep);
  String get timeAgo => _getTimeAgo();
  bool get isCompleted => status == 'ended';
  bool get isOngoing => status == 'ongoing';
  bool get isReady => status == 'ready';
  Color get statusColor => _getStatusColor();

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(checkinAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'ended':
        return Colors.grey;
      case 'ongoing':
        return Colors.green;
      case 'ready':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class Activate {
  final String challengeId;
  final String challengeName;
  final String productId;
  final String productName;

  Activate({
    required this.challengeId,
    required this.challengeName,
    required this.productId,
    required this.productName,
  });

  // 业务方法
  bool get isValid => challengeId.isNotEmpty && productId.isNotEmpty;
  
  // 获取显示名称
  String get displayName => '$challengeName → $productName';
}

// 新增：激活分页实体（不含 equipmentIds）
class ActivatePage {
  final List<Activate> activate;
  final int total;
  final int currentPage;
  final int pageSize;

  ActivatePage({
    required this.activate,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });
}

// 新增：打卡记录分页实体
class CheckinPage {
  final List<CheckinRecord> checkinRecords;
  final int total;
  final int currentPage;
  final int pageSize;

  CheckinPage({
    required this.checkinRecords,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });
}

// 新增：挑战记录分页实体
class ChallengePage {
  final List<ChallengeRecord> challengeRecords;
  final int total;
  final int currentPage;
  final int pageSize;

  ChallengePage({
    required this.challengeRecords,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });
}