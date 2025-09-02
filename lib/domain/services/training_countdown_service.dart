import '../entities/checkin_countdown/training_countdown_history_item.dart';
import '../entities/checkin_countdown/training_countdown_result.dart';

/// 倒计时训练领域服务
class TrainingCountdownService {
  /// 判断倒计时训练历史是否完整
  bool isTrainingCountdownHistoryComplete(List<TrainingCountdownHistoryItem> history) {
    return history.isNotEmpty && history.every((item) => item.rank != null);
  }

  /// 获取当前倒计时训练排名
  int? getCurrentTrainingCountdownRank(List<TrainingCountdownHistoryItem> history) {
    final currentItem = history.firstWhere(
      (item) => item.isCurrent,
      orElse: () => TrainingCountdownHistoryItem(
        id: '',
        rank: null,
        daySeconds: 0,
        seconds: 0,
        timestamp: 0,
      ),
    );
    return currentItem.rank;
  }

  /// 计算倒计时训练历史统计信息
  Map<String, dynamic> calculateTrainingCountdownStats(List<TrainingCountdownHistoryItem> history) {
    if (history.isEmpty) {
      return {
        'totalSessions': 0,
        'averageSeconds': 0,
        'bestSeconds': 0,
        'totalSeconds': 0,
        'averageDaySeconds': 0,
        'totalDaySeconds': 0,
      };
    }

    final totalSessions = history.length;
    final totalSeconds = history.fold(0, (sum, item) => sum + item.seconds);
    final totalDaySeconds = history.fold(0, (sum, item) => sum + (item.daySeconds ?? 0)); // 🎯 修复：处理daySeconds为null的情况
    final averageSeconds = totalSeconds / totalSessions;
    final averageDaySeconds = totalDaySeconds / totalSessions;
    final bestSeconds = history.fold(0, (max, item) => item.seconds > max ? item.seconds : max);

    return {
      'totalSessions': totalSessions,
      'averageSeconds': averageSeconds.round(),
      'bestSeconds': bestSeconds,
      'totalSeconds': totalSeconds,
      'averageDaySeconds': averageDaySeconds.round(),
      'totalDaySeconds': totalDaySeconds,
    };
  }

  /// 验证倒计时训练结果数据
  bool isValidTrainingCountdownResult(TrainingCountdownResult result) {
    return result.trainingId.isNotEmpty &&
           result.seconds >= 0 &&
           result.timestamp > 0;
  }

  /// 生成倒计时训练历史项
  TrainingCountdownHistoryItem createTrainingCountdownHistoryItem({
    String? id, // 🎯 修复：id可为null
    int? daySeconds, // 🎯 修复：daySeconds可为null
    required int seconds,
    required int timestamp,
    int? rank,
    String? note,
  }) {
    return TrainingCountdownHistoryItem(
      id: id,
      rank: rank,
      daySeconds: daySeconds,
      seconds: seconds,
      timestamp: timestamp,
      note: note,
    );
  }

  /// 格式化倒计时训练时间
  String formatTrainingCountdownTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// 判断是否为今天的倒计时训练
  bool isTodayTrainingCountdown(int timestamp) {
    final trainingDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final today = DateTime.now();
    return trainingDate.year == today.year &&
           trainingDate.month == today.month &&
           trainingDate.day == today.day;
  }

  /// 获取倒计时训练难度等级
  String getTrainingCountdownDifficulty(int seconds) {
    if (seconds >= 1200) return 'Expert';      // 20分钟以上
    if (seconds >= 900) return 'Advanced';     // 15-20分钟
    if (seconds >= 600) return 'Intermediate'; // 10-15分钟
    if (seconds >= 300) return 'Beginner';     // 5-10分钟
    return 'Novice';                           // 5分钟以下
  }

  /// 格式化训练时长显示
  String formatTrainingCountdownDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// 计算训练效率（秒数/轮次）
  double calculateTrainingCountdownEfficiency(int seconds, int totalRounds) {
    if (totalRounds <= 0) return 0.0;
    return seconds / totalRounds;
  }

  /// 判断是否为高强度训练
  bool isHighIntensityTraining(int seconds, int totalRounds) {
    final efficiency = calculateTrainingCountdownEfficiency(seconds, totalRounds);
    return efficiency >= 60; // 每轮60秒以上为高强度
  }
} 