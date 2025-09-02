import 'package:flutter/material.dart';
import 'auth_state_manager.dart';

/// 认证保护装饰器（简化版）
/// 大厂级别：简化逻辑，认证检查统一由 AuthGuardMixin 处理
class AuthGuard {
  /// 检查当前用户是否已登录
  static Future<bool> isLoggedIn() async {
    final authManager = AuthStateManager();
    if (!authManager.isInitialized) {
      await authManager.initialize();
    }
    return await authManager.checkLoginStatus();
  }

  /// 获取认证状态管理器
  static AuthStateManager get authManager => AuthStateManager();
}
