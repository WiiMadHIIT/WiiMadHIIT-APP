import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/usecases/auth/send_login_code_usecase.dart';
import '../../domain/usecases/auth/verify_login_code_usecase.dart';
import '../../domain/usecases/auth/send_register_code_usecase.dart';
import '../../domain/usecases/auth/verify_register_code_usecase.dart';
import '../../domain/entities/auth/auth_entities.dart';
import '../../core/auth/auth_state_manager.dart';

/// 登录/注册 ViewModel
/// - 面向用户的字段/文案保持英文
/// - 内部注释采用中文，便于团队沟通
class LoginViewModel extends ChangeNotifier {
  final AuthService authService;
  final SendLoginCodeUseCase sendLoginCodeUseCase;
  final VerifyLoginCodeUseCase verifyLoginCodeUseCase;
  final SendRegisterCodeUseCase sendRegisterCodeUseCase;
  final VerifyRegisterCodeUseCase verifyRegisterCodeUseCase;
  
  // 认证状态管理器
  final AuthStateManager _authManager = AuthStateManager();

  LoginViewModel({
    required this.authService,
    required this.sendLoginCodeUseCase,
    required this.verifyLoginCodeUseCase,
    required this.sendRegisterCodeUseCase,
    required this.verifyRegisterCodeUseCase,
  });

  // UI 状态（加载/错误）
  bool isLoading = false;
  String? errorMessage;
  String? errorCode; // 添加错误码
  String? userFriendlyMessage; // 添加用户友好错误信息

  // 登录表单
  String email = '';
  String code = '';
  bool get isEmailValid => authService.isValidEmail(email);
  bool get isCodeValid => authService.isValidVerificationCode(code);

  // 注册表单
  String registerEmail = '';
  String registerCode = '';
  String activationCode = '';
  bool get isRegisterEmailValid => authService.isValidEmail(registerEmail);
  bool get isRegisterCodeValid => authService.isValidVerificationCode(registerCode);
  bool get isActivationCodeValid => authService.isValidActivationCode(activationCode);

  // 计时器（验证码重发倒计时）
  Timer? _resendTimer;
  int resendCountdown = 0;
  VerificationCodeInfo? lastVerificationInfo;

  // 登录状态
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setCode(String value) {
    code = value;
    notifyListeners();
  }

  void setRegisterEmail(String value) {
    registerEmail = value;
    notifyListeners();
  }

  void setRegisterCode(String value) {
    registerCode = value;
    notifyListeners();
  }

  void setActivationCode(String value) {
    activationCode = value;
    notifyListeners();
  }

  Future<void> sendLoginCode() async {
    if (!isEmailValid) return;
    _setLoading(true);
    try {
      final info = await sendLoginCodeUseCase.execute(email);
      
      // 检查是否有错误
      if (info.hasError) {
        _setErrorWithCode(
          info.errorMessage ?? 'Failed to send code',
          info.errorCode ?? 'UNKNOWN',
          info.userFriendlyMessage ?? 'Failed to send verification code',
        );
        return;
      }
      
      lastVerificationInfo = info;
      _startResendCountdown(info.resendTime);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyLoginCode() async {
    if (!isEmailValid || !isCodeValid) return false;
    _setLoading(true);
    try {
      final result = await verifyLoginCodeUseCase.execute(email: email, code: code);
      if (result.isSuccess) {
        _isLoggedIn = true;
        _clearError();
        
        // 通知认证状态管理器更新登录状态
        _authManager.setLoginStatus(true);
        
        print('🔐 LoginViewModel: 登录成功，认证状态已更新');
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendRegisterCode() async {
    if (!isRegisterEmailValid) return;
    _setLoading(true);
    try {
      final info = await sendRegisterCodeUseCase.execute(registerEmail);
      
      // 检查是否有错误
      if (info.hasError) {
        _setErrorWithCode(
          info.errorMessage ?? 'Failed to send code',
          info.errorCode ?? 'UNKNOWN',
          info.userFriendlyMessage ?? 'Failed to send verification code',
        );
        return;
      }
      
      lastVerificationInfo = info;
      _startResendCountdown(info.resendTime);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyRegisterCode() async {
    if (!isRegisterEmailValid || !isRegisterCodeValid || !isActivationCodeValid) {
      return false;
    }
    _setLoading(true);
    try {
      final result = await verifyRegisterCodeUseCase.execute(
        email: registerEmail,
        code: registerCode,
        activationCode: activationCode,
      );
      if (result.isSuccess) {
        _clearError();
        return true;
      } else {
        _setError(result.message ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _startResendCountdown(DateTime nextResendTime) {
    _resendTimer?.cancel();
    resendCountdown = authService.remainingSeconds(nextResendTime);
    if (resendCountdown <= 0) {
      notifyListeners();
      return;
    }
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown <= 0) {
        timer.cancel();
      } else {
        resendCountdown -= 1;
      }
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    errorMessage = message;
    errorCode = null;
    userFriendlyMessage = null;
    notifyListeners();
  }

  void _setErrorWithCode(String message, String code, String userFriendly) {
    errorMessage = message;
    errorCode = code;
    userFriendlyMessage = userFriendly;
    notifyListeners();
  }

  void _clearError() {
    errorMessage = null;
    errorCode = null;
    userFriendlyMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}

