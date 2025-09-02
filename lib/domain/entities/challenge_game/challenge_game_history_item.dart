/// 挑战游戏历史记录项实体
class ChallengeGameHistoryItem {
  final String? id; // 🎯 修改：id可以为null，用于临时记录
  final int? rank; // 可为null，表示正在加载
  final int counts;
  final int timestamp; // 毫秒时间戳
  final String? note; // 用于标识当前挑战结果
  final String name; // 🎯 新增：用户名
  final String userId; // 🎯 新增：用户ID

  ChallengeGameHistoryItem({
    this.id, // 🎯 修改：id不再是required
    this.rank, // 可为null
    required this.counts,
    required this.timestamp,
    this.note,
    required this.name, // 🎯 新增：用户名
    required this.userId, // 🎯 新增：用户ID
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

  /// 判断是否为当前挑战结果
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
  ChallengeGameHistoryItem copyWith({
    String? id,
    int? rank,
    int? counts,
    int? timestamp,
    String? note,
    String? name,
    String? userId,
  }) {
    return ChallengeGameHistoryItem(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      counts: counts ?? this.counts,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      name: name ?? this.name,
      userId: userId ?? this.userId,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // 🎯 id可能为null，这是正常的
      'rank': rank,
      'counts': counts,
      'timestamp': timestamp,
      'note': note,
      'name': name,
      'userId': userId,
    };
  }

  /// 从Map创建
  factory ChallengeGameHistoryItem.fromMap(Map<String, dynamic> map) {
    return ChallengeGameHistoryItem(
      id: map['id'] as String?,
      rank: map['rank'] as int?,
      counts: map['counts'] as int,
      timestamp: map['timestamp'] as int,
      note: map['note'] as String?,
      name: map['name'] as String,
      userId: map['userId'] as String,
    );
  }

  /// 创建当前挑战结果的历史项
  factory ChallengeGameHistoryItem.createCurrent({
    required String id,
    required int counts,
    required int timestamp,
    required String name,
    required String userId,
  }) {
    return ChallengeGameHistoryItem(
      id: id,
      rank: null, // 正在加载排名
      counts: counts,
      timestamp: timestamp,
      note: "current",
      name: name,
      userId: userId,
    );
  }

  /// 创建加载中的历史项
  factory ChallengeGameHistoryItem.createLoading({
    required String id,
    required int counts,
    required int timestamp,
    required String name,
    required String userId,
  }) {
    return ChallengeGameHistoryItem(
      id: id,
      rank: null,
      counts: counts,
      timestamp: timestamp,
      note: "loading",
      name: name,
      userId: userId,
    );
  }

  @override
  String toString() {
    return 'ChallengeGameHistoryItem(id: $id, rank: $rank, counts: $counts, timestamp: $timestamp, note: $note, name: $name, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeGameHistoryItem &&
        other.id == id &&
        other.rank == rank &&
        other.counts == counts &&
        other.timestamp == timestamp &&
        other.note == note &&
        other.name == name &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        rank.hashCode ^
        counts.hashCode ^
        timestamp.hashCode ^
        note.hashCode ^
        name.hashCode ^
        userId.hashCode;
  }
} 