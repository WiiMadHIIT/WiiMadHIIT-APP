import '../entities/checkin_training_voice/training_voice_history_item.dart';
import '../entities/checkin_training_voice/training_voice_result.dart';

/// 语音训练领域服务
class TrainingVoiceService {
  /// 判断语音训练历史是否完整
  bool isTrainingVoiceHistoryComplete(List<TrainingVoiceHistoryItem> history) {
    return history.isNotEmpty && history.every((item) => item.rank != null);
  }

  /// 获取当前语音训练排名
  int? getCurrentTrainingVoiceRank(List<TrainingVoiceHistoryItem> history) {
    final currentItem = history.firstWhere(
      (item) => item.isCurrent,
      orElse: () => TrainingVoiceHistoryItem(
        id: '',
        rank: null,
        counts: 0,
        countsPerMin: 0.0,
        timestamp: 0,
      ),
    );
    return currentItem.rank;
  }

  /// 计算语音训练历史统计信息
  Map<String, dynamic> calculateTrainingVoiceStats(List<TrainingVoiceHistoryItem> history) {
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

  /// 验证语音训练结果数据
  bool isValidTrainingVoiceResult(TrainingVoiceResult result) {
    return result.trainingId.isNotEmpty &&
           result.countsPerMin >= 0.0 &&
           result.totalSeconds > 0 &&
           result.counts >= 0 &&
           result.timestamp > 0;
  }

  /// 生成语音训练历史项
  TrainingVoiceHistoryItem createTrainingVoiceHistoryItem({
    required String id,
    required int counts,
    required double countsPerMin,
    required int timestamp,
    int? rank,
    String? note,
  }) {
    return TrainingVoiceHistoryItem(
      id: id,
      rank: rank,
      counts: counts,
      countsPerMin: countsPerMin,
      timestamp: timestamp,
      note: note,
    );
  }

  /// 格式化语音训练时间
  String formatTrainingVoiceTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// 判断是否为今天的语音训练
  bool isTodayTrainingVoice(int timestamp) {
    final trainingDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final today = DateTime.now();
    return trainingDate.year == today.year &&
           trainingDate.month == today.month &&
           trainingDate.day == today.day;
  }

  /// 获取语音训练难度等级
  String getTrainingVoiceDifficulty(int counts) {
    if (counts >= 25) return 'Expert';
    if (counts >= 20) return 'Advanced';
    if (counts >= 15) return 'Intermediate';
    if (counts >= 10) return 'Beginner';
    return 'Novice';
  }

  /// 计算语音训练总时长（秒）
  int calculateTotalTrainingVoiceDuration(int totalRounds, int roundDuration) {
    return totalRounds * roundDuration;
  }

  /// 获取语音训练时长显示文本
  String getTrainingVoiceDurationDisplay(int totalRounds, int roundDuration) {
    final totalDuration = calculateTotalTrainingVoiceDuration(totalRounds, roundDuration);
    final minutes = totalDuration ~/ 60;
    final seconds = totalDuration % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// 获取语音训练轮次显示文本
  String getTrainingVoiceRoundsDisplay(int totalRounds) {
    if (totalRounds == 1) {
      return '1 Round';
    } else {
      return '$totalRounds Rounds';
    }
  }

  /// 验证语音检测配置
  bool isValidVoiceDetectionConfig({
    required bool enabled,
    required double sensitivity,
    required int debounceTime,
  }) {
    return enabled &&
           sensitivity >= 0.0 && sensitivity <= 1.0 &&
           debounceTime >= 0 && debounceTime <= 1000;
  }
} 