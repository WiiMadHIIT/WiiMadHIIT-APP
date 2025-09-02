import '../../core/network/dio_client.dart';

/// Token管理服务
/// 提供统一的token管理接口，包括存储、获取、清除等操作
/// 注意：token刷新由DioClient自动处理，无需手动干预
class TokenManagerService {
  final DioClient _dioClient = DioClient();

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final status = await _dioClient.getTokenStatus();
    return status['hasAccessToken'] == true && status['isExpired'] == false;
  }

  /// 检查token是否即将过期（提前5分钟）
  Future<bool> isTokenExpiringSoon() async {
    final status = await _dioClient.getTokenStatus();
    if (status['hasAccessToken'] != true) return false;
    
    // 这里可以添加更精确的过期时间检查逻辑
    return status['isExpired'] == true;
  }

  /// 获取当前token状态
  Future<Map<String, dynamic>> getTokenStatus() async {
    return await _dioClient.getTokenStatus();
  }

  /// 手动设置token（用于测试或特殊情况）
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required int issuedAt,
  }) async {
    await _dioClient.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      issuedAt: issuedAt,
    );
  }

  /// 清除所有token（登出时使用）
  Future<void> clearTokens() async {
    await _dioClient.clearTokens();
  }

  /// 获取token过期时间
  Future<DateTime?> getTokenExpiryTime() async {
    final status = await _dioClient.getTokenStatus();
    if (status['hasAccessToken'] != true) return null;
    
    // 这里可以添加更精确的过期时间计算逻辑
    return null;
  }
}
