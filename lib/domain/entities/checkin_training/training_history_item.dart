/// 训练历史记录项实体
class TrainingHistoryItem {
  final String id;
  final int? rank; // 可为null，表示正在加载
  final int counts;
  final int timestamp; // 毫秒时间戳
  final String? note; // 用于标识当前训练结果

  TrainingHistoryItem({
    required this.id,
    this.rank, // 可为null
    required this.counts,
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

  /// 复制并更新字段
  TrainingHistoryItem copyWith({
    String? id,
    int? rank,
    int? counts,
    int? timestamp,
    String? note,
  }) {
    return TrainingHistoryItem(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      counts: counts ?? this.counts,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rank': rank,
      'counts': counts,
      'timestamp': timestamp,
      'note': note,
    };
  }

  /// 从Map创建
  factory TrainingHistoryItem.fromMap(Map<String, dynamic> map) {
    return TrainingHistoryItem(
      id: map['id'] as String,
      rank: map['rank'] as int?,
      counts: map['counts'] as int,
      timestamp: map['timestamp'] as int,
      note: map['note'] as String?,
    );
  }

  /// 创建当前训练结果的历史项
  factory TrainingHistoryItem.createCurrent({
    required String id,
    required int counts,
    required int timestamp,
  }) {
    return TrainingHistoryItem(
      id: id,
      rank: null, // 正在加载排名
      counts: counts,
      timestamp: timestamp,
      note: "current",
    );
  }

  /// 创建加载中的历史项
  factory TrainingHistoryItem.createLoading({
    required String id,
    required int counts,
    required int timestamp,
  }) {
    return TrainingHistoryItem(
      id: id,
      rank: null,
      counts: counts,
      timestamp: timestamp,
      note: "loading",
    );
  }

  @override
  String toString() {
    return 'TrainingHistoryItem(id: $id, rank: $rank, counts: $counts, timestamp: $timestamp, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingHistoryItem &&
        other.id == id &&
        other.rank == rank &&
        other.counts == counts &&
        other.timestamp == timestamp &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        rank.hashCode ^
        counts.hashCode ^
        timestamp.hashCode ^
        note.hashCode;
  }
} 