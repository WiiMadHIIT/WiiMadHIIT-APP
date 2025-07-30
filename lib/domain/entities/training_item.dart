class TrainingItem {
  final String id;
  final String name;
  final String level;
  final String description;
  final int participantCount;
  final double completionRate;
  final String status;

  TrainingItem({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.participantCount,
    required this.completionRate,
    required this.status,
  });

  // 检查训练是否可用
  bool get isActive => status == 'ACTIVE';

  // 获取难度等级颜色
  String get levelColor {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'green';
      case 'intermediate':
        return 'orange';
      case 'advanced':
        return 'red';
      case 'expert':
        return 'purple';
      default:
        return 'grey';
    }
  }

  // 获取完成率显示文本
  String get completionRateText => '${completionRate.toStringAsFixed(1)}%';

  // 获取参与人数显示文本
  String get participantCountText {
    if (participantCount >= 1000) {
      return '${(participantCount / 1000).toStringAsFixed(1)}K';
    }
    return participantCount.toString();
  }

  // 获取训练摘要
  String get summary {
    return '$name - $level level training with ${completionRateText} completion rate';
  }

  // 检查是否为热门训练
  bool get isPopular => participantCount > 1000;

  // 检查是否为高完成率训练
  bool get isHighCompletion => completionRate > 80.0;

  // 获取训练难度等级
  int get difficultyLevel {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      case 'expert':
        return 4;
      default:
        return 1;
    }
  }
} 