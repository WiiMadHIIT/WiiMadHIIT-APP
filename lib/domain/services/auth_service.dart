class AuthService {
  /// 简单邮箱校验（可在上层用更严格校验替换）
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
    return emailRegex.hasMatch(email.trim());
  }

  /// 验证码校验：默认必须为6位数字
  bool isValidVerificationCode(String code, {int length = 6}) {
    final normalized = code.trim();
    if (normalized.length != length) return false;
    return RegExp(r'^\d+$').hasMatch(normalized);
  }

  /// 激活码校验：默认长度≥6 即可
  bool isValidActivationCode(String activationCode) {
    final normalized = activationCode.trim();
    return normalized.length >= 6;
  }

  /// 计算倒计时秒数
  int remainingSeconds(DateTime targetTime) {
    final diff = targetTime.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }
}


