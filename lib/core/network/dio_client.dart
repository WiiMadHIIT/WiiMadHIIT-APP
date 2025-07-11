import 'package:dio/dio.dart';

import '../config/app_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl, // 统一配置
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      // 可加 headers、拦截器等
    ));
    // 可加拦截器、日志、token等
  }
}