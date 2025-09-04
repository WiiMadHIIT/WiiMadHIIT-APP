/// AppConfig - 大厂级多环境配置
/// 支持通过 --dart-define=API_BASE_URL=xxx 切换环境，默认本地开发环境
class AppConfig {
  /// 后端 API 基础地址
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://170.106.73.145',
    // defaultValue: 'http://192.168.1.166:8080', // 本地/临时开放环境
  );

  /// 其他可扩展配置（如超时时间、环境名等）
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
  // static const String env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
}