class Profile {
  final String userId;
  final String username;
  final String email;

  Profile({
    required this.userId,
    required this.username,
    required this.email,
  });

  // 业务规则示例
  bool get isEmailValid => email.contains('@');
  bool get isComplete => username.isNotEmpty && isEmailValid;
}