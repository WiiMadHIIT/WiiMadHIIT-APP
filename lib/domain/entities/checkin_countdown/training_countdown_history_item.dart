/// 倒计时训练历史记录项实体
class TrainingCountdownHistoryItem {
  final String? id; // 🎯 修改：id可以为null，用于临时记录
  final int? rank; // 可为null，表示正在加载
  final int? daySeconds; // 每日总秒数，可为null
  final int seconds; // 训练秒数
  final int timestamp; // 毫秒时间戳（前端本地生成）
  final String? note; // 用于标识当前训练结果

  TrainingCountdownHistoryItem({
    this.id, // 🎯 修改：id不再是required
    this.rank, // 可为null
    this.daySeconds, // 🎯 修改：daySeconds不再是required
    required this.seconds,
    required this.timestamp,
    this.note,
  });

  /// 用于显示的历史记录项
  String get displayDate {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// 判断是否为当前训练结果
  bool get isCurrent => note == "current";

  /// 判断是否正在加载排名
  bool get isLoadingRank => rank == null && isCurrent;

  /// 获取排名显示文本
  String get rankDisplay {
    if (rank == null) return '--';
    return '#$rank';
  }

  /// 获取时间显示文本
  String get timeDisplay {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// 获取训练时长显示文本
  String get durationDisplay {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// 获取每日总秒数显示文本
  String get daySecondsDisplay {
    if (daySeconds == null) return '--';
    final minutes = daySeconds! ~/ 60;
    final remainingSeconds = daySeconds! % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${daySeconds}s';
    }
  }

  /// 复制并更新字段
  TrainingCountdownHistoryItem copyWith({
    String? id,
    int? rank,
    int? daySeconds, // 🎯 修改：daySeconds可为null
    int? seconds,
    int? timestamp,
    String? note,
  }) {
    return TrainingCountdownHistoryItem(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      daySeconds: daySeconds ?? this.daySeconds,
      seconds: seconds ?? this.seconds,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // 🎯 id可能为null，这是正常的
      'rank': rank,
      'daySeconds': daySeconds, // 🎯 daySeconds可能为null，这是正常的
      'seconds': seconds,
      'timestamp': timestamp,
      'note': note,
    };
  }

  /// 从Map创建
  factory TrainingCountdownHistoryItem.fromMap(Map<String, dynamic> map) {
    return TrainingCountdownHistoryItem(
      id: map['id'] as String?,
      rank: map['rank'] as int?,
      daySeconds: map['daySeconds'] as int?, // 🎯 修改：daySeconds可为null
      seconds: map['seconds'] as int,
      timestamp: map['timestamp'] as int,
      note: map['note'] as String?,
    );
  }

  /// 创建当前训练结果的历史项
  factory TrainingCountdownHistoryItem.createCurrent({
    required String id,
    int? daySeconds, // 🎯 修改：daySeconds可为null
    required int seconds,
    required int timestamp,
  }) {
    return TrainingCountdownHistoryItem(
      id: id,
      rank: null, // 正在加载排名
      daySeconds: daySeconds,
      seconds: seconds,
      timestamp: timestamp,
      note: "current",
    );
  }

  /// 创建加载中的历史项
  factory TrainingCountdownHistoryItem.createLoading({
    required String id,
    int? daySeconds, // 🎯 修改：daySeconds可为null
    required int seconds,
    required int timestamp,
  }) {
    return TrainingCountdownHistoryItem(
      id: id,
      rank: null,
      daySeconds: daySeconds,
      seconds: seconds,
      timestamp: timestamp,
      note: "loading",
    );
  }

  @override
  String toString() {
    return 'TrainingCountdownHistoryItem(id: $id, rank: $rank, daySeconds: $daySeconds, seconds: $seconds, timestamp: $timestamp, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingCountdownHistoryItem &&
        other.id == id &&
        other.rank == rank &&
        other.daySeconds == daySeconds &&
        other.seconds == seconds &&
        other.timestamp == timestamp &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        rank.hashCode ^
        daySeconds.hashCode ^
        seconds.hashCode ^
        timestamp.hashCode ^
        note.hashCode;
  }
} 