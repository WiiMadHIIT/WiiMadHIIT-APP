import '../entities/checkin_training/checkin_training_history_item.dart';
import '../entities/checkin_training/checkin_training_result.dart';

/// 训练领域服务
class CheckinTrainingService {
  /// 判断训练历史是否完整
  bool isCheckinTrainingHistoryComplete(List<CheckinTrainingHistoryItem> history) {
    return history.isNotEmpty && history.every((item) => item.rank != null);
  }

  /// 获取当前训练排名
  int? getCurrentTrainingRank(List<CheckinTrainingHistoryItem> history) {
    final currentItem = history.firstWhere(
      (item) => item.isCurrent,
      orElse: () => CheckinTrainingHistoryItem(
        id: '',
        rank: null,
        counts: 0,
        countsPerMin: 0.0,
        timestamp: 0,
      ),
    );
    return currentItem.rank;
  }

  /// 计算训练历史统计信息
  Map<String, dynamic> calculateTrainingStats(List<CheckinTrainingHistoryItem> history) {
    if (history.isEmpty) {
      return {
        'totalSessions': 0,
        'averageCounts': 0,
        'bestCounts': 0,
        'totalCounts': 0,
      };
    }

    final totalSessions = history.length;
    final totalCounts = history.fold(0, (sum, item) => sum + item.counts);
    final averageCounts = totalCounts / totalSessions;
    final bestCounts = history.fold(0, (max, item) => item.counts > max ? item.counts : max);

    return {
      'totalSessions': totalSessions,
      'averageCounts': averageCounts.round(),
      'bestCounts': bestCounts,
      'totalCounts': totalCounts,
    };
  }

  /// 验证训练结果数据
  bool isValidTrainingResult(CheckinTrainingResult result) {
    return result.trainingId.isNotEmpty &&
           result.countsPerMin >= 0.0 &&
           result.totalSeconds > 0 &&
           result.counts >= 0 &&
           result.timestamp > 0;
  }

  /// 生成训练历史项
  CheckinTrainingHistoryItem createTrainingHistoryItem({
    required String id,
    required int counts,
    required double countsPerMin,
    required int timestamp,
    int? rank,
    String? note,
  }) {
    return CheckinTrainingHistoryItem(
      id: id,
      rank: rank,
      counts: counts,
      countsPerMin: countsPerMin,
      timestamp: timestamp,
      note: note,
    );
  }

  /// 格式化训练时间
  String formatTrainingTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// 判断是否为今天的训练
  bool isTodayTraining(int timestamp) {
    final trainingDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final today = DateTime.now();
    return trainingDate.year == today.year &&
           trainingDate.month == today.month &&
           trainingDate.day == today.day;
  }

  /// 获取训练难度等级
  String getTrainingDifficulty(int counts) {
    if (counts >= 25) return 'Expert';
    if (counts >= 20) return 'Advanced';
    if (counts >= 15) return 'Intermediate';
    if (counts >= 10) return 'Beginner';
    return 'Novice';
  }
}