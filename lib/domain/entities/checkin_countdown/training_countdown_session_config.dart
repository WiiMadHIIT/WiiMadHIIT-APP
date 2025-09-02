/// 倒计时训练会话配置实体
class TrainingCountdownSessionConfig {
  final int totalRounds;
  final int roundDuration;
  final int preCountdown;
  final String backgroundType;
  final bool videoEnabled;

  TrainingCountdownSessionConfig({
    required this.totalRounds,
    required this.roundDuration,
    required this.preCountdown,
    required this.backgroundType,
    required this.videoEnabled,
  });

  /// 本地配置，不需要从API获取
  factory TrainingCountdownSessionConfig.defaultConfig() {
    return TrainingCountdownSessionConfig(
      totalRounds: 1,
      roundDuration: 60,
      preCountdown: 10,
      backgroundType: 'video', // 倒计时训练默认使用视频背景
      videoEnabled: true,
    );
  }

  /// 创建自定义配置
  factory TrainingCountdownSessionConfig.custom({
    required int totalRounds,
    required int roundDuration,
    int preCountdown = 10,
    String backgroundType = 'video',
    bool videoEnabled = true,
  }) {
    return TrainingCountdownSessionConfig(
      totalRounds: totalRounds,
      roundDuration: roundDuration,
      preCountdown: preCountdown,
      backgroundType: backgroundType,
      videoEnabled: videoEnabled,
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

  /// 获取倒计时显示文本
  String get preCountdownDisplay {
    return '${preCountdown}s';
  }

  /// 复制并更新字段
  TrainingCountdownSessionConfig copyWith({
    int? totalRounds,
    int? roundDuration,
    int? preCountdown,
    String? backgroundType,
    bool? videoEnabled,
  }) {
    return TrainingCountdownSessionConfig(
      totalRounds: totalRounds ?? this.totalRounds,
      roundDuration: roundDuration ?? this.roundDuration,
      preCountdown: preCountdown ?? this.preCountdown,
      backgroundType: backgroundType ?? this.backgroundType,
      videoEnabled: videoEnabled ?? this.videoEnabled,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'totalRounds': totalRounds,
      'roundDuration': roundDuration,
      'preCountdown': preCountdown,
      'backgroundType': backgroundType,
      'videoEnabled': videoEnabled,
    };
  }

  /// 从Map创建
  factory TrainingCountdownSessionConfig.fromMap(Map<String, dynamic> map) {
    return TrainingCountdownSessionConfig(
      totalRounds: map['totalRounds'] as int,
      roundDuration: map['roundDuration'] as int,
      preCountdown: map['preCountdown'] as int,
      backgroundType: map['backgroundType'] as String,
      videoEnabled: map['videoEnabled'] as bool,
    );
  }

  @override
  String toString() {
    return 'TrainingCountdownSessionConfig(totalRounds: $totalRounds, roundDuration: $roundDuration, preCountdown: $preCountdown, backgroundType: $backgroundType, videoEnabled: $videoEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingCountdownSessionConfig &&
        other.totalRounds == totalRounds &&
        other.roundDuration == roundDuration &&
        other.preCountdown == preCountdown &&
        other.backgroundType == backgroundType &&
        other.videoEnabled == videoEnabled;
  }

  @override
  int get hashCode {
    return totalRounds.hashCode ^
        roundDuration.hashCode ^
        preCountdown.hashCode ^
        backgroundType.hashCode ^
        videoEnabled.hashCode;
  }
} 