import 'package:flutter/material.dart';

class Announcement {
  final String id;
  final String title;
  final String subtitle;
  final int priority;

  Announcement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
  });

  // 业务方法 - 前端硬编码映射
  IconData get icon => _getDefaultIcon();
  Color get color => _getDefaultColor();

  IconData _getDefaultIcon() {
    // 根据标题内容智能匹配图标
    if (title.contains('🔥') || title.contains('连续')) {
      return Icons.local_fire_department;
    } else if (title.contains('🎉') || title.contains('恭喜')) {
      return Icons.celebration;
    } else if (title.contains('⚡') || title.contains('挑战')) {
      return Icons.flash_on;
    } else if (title.contains('🏆') || title.contains('冠军')) {
      return Icons.emoji_events;
    }
    return Icons.announcement;
  }

  Color _getDefaultColor() {
    // 根据优先级和内容智能匹配颜色
    if (priority == 1) {
      return Colors.red;
    } else if (priority == 2) {
      return Colors.orange;
    } else if (priority == 3) {
      return Colors.blue;
    }
    return Colors.grey;
  }
}

class Champion {
  final String userId;
  final String username;
  final String challengeName;
  final String challengeId;
  final int rank;
  final int counts;
  final DateTime completedAt;
  final String avatar;

  Champion({
    required this.userId,
    required this.username,
    required this.challengeName,
    required this.challengeId,
    required this.rank,
    required this.counts,
    required this.completedAt,
    required this.avatar,
  });

  // 业务方法
  String get rankText => '$rank';
  String get scoreText => counts.toString();
  String get timeAgo => _getTimeAgo();
  Color get rankColor => _getRankColor();

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(completedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}

class ActiveUser {
  final String userId;
  final String username;
  final int streakDays;
  final DateTime lastCheckinDate;
  final int yearlyCheckins;
  final String latestActivityName;
  final String avatar;

  ActiveUser({
    required this.userId,
    required this.username,
    required this.streakDays,
    required this.lastCheckinDate,
    required this.yearlyCheckins,
    required this.latestActivityName,
    required this.avatar,
  });

  // 业务方法
  String get streakText => '$streakDays天';
  String get yearlyText => '$yearlyCheckins天';
  String get lastCheckinText => _getLastCheckinText();
  Color get streakColor => _getStreakColor();

  String _getLastCheckinText() {
    final now = DateTime.now();
    final difference = now.difference(lastCheckinDate);
    
    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${lastCheckinDate.month}/${lastCheckinDate.day}';
    }
  }

  Color _getStreakColor() {
    if (streakDays >= 30) {
      return Colors.purple;
    } else if (streakDays >= 21) {
      return Colors.red;
    } else if (streakDays >= 14) {
      return Colors.orange;
    } else if (streakDays >= 7) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
}
