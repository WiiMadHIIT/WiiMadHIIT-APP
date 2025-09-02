import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/services/token_manager_service.dart';
import '../../routes/app_routes.dart';

/// 统一认证状态管理器
/// 提供统一的登录状态管理和路由保护功能
/// 大厂级别：单例模式，全局状态管理，支持Tab和非Tab页面
class AuthStateManager extends ChangeNotifier {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal();

  final TokenManagerService _tokenManager = TokenManagerService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // 认证状态
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  /// 初始化认证状态管理器
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 检查本地存储的token状态
      final tokenStatus = await _tokenManager.getTokenStatus();
      _isLoggedIn = tokenStatus['hasAccessToken'] == true && tokenStatus['isExpired'] == false;
      
      _isInitialized = true;
      notifyListeners();
      
      print('🔐 AuthStateManager: 初始化完成，登录状态: $_isLoggedIn');
    } catch (e) {
      print('🔐 AuthStateManager: 初始化失败: $e');
      _isLoggedIn = false;
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// 检查登录状态（实时检查）
  Future<bool> checkLoginStatus() async {
    try {
      final tokenStatus = await _tokenManager.getTokenStatus();
      final newLoginStatus = tokenStatus['hasAccessToken'] == true && tokenStatus['isExpired'] == false;
      
      if (_isLoggedIn != newLoginStatus) {
        _isLoggedIn = newLoginStatus;
        notifyListeners();
        print('🔐 AuthStateManager: 登录状态变化: $_isLoggedIn');
      }
      
      return _isLoggedIn;
    } catch (e) {
      print('🔐 AuthStateManager: 检查登录状态失败: $e');
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  /// 设置登录状态
  void setLoginStatus(bool isLoggedIn) {
    if (_isLoggedIn != isLoggedIn) {
      _isLoggedIn = isLoggedIn;
      notifyListeners();
      print('🔐 AuthStateManager: 设置登录状态: $_isLoggedIn');
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _tokenManager.clearTokens();
      _isLoggedIn = false;
      notifyListeners();
      print('🔐 AuthStateManager: 登出成功');
    } catch (e) {
      print('🔐 AuthStateManager: 登出失败: $e');
    }
  }

  /// ====== 通用认证方法 ======

  /// 检查是否需要认证
  bool requiresAuth(String routePath) {
    // 大厂级别：定义需要认证的路径
    final protectedPaths = [
      // 用户相关页面 - 需要认证
      AppRoutes.profile,             // 个人资料页面
      
      // 挑战相关页面 - 需要认证
      AppRoutes.challengeRule,       // 挑战规则页面
      AppRoutes.challengeGame,       // 挑战游戏页面
      
      // 训练相关页面 - 需要认证
      AppRoutes.trainingRule,        // 训练规则页面
      AppRoutes.checkinCountdown,    // 倒计时训练页面
      AppRoutes.checkinTraining,     // 签到训练页面
      AppRoutes.checkinTrainingVoice, // 语音训练页面
    ];
    
    // 大厂级别：这些页面必须认证
    return protectedPaths.contains(routePath);
  }

  /// 获取登录页面路径
  String getLoginRoute() {
    // 大厂级别：使用arguments而不是URL参数，避免路由解析问题
    return AppRoutes.login;
  }

  /// 获取登录页面参数（简化后不再需要重定向参数）
  Map<String, dynamic>? getLoginArguments() {
    // 大厂级别：简化后不再需要重定向参数
    return null;
  }

  /// 检查页面认证状态（通用方法）
  Future<bool> checkPageAuth(String routePath) async {
    // 大厂级别：如果不需要认证，直接返回true
    if (!requiresAuth(routePath)) {
      return true;
    }

    // 大厂级别：需要认证的页面，检查登录状态
    final isLoggedIn = await checkLoginStatus();
    
    if (!isLoggedIn) {
      print('🔐 AuthStateManager: 页面 $routePath 需要认证，但用户未登录');
    } else {
      print('🔐 AuthStateManager: 页面 $routePath 认证通过');
    }
    
    return isLoggedIn;
  }

  /// 处理页面认证失败（通用方法）
  Future<void> handlePageAuthFailure(BuildContext context, String routePath) async {
    // 大厂级别：简化逻辑，直接跳转登录页面
    await Navigator.of(context).pushNamed(getLoginRoute());
  }

  /// 处理登录成功后的页面跳转
  Future<void> handleLoginSuccess(BuildContext context) async {
    // 大厂级别：智能返回，确保回到触发登录的页面
    final navigator = Navigator.of(context);
    
    print('🔐 AuthStateManager: 登录成功，开始智能返回');
    
    // 检查导航栈状态
    if (navigator.canPop()) {
      // 第一次pop：离开登录页面
      print('🔐 AuthStateManager: 第一次pop：离开登录页面');
      navigator.pop();
      
      // 继续检查并返回，直到回到目标页面
      _continuePoppingUntilTargetPage(navigator);
    } else {
      // 没有上一页，跳转主页
      print('🔐 AuthStateManager: 没有上一页，跳转主页');
      navigator.pushReplacementNamed('/');
    }
    
    print('🔐 AuthStateManager: 登录成功处理完成');
  }
  
  /// 继续执行pop操作，直到回到目标页面
  void _continuePoppingUntilTargetPage(NavigatorState navigator) {
    while (navigator.canPop()) {
      // 获取当前页面的路由名称
      final currentRoute = ModalRoute.of(navigator.context)?.settings.name;
      print('🔐 AuthStateManager: 当前页面路由: $currentRoute');
      
      if (currentRoute == AppRoutes.login) {
        // 如果当前页面是登录页面，需要继续返回两次
        print('🔐 AuthStateManager: 仍在登录页面，需要继续返回两次');
        
        // 第二次pop：离开第二个登录页面
        if (navigator.canPop()) {
          navigator.pop();
          print('🔐 AuthStateManager: 第二次pop：离开第二个登录页面');
        } else {
          print('🔐 AuthStateManager: 无法继续返回，跳转主页');
          navigator.pushReplacementNamed('/');
          return;
        }
        
        // 第三次pop：回到触发登录的页面
        if (navigator.canPop()) {
          navigator.pop();
          print('🔐 AuthStateManager: 第三次pop：回到触发登录的页面');
        } else {
          print('🔐 AuthStateManager: 无法回到触发页面，跳转主页');
          navigator.pushReplacementNamed('/');
          return;
        }
      } else {
        // 如果当前页面不是登录页面，只需要返回一次
        print('🔐 AuthStateManager: 当前页面不是登录页面，返回一次');
        navigator.pop();
        print('🔐 AuthStateManager: 返回完成，已回到目标页面');
        return;
      }
    }
    
    // 如果无法继续返回，跳转主页
    print('🔐 AuthStateManager: 无法继续返回，跳转主页');
    navigator.pushReplacementNamed('/');
  }
}
