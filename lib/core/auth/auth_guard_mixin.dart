import 'package:flutter/material.dart';
import 'auth_state_manager.dart';

/// 路由保护混入
/// 为需要认证的页面提供统一的认证检查功能
/// 大厂级别：可复用的认证逻辑，支持Tab和非Tab页面
mixin AuthGuardMixin<T extends StatefulWidget> on State<T> {
  late final AuthStateManager _authManager = AuthStateManager();
  bool _isAuthChecked = false;

  @override
  void initState() {
    super.initState();
    _checkAuthOnInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次依赖变化时检查认证状态
    if (!_isAuthChecked) {
      _checkAuthOnInit();
    }
  }

  /// 初始化时检查认证状态
  Future<void> _checkAuthOnInit() async {
    if (_isAuthChecked) return;
    
    try {
      // 大厂级别：等待认证状态管理器初始化
      if (!_authManager.isInitialized) {
        await _authManager.initialize();
      }
      
      // 获取当前路由路径
      final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
      
      // 大厂级别：检查页面认证状态
      final isAuthenticated = await _authManager.checkPageAuth(currentRoute);
      
      if (!isAuthenticated) {
        // 未认证，处理认证失败
        print('🔐 AuthGuardMixin: 页面 $currentRoute 认证失败，跳转登录页面');
        _handleUnauthenticated(currentRoute);
      } else {
        // 已认证，页面继续显示，无需特殊处理
        print('🔐 AuthGuardMixin: 页面 $currentRoute 认证成功，继续显示');
      }
      
      _isAuthChecked = true;
    } catch (e) {
      print('🔐 AuthGuardMixin: 认证检查失败: $e');
      // 大厂级别：认证错误时显示用户友好的提示，不暴露技术细节
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🔐 Authentication service is taking a coffee break! ☕'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 处理未认证状态
  void _handleUnauthenticated(String routePath) {
    // 大厂级别：简化逻辑，不再需要重定向路径
    print('🔐 AuthGuardMixin: 页面 $routePath 未认证，跳转登录页面');
    
    // 跳转到登录页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 大厂级别：直接跳转登录页面，登录成功后会自动返回上一页
        Navigator.of(context).pushNamed(_authManager.getLoginRoute());
        
        // 可选：显示友好的提示信息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔐 Please log in to access this page'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  /// 获取认证状态管理器（供子类使用）
  AuthStateManager get authManager => _authManager;

}
