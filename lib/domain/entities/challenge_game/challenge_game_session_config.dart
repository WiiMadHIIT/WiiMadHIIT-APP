/// 挑战游戏会话配置实体
class ChallengeGameSessionConfig {
  final int totalRounds;
  final int roundDuration;
  final int preCountdown;
  final bool audioDetectionEnabled;
  final String backgroundType;
  final int allowedTimes;

  ChallengeGameSessionConfig({
    required this.totalRounds,
    required this.roundDuration,
    required this.preCountdown,
    required this.audioDetectionEnabled,
    required this.backgroundType,
    required this.allowedTimes,
  });

  /// 本地配置，不需要从API获取
  factory ChallengeGameSessionConfig.defaultConfig() {
    return ChallengeGameSessionConfig(
      totalRounds: 1,
      roundDuration: 60,
      preCountdown: 10,
      audioDetectionEnabled: true,
      backgroundType: 'color',
      allowedTimes: 0, // 默认无次数
    );
  }

  /// 创建自定义配置
  factory ChallengeGameSessionConfig.custom({
    required int totalRounds,
    required int roundDuration,
    int preCountdown = 10,
    bool audioDetectionEnabled = true,
    String backgroundType = 'color',
    int allowedTimes = 0,
  }) {
    return ChallengeGameSessionConfig(
      totalRounds: totalRounds,
      roundDuration: roundDuration,
      preCountdown: preCountdown,
      audioDetectionEnabled: audioDetectionEnabled,
      backgroundType: backgroundType,
      allowedTimes: allowedTimes,
    );
  }

  /// 获取总挑战时间（秒）
  int get totalDuration => totalRounds * roundDuration;

  /// 获取总时间（包括倒计时）
  int get totalTimeWithCountdown => totalDuration + preCountdown;

  /// 获取挑战时间显示文本
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

  /// 检查是否还有挑战次数
  bool get hasAttemptsLeft => allowedTimes > 0;

  /// 检查是否已用完挑战次数
  bool get hasNoAttemptsLeft => allowedTimes <= 0;

  /// 获取剩余次数显示文本
  String get allowedTimesDisplay {
    if (allowedTimes <= 0) return 'No attempts left';
    if (allowedTimes == 1) return '1 attempt left';
    return '$allowedTimes attempts left';
  }

  /// 复制并更新字段
  ChallengeGameSessionConfig copyWith({
    int? totalRounds,
    int? roundDuration,
    int? preCountdown,
    bool? audioDetectionEnabled,
    String? backgroundType,
    int? allowedTimes,
  }) {
    return ChallengeGameSessionConfig(
      totalRounds: totalRounds ?? this.totalRounds,
      roundDuration: roundDuration ?? this.roundDuration,
      preCountdown: preCountdown ?? this.preCountdown,
      audioDetectionEnabled: audioDetectionEnabled ?? this.audioDetectionEnabled,
      backgroundType: backgroundType ?? this.backgroundType,
      allowedTimes: allowedTimes ?? this.allowedTimes,
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
      'allowedTimes': allowedTimes,
    };
  }

  /// 从Map创建
  factory ChallengeGameSessionConfig.fromMap(Map<String, dynamic> map) {
    return ChallengeGameSessionConfig(
      totalRounds: map['totalRounds'] as int,
      roundDuration: map['roundDuration'] as int,
      preCountdown: map['preCountdown'] as int,
      audioDetectionEnabled: map['audioDetectionEnabled'] as bool,
      backgroundType: map['backgroundType'] as String,
      allowedTimes: map['allowedTimes'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'ChallengeGameSessionConfig(totalRounds: $totalRounds, roundDuration: $roundDuration, preCountdown: $preCountdown, audioDetectionEnabled: $audioDetectionEnabled, backgroundType: $backgroundType, allowedTimes: $allowedTimes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeGameSessionConfig &&
        other.totalRounds == totalRounds &&
        other.roundDuration == roundDuration &&
        other.preCountdown == preCountdown &&
        other.audioDetectionEnabled == audioDetectionEnabled &&
        other.backgroundType == backgroundType &&
        other.allowedTimes == allowedTimes;
  }

  @override
  int get hashCode {
    return totalRounds.hashCode ^
        roundDuration.hashCode ^
        preCountdown.hashCode ^
        audioDetectionEnabled.hashCode ^
        backgroundType.hashCode ^
        allowedTimes.hashCode;
  }
} 