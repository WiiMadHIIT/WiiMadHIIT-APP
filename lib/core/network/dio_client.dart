import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Token相关常量
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),  // 连接超时：15秒
      receiveTimeout: const Duration(seconds: 30),  // 接收超时：30秒（邮件发送需要更长时间）
      sendTimeout: const Duration(seconds: 15),     // 发送超时：15秒
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }

  /// 设置拦截器
  void _setupInterceptors() {
    // Token注入拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 自动注入token到所有请求
          final token = await _getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Token过期处理
          print('======过期处理=======================================================');
          print('DIO: ${error.response?.statusCode}');
          print('DIO: ${error.response?.data}');
          if (error.response?.statusCode == 403) {
            final refreshed = await _handleTokenExpired();
            if (refreshed) {
              // 重新发起原请求
              final token = await _getAccessToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );

    // 日志拦截器（开发环境）
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('DIO: $obj'),
      ));
    }
  }

  /// 获取访问令牌
  Future<String?> _getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// 获取刷新令牌
  Future<String?> _getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 处理Token过期
  Future<bool> _handleTokenExpired() async {
    try {
      final refreshToken = await _getRefreshToken();
      print('======refreshToken=======================================================');
      print('DIO: $refreshToken');
      if (refreshToken == null) return false;

      // 调用刷新token接口
      final response = await dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        final data = response.data['data'];
        await _saveTokens(
          accessToken: data['token'],
          refreshToken: data['refreshToken'],
          expiresIn: data['expiresIn'],
          issuedAt: data['issuedAt'],
        );
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
      // 刷新失败，清除所有token
      await _clearTokens();
    }
    return false;
  }

  /// 保存Token信息
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required int issuedAt,
  }) async {
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(issuedAt)
        .add(Duration(milliseconds: expiresIn));
    
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _tokenExpiryKey, value: expiryTime.millisecondsSinceEpoch.toString());
  }

  /// 清除Token信息
  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
  }

  /// 检查Token是否过期
  Future<bool> isTokenExpired() async {
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryStr == null) return true;
    
    try {
      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  /// 手动设置Token（登录成功后调用）
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required int issuedAt,
  }) async {
    await _saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      issuedAt: issuedAt,
    );
  }

  /// 手动清除Token（登出时调用）
  Future<void> clearTokens() async {
    await _clearTokens();
  }

  /// 获取当前Token状态
  Future<Map<String, dynamic>> getTokenStatus() async {
    final accessToken = await _getAccessToken();
    final refreshToken = await _getRefreshToken();
    final isExpired = await isTokenExpired();
    
    return {
      'hasAccessToken': accessToken != null && accessToken.isNotEmpty,
      'hasRefreshToken': refreshToken != null && refreshToken.isNotEmpty,
      'isExpired': isExpired,
    };
  }
}