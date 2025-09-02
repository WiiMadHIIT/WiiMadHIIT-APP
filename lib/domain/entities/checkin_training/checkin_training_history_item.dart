/// 训练历史记录项实体
class CheckinTrainingHistoryItem {
  final String? id; // 🎯 修改：id可以为null，用于临时记录
  final int? rank; // 可为null，表示正在加载
  final int counts;
  final double countsPerMin; // 每分钟标准化计数
  final int timestamp; // 毫秒时间戳
  final String? note; // 用于标识当前训练结果（不从后端获取）

  CheckinTrainingHistoryItem({
    this.id, // 🎯 修改：id不再是required
    this.rank, // 可为null
    required this.counts,
    required this.countsPerMin,
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
  CheckinTrainingHistoryItem copyWith({
    String? id,
    int? rank,
    int? counts,
    double? countsPerMin,
    int? timestamp,
    String? note,
  }) {
    return CheckinTrainingHistoryItem(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      counts: counts ?? this.counts,
      countsPerMin: countsPerMin ?? this.countsPerMin,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // 🎯 id可能为null，这是正常的
      'rank': rank,
      'counts': counts,
      'countsPerMin': countsPerMin,
      'timestamp': timestamp,
      'note': note,
    };
  }

  /// 从Map创建
  factory CheckinTrainingHistoryItem.fromMap(Map<String, dynamic> map) {
    return CheckinTrainingHistoryItem(
      id: map['id'] as String?,
      rank: map['rank'] as int?,
      counts: map['counts'] as int,
      countsPerMin: (map['countsPerMin'] as num).toDouble(),
      timestamp: map['timestamp'] as int,
      note: map['note'] as String?,
    );
  }

  /// 创建当前训练结果的历史项
  factory CheckinTrainingHistoryItem.createCurrent({
    required String id,
    required int counts,
    required double countsPerMin,
    required int timestamp,
  }) {
    return CheckinTrainingHistoryItem(
      id: id,
      rank: null, // 正在加载排名
      counts: counts,
      countsPerMin: countsPerMin,
      timestamp: timestamp,
      note: "current",
    );
  }

  /// 创建加载中的历史项
  factory CheckinTrainingHistoryItem.createLoading({
    required String id,
    required int counts,
    required double countsPerMin,
    required int timestamp,
  }) {
    return CheckinTrainingHistoryItem(
      id: id,
      rank: null,
      counts: counts,
      countsPerMin: countsPerMin,
      timestamp: timestamp,
      note: "loading",
    );
  }

  @override
  String toString() {
    return 'CheckinTrainingHistoryItem(id: $id, rank: $rank, counts: $counts, countsPerMin: $countsPerMin, timestamp: $timestamp, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckinTrainingHistoryItem &&
        other.id == id &&
        other.rank == rank &&
        other.counts == counts &&
        other.countsPerMin == countsPerMin &&
        other.timestamp == timestamp &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        rank.hashCode ^
        counts.hashCode ^
        countsPerMin.hashCode ^
        timestamp.hashCode ^
        note.hashCode;
  }
} 