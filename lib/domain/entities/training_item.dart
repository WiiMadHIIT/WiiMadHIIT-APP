class TrainingItem {
  final String id;
  final String name;
  final int level; // 1-10 星级
  final String description;
  final int participantCount;
  final String status;

  TrainingItem({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.participantCount,
    required this.status,
  });

  // 检查训练是否可用
  bool get isActive => status == 'ACTIVE';

  // 难度颜色（按星级粗略映射）
  String get levelColor {
    if (level <= 2) return 'green';
    if (level <= 4) return 'orange';
    if (level <= 7) return 'red';
    return 'purple';
  }

  // 取消完成率显示（已移除 completionRate 字段）
  String get completionRateText => '';

  // 获取参与人数显示文本
  String get participantCountText {
    if (participantCount >= 1000) {
      return '${(participantCount / 1000).toStringAsFixed(1)}K';
    }
    return participantCount.toString();
  }

  // 获取训练摘要
  String get summary {
    return '$name - $level stars training';
  }

  // 检查是否为热门训练
  bool get isPopular => participantCount > 1000;

  // 取消高完成率判断（已移除 completionRate）
  bool get isHighCompletion => false;

  // 训练难度等级直接用星级
  int get difficultyLevel => level.clamp(1, 10);
} 