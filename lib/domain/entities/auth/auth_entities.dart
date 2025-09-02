/// 验证码信息实体
/// - 字段英文，便于跨端一致；注释中文，便于团队沟通
class VerificationCodeInfo {
  final String email;
  final DateTime expireTime;
  final DateTime resendTime;
  final String? errorCode; // 错误码
  final String? errorMessage; // 错误信息
  final String? userFriendlyMessage; // 用户友好错误信息

  VerificationCodeInfo({
    required this.email,
    required this.expireTime,
    required this.resendTime,
    this.errorCode,
    this.errorMessage,
    this.userFriendlyMessage,
  });

  /// 剩余有效期
  Duration get remainingDuration => expireTime.difference(DateTime.now());
  /// 距离可重发时间
  Duration get resendAfter => resendTime.difference(DateTime.now());
  /// 是否可重发
  bool get canResend => DateTime.now().isAfter(resendTime);
  /// 是否有错误
  bool get hasError => errorCode != null && errorCode != 'A200';
}

/// 登录结果实体
/// 注意：所有token管理由DioClient自动处理，业务层无需关心
/// 业务层只需要知道登录是否成功
class LoginResult {
  final bool isSuccess;
  final String? message; // 可选的错误信息

  LoginResult({
    required this.isSuccess,
    this.message,
  });

  /// 登录成功
  factory LoginResult.success() => LoginResult(isSuccess: true);
  
  /// 登录失败
  factory LoginResult.failure(String message) => LoginResult(
    isSuccess: false, 
    message: message,
  );
}

/// 注册结果实体
class RegisterResult {
  final bool isSuccess;
  final String? message;

  RegisterResult({
    required this.isSuccess,
    this.message,
  });

  /// 注册成功
  factory RegisterResult.success() => RegisterResult(isSuccess: true);
  
  /// 注册失败
  factory RegisterResult.failure(String message) => RegisterResult(
    isSuccess: false, 
    message: message,
  );
}


