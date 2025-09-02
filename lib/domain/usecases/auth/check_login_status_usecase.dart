import '../../../data/repository/auth_repository.dart';

/// 检查登录状态用例
/// 提供统一的登录状态检查逻辑
class CheckLoginStatusUseCase {
  /// 认证仓库
  final AuthRepository repository;

  CheckLoginStatusUseCase(this.repository);

  /// 执行登录状态检查
  Future<bool> execute() async {
    try {
      return await repository.isLoggedIn();
    } catch (e) {
      print('Check login status failed: $e');
      return false;
    }
  }

  /// 获取详细的token状态信息
  Future<Map<String, dynamic>> getDetailedStatus() async {
    try {
      return await repository.getTokenStatus();
    } catch (e) {
      print('Get detailed token status failed: $e');
      return {
        'hasAccessToken': false,
        'hasRefreshToken': false,
        'isExpired': true,
      };
    }
  }
}
