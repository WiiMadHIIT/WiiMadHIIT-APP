import '../../../data/repository/auth_repository.dart';

/// 登出用例
/// 提供统一的登出逻辑，包括清除token、清理缓存等
class LogoutUseCase {
  /// 认证仓库
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// 执行登出
  Future<void> execute() async {
    try {
      // 清除所有token
      await repository.logout();
      
      // 这里可以添加其他清理逻辑，比如：
      // - 清除用户信息缓存
      // - 清除应用状态
      // - 发送登出事件
      // - 清理本地存储等
      
    } catch (e) {
      print('Logout failed: $e');
      // 即使出错，也要尝试清除token
      await repository.logout();
      rethrow;
    }
  }
}
