import '../api/auth_api.dart';
import '../models/auth_api_model.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/auth/auth_entities.dart';

class AuthRepository {
  final AuthApi _api;
  final DioClient _dioClient = DioClient();

  AuthRepository(this._api);

  Future<VerificationCodeInfo> sendLoginCode(String email) async {
    try {
      final VerificationCodeResponseApiModel apiModel = await _api.sendLoginCode(email);
      return VerificationCodeInfo(
        email: apiModel.email,
        expireTime: DateTime.fromMillisecondsSinceEpoch(apiModel.expireTime),
        resendTime: DateTime.fromMillisecondsSinceEpoch(apiModel.resendTime),
      );
    } on AuthApiException catch (e) {
      // 处理业务错误，返回包含错误信息的验证码信息
      return VerificationCodeInfo(
        email: email,
        expireTime: DateTime.now().add(const Duration(minutes: 5)), // 默认5分钟
        resendTime: DateTime.now().add(const Duration(minutes: 1)), // 默认1分钟后可重发
        errorCode: e.code,
        errorMessage: e.message,
        userFriendlyMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      // 处理其他异常，返回包含错误信息的验证码信息
      return VerificationCodeInfo(
        email: email,
        expireTime: DateTime.now().add(const Duration(minutes: 5)), // 默认5分钟
        resendTime: DateTime.now().add(const Duration(minutes: 1)), // 默认1分钟后可重发
        errorCode: 'UNKNOWN',
        errorMessage: e.toString(),
        userFriendlyMessage: 'Engineers are fixing bugs! 🐛',
      );
    }
  }

  Future<LoginResult> verifyLoginCode(String email, String code) async {
    try {
      final LoginVerifyResponseApiModel apiModel = await _api.verifyLoginCode(email, code);
      
      // 登录成功后，自动保存完整token信息到DioClient
      // 注意：业务层不需要关心token细节，由DioClient自动管理
      await _dioClient.setTokens(
        accessToken: apiModel.token,
        refreshToken: apiModel.refreshToken,
        expiresIn: apiModel.expiresIn,
        issuedAt: apiModel.issuedAt,
      );
      
      // 业务层只关心登录是否成功，不关心token细节
      return LoginResult.success();
    } on AuthApiException catch (e) {
      // 处理业务错误
      return LoginResult.failure(e.userFriendlyMessage);
    } catch (e) {
      return LoginResult.failure('Not registered yet? Create an account first! 🚀');
    }
  }

  Future<VerificationCodeInfo> sendRegisterCode(String email) async {
    try {
      final VerificationCodeResponseApiModel apiModel = await _api.sendRegisterCode(email);
      return VerificationCodeInfo(
        email: apiModel.email,
        expireTime: DateTime.fromMillisecondsSinceEpoch(apiModel.expireTime),
        resendTime: DateTime.fromMillisecondsSinceEpoch(apiModel.resendTime),
      );
    } on AuthApiException catch (e) {
      // 处理业务错误，返回包含错误信息的验证码信息
      return VerificationCodeInfo(
        email: email,
        expireTime: DateTime.now().add(const Duration(minutes: 5)), // 默认5分钟
        resendTime: DateTime.now().add(const Duration(minutes: 1)), // 默认1分钟后可重发
        errorCode: e.code,
        errorMessage: e.message,
        userFriendlyMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      // 处理其他异常，返回包含错误信息的验证码信息
      return VerificationCodeInfo(
        email: email,
        expireTime: DateTime.now().add(const Duration(minutes: 5)), // 默认5分钟
        resendTime: DateTime.now().add(const Duration(minutes: 1)), // 默认1分钟后可重发
        errorCode: 'UNKNOWN',
        errorMessage: e.toString(),
        userFriendlyMessage: 'Engineers are fixing bugs! 🐛',
      );
    }
  }

  Future<RegisterResult> verifyRegisterCode({
    required String email,
    required String code,
    required String activationCode,
  }) async {
    try {
      final RegisterVerifyResponseApiModel apiModel = await _api.verifyRegisterCode(
        email: email,
        code: code,
        activationCode: activationCode,
      );
      
      // 根据后端返回的status判断是否成功
      if (apiModel.status.toLowerCase() == 'success') {
        return RegisterResult.success();
      } else {
        return RegisterResult.failure('Registration failed: ${apiModel.status}');
      }
    } on AuthApiException catch (e) {
      // 处理业务错误
      return RegisterResult.failure(e.userFriendlyMessage);
    } catch (e) {
      return RegisterResult.failure('Already have an account? Try logging in instead! 🚀');
    }
  }

  /// 登出
  Future<void> logout() async {
    await _dioClient.clearTokens();
  }

  /// 检查登录状态
  Future<bool> isLoggedIn() async {
    final status = await _dioClient.getTokenStatus();
    return status['hasAccessToken'] == true && status['isExpired'] == false;
  }

  /// 获取当前token状态
  Future<Map<String, dynamic>> getTokenStatus() async {
    return await _dioClient.getTokenStatus();
  }
}

/// 认证仓库异常类
/// 包含业务错误码、详细错误信息和用户友好错误信息
class AuthRepositoryException implements Exception {
  final String code;
  final String message;
  final String userFriendlyMessage;

  AuthRepositoryException({
    required this.code,
    required this.message,
    required this.userFriendlyMessage,
  });

  @override
  String toString() => 'AuthRepositoryException(code: $code, message: $message, userFriendlyMessage: $userFriendlyMessage)';
}

