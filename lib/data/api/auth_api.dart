import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/auth_api_model.dart';
import '../error_management/auth_error_mapper.dart';

class AuthApi {
  final Dio _dio = DioClient().dio;

  /// 发送登录验证码
  Future<VerificationCodeResponseApiModel> sendLoginCode(String email) async {
    final response = await _dio.post(
      '/api/auth/login/send-code',
      queryParameters: {
        'email': email,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 45),  // 邮件发送需要更长时间
        sendTimeout: const Duration(seconds: 20),
      ),
    );
    print('===============sendLoginCode=================');
    print('email: $email');
    print('response: $response');

    if (response.statusCode == 200) {
      final responseData = response.data;
      final businessCode = responseData['code'] as String?;
      
      // 检查业务代码是否成功
      if (businessCode == 'A200') {
        return VerificationCodeResponseApiModel.fromJson(responseData['data']);
      } else {
        // 使用错误映射工具获取错误信息
        final errorInfo = AuthErrorMapper.getSendCodeError(businessCode ?? '');
        final errorMessage = errorInfo['message'] ?? 'Engineers are fixing bugs! 🐛';
        final userFriendlyMessage = errorInfo['userFriendly'] ?? 'Server is having a coffee break! ☕ Try again later';
        
        print('Error Code: $businessCode');
        print('Error Message: $errorMessage');
        print('User Friendly Message: $userFriendlyMessage');
        
        throw AuthApiException(
          code: businessCode ?? 'UNKNOWN',
          message: errorMessage,
          userFriendlyMessage: userFriendlyMessage,
        );
      }
    } else {
      throw Exception(response.data['message'] ?? 'Failed to send login code');
    }
  }

  /// 验证登录验证码并完成登录
  Future<LoginVerifyResponseApiModel> verifyLoginCode(
    String email,
    String code,
  ) async {
    final response = await _dio.post(
      '/api/auth/login/verify-code',
      data: {
        'email': email,
        'code': code,
      },
    );
    print('===============verifyLoginCode=================');
    print('email: $email');
    print('code: $code');
    print('response: $response');

    if (response.statusCode == 200) {
      final responseData = response.data;
      final businessCode = responseData['code'] as String?;
      
      // 检查业务代码是否成功
      if (businessCode == 'A200') {
        return LoginVerifyResponseApiModel.fromJson(responseData['data']);
      } else {
        // 使用错误映射工具获取错误信息
        final errorInfo = AuthErrorMapper.getVerifyLoginError(businessCode ?? '');
        final errorMessage = errorInfo['message'] ?? 'Login failed';
        final userFriendlyMessage = errorInfo['userFriendly'] ?? 'Not registered yet? Create an account first! 🚀';
        throw AuthApiException(
          code: businessCode ?? 'UNKNOWN',
          message: errorMessage,
          userFriendlyMessage: userFriendlyMessage,
        );
      }
    } else {
      throw Exception(response.data['message'] ?? 'Failed to verify login code');
    }
  }

  /// 发送注册邮箱验证码
  Future<VerificationCodeResponseApiModel> sendRegisterCode(String email) async {
    final response = await _dio.post(
      '/api/auth/register/send-code',
      queryParameters: {
        'email': email,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 45),  // 邮件发送需要更长时间
        sendTimeout: const Duration(seconds: 20),
      ),
    );

    print('===============sendRegisterCode=================');
    print('email: $email');
    print('response: $response');

    if (response.statusCode == 200) {
      final responseData = response.data;
      final businessCode = responseData['code'] as String?;
      
      // 检查业务代码是否成功
      if (businessCode == 'A200') {
        return VerificationCodeResponseApiModel.fromJson(responseData['data']);
      } else {
        // 使用错误映射工具获取错误信息
        final errorInfo = AuthErrorMapper.getSendCodeError(businessCode ?? '');
        final errorMessage = errorInfo['message'] ?? 'Engineers are fixing bugs! 🐛';
        final userFriendlyMessage = errorInfo['userFriendly'] ?? 'Server is having a coffee break! ☕ Try again later';
        throw AuthApiException(
          code: businessCode ?? 'UNKNOWN',
          message: errorMessage,
          userFriendlyMessage: userFriendlyMessage,
        );
      }
    } else {
      throw Exception(response.data['message'] ?? 'Failed to send register code');
    }
  }

  /// 验证注册邮箱验证码
  Future<RegisterVerifyResponseApiModel> verifyRegisterCode({
    required String email,
    required String code,
    required String activationCode,
  }) async {
    final response = await _dio.post(
      '/api/auth/register/verify-code',
      data: {
        'email': email,
        'code': code,
        'activationCode': activationCode,
      },
    );

    print('===============verifyRegisterCode=================');
    print('email: $email');
    print('code: $code');
    print('activationCode: $activationCode');
    print('response: $response');

    if (response.statusCode == 200) {
      final responseData = response.data;
      final businessCode = responseData['code'] as String?;
      
      // 检查业务代码是否成功
      if (businessCode == 'A200') {
        return RegisterVerifyResponseApiModel.fromJson(responseData['data']);
      } else {
        // 使用错误映射工具获取错误信息
        final errorInfo = AuthErrorMapper.getVerifyRegisterError(businessCode ?? '');
        final errorMessage = errorInfo['message'] ?? 'Registration failed';
        final userFriendlyMessage = errorInfo['userFriendly'] ?? 'Already have an account? Try logging in instead! 🚀';
        throw AuthApiException(
          code: businessCode ?? 'UNKNOWN',
          message: errorMessage,
          userFriendlyMessage: userFriendlyMessage,
        );
      }
    } else {
      throw Exception(response.data['message'] ?? 'Failed to verify register code');
    }
  }
}

/// 认证API异常类
/// 包含业务错误码、详细错误信息和用户友好错误信息
class AuthApiException implements Exception {
  final String code;
  final String message;
  final String userFriendlyMessage;

  AuthApiException({
    required this.code,
    required this.message,
    required this.userFriendlyMessage,
  });

  @override
  String toString() => 'AuthApiException(code: $code, message: $message, userFriendlyMessage: $userFriendlyMessage)';
}


