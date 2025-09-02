class ChallengeConfig {
  final String nextPageRoute;
  final bool isActivated;
  final bool isQualified;
  final int allowedTimes;
  final int totalRounds;
  final int roundDuration;

  ChallengeConfig({
    required this.nextPageRoute,
    required this.isActivated,
    required this.isQualified,
    required this.allowedTimes,
    required this.totalRounds,
    required this.roundDuration,
  });

  // 业务逻辑方法
  bool get isValid => nextPageRoute.isNotEmpty;
  
  bool get canStartChallenge => isActivated && isQualified && allowedTimes > 0;
  
  bool get needsActivation => !isActivated;
  
  bool get needsQualification => !isQualified;
  
  bool get hasNoAttemptsLeft => allowedTimes <= 0;
  
  bool get hasAttemptsLeft => allowedTimes > 0;
  
  String get statusMessage {
    if (!isActivated) return 'Challenge not activated';
    if (!isQualified) return 'Challenge qualification required';
    if (allowedTimes <= 0) return 'Challenge completed';
    return 'Ready to start challenge';
  }
  
  // 显示相关的方法
  String get roundsDisplayText => '$totalRounds rounds';
  
  String get durationDisplayText => '${roundDuration}s per round';
  
  int get totalDurationInSeconds => totalRounds * roundDuration;
  
  String get totalDurationDisplayText {
    final minutes = totalDurationInSeconds ~/ 60;
    final seconds = totalDurationInSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s total';
    }
    return '${seconds}s total';
  }
} 