class TrainingConfig {
  final String nextPageRoute;
  final bool isActivated;

  TrainingConfig({
    required this.nextPageRoute,
    required this.isActivated,
  });

  // 业务逻辑方法
  bool get isValid => nextPageRoute.isNotEmpty;
  
  String get displayRoute => nextPageRoute.trim();
  
  // 激活状态相关方法
  bool get canStartTraining => isActivated && isValid;
  
  String get activationStatusText {
    if (!isActivated) {
      return 'Training not activated';
    }
    return 'Training ready';
  }
  
  bool get isCountdownRoute => nextPageRoute == '/checkin_countdown';
  
  bool get isVoiceTrainingRoute => nextPageRoute == '/checkin_training_voice';
  
  bool get isDirectTrainingRoute => nextPageRoute == '/checkin_training';
  
  bool get requiresCountdown => isCountdownRoute;
  
  bool get requiresVoice => isVoiceTrainingRoute;
  
  bool get isDirectStart => isDirectTrainingRoute;
  
  // 获取路由名称（用于日志和调试）
  String get routeName {
    switch (nextPageRoute) {
      case '/checkin_countdown':
        return 'Countdown';
      case '/checkin_training_voice':
        return 'Voice Training';
      case '/checkin_training':
        return 'Direct Training';
      default:
        return 'Unknown';
    }
  }
  
  // 验证路由是否有效
  bool get isRouteValid {
    final validRoutes = [
      '/checkin_countdown',
      '/checkin_training_voice',
      '/checkin_training',
    ];
    return validRoutes.contains(nextPageRoute);
  }
} 