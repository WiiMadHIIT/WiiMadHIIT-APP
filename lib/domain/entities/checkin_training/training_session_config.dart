/// 训练会话配置实体
class TrainingSessionConfig {
  final int totalRounds;
  final int roundDuration;
  final int preCountdown;
  final bool audioDetectionEnabled;
  final String backgroundType;

  TrainingSessionConfig({
    required this.totalRounds,
    required this.roundDuration,
    required this.preCountdown,
    required this.audioDetectionEnabled,
    required this.backgroundType,
  });

  /// 本地配置，不需要从API获取
  factory TrainingSessionConfig.defaultConfig() {
    return TrainingSessionConfig(
      totalRounds: 1,
      roundDuration: 60,
      preCountdown: 10,
      audioDetectionEnabled: true,
      backgroundType: 'color',
    );
  }

  /// 创建自定义配置
  factory TrainingSessionConfig.custom({
    required int totalRounds,
    required int roundDuration,
    int preCountdown = 10,
    bool audioDetectionEnabled = true,
    String backgroundType = 'color',
  }) {
    return TrainingSessionConfig(
      totalRounds: totalRounds,
      roundDuration: roundDuration,
      preCountdown: preCountdown,
      audioDetectionEnabled: audioDetectionEnabled,
      backgroundType: backgroundType,
    );
  }

  /// 获取总训练时间（秒）
  int get totalDuration => totalRounds * roundDuration;

  /// 获取总时间（包括倒计时）
  int get totalTimeWithCountdown => totalDuration + preCountdown;

  /// 获取训练时间显示文本
  String get durationDisplay {
    final minutes = totalDuration ~/ 60;
    final seconds = totalDuration % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// 获取轮次显示文本
  String get roundsDisplay {
    if (totalRounds == 1) {
      return '1 Round';
    } else {
      return '$totalRounds Rounds';
    }
  }

  /// 获取轮次时长显示文本
  String get roundDurationDisplay {
    final minutes = roundDuration ~/ 60;
    final seconds = roundDuration % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// 复制并更新字段
  TrainingSessionConfig copyWith({
    int? totalRounds,
    int? roundDuration,
    int? preCountdown,
    bool? audioDetectionEnabled,
    String? backgroundType,
  }) {
    return TrainingSessionConfig(
      totalRounds: totalRounds ?? this.totalRounds,
      roundDuration: roundDuration ?? this.roundDuration,
      preCountdown: preCountdown ?? this.preCountdown,
      audioDetectionEnabled: audioDetectionEnabled ?? this.audioDetectionEnabled,
      backgroundType: backgroundType ?? this.backgroundType,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'totalRounds': totalRounds,
      'roundDuration': roundDuration,
      'preCountdown': preCountdown,
      'audioDetectionEnabled': audioDetectionEnabled,
      'backgroundType': backgroundType,
    };
  }

  /// 从Map创建
  factory TrainingSessionConfig.fromMap(Map<String, dynamic> map) {
    return TrainingSessionConfig(
      totalRounds: map['totalRounds'] as int,
      roundDuration: map['roundDuration'] as int,
      preCountdown: map['preCountdown'] as int,
      audioDetectionEnabled: map['audioDetectionEnabled'] as bool,
      backgroundType: map['backgroundType'] as String,
    );
  }

  @override
  String toString() {
    return 'TrainingSessionConfig(totalRounds: $totalRounds, roundDuration: $roundDuration, preCountdown: $preCountdown, audioDetectionEnabled: $audioDetectionEnabled, backgroundType: $backgroundType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingSessionConfig &&
        other.totalRounds == totalRounds &&
        other.roundDuration == roundDuration &&
        other.preCountdown == preCountdown &&
        other.audioDetectionEnabled == audioDetectionEnabled &&
        other.backgroundType == backgroundType;
  }

  @override
  int get hashCode {
    return totalRounds.hashCode ^
        roundDuration.hashCode ^
        preCountdown.hashCode ^
        audioDetectionEnabled.hashCode ^
        backgroundType.hashCode;
  }
} 