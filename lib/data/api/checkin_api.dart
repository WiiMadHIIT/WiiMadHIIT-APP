import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/checkin_api_model.dart';

class CheckinApi {
  final Dio _dio = DioClient().dio;

  /// 获取Checkin产品列表（支持分页）
  Future<CheckinListApiModel> fetchCheckinProducts({
    int page = 1,
    int size = 10,
  }) async {
    try {
      print('CheckinApi: 开始请求 /api/checkin/products?page=$page&size=$size');
      final response = await _dio.get(
        '/api/checkin/products',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        print('CheckinApi: 请求成功，数据: ${response.data['data']}');
        return CheckinListApiModel.fromJson(response.data['data']);
      } else {
        print('CheckinApi: 请求失败，状态码: ${response.statusCode}, 消息: ${response.data['message']}');
        throw Exception(response.data['message'] ?? 'Failed to fetch checkin products');
      }
    } catch (e) {
      print('CheckinApi: 请求异常: $e');
      rethrow;
    }
  }

  /// 获取模拟Checkin产品列表（临时使用）
  Future<CheckinListApiModel> fetchCheckinProducts_MOCK() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockProducts = [
      CheckinProductApiModel(
        id: "hiit_pro_001",
        name: "HIIT Pro Training",
        description: "High-Intensity Interval Training for maximum results",
        videoUrl: null, // 使用本地默认视频
      ),
      CheckinProductApiModel(
        id: "yoga_flex_002",
        name: "Yoga Flex Training",
        description: "Daily Yoga Flexibility and Mindfulness",
        videoUrl: null, // 使用本地默认视频
      ),
      CheckinProductApiModel(
        id: "cardio_003",
        name: "Cardio Training",
        description: "Daily Cardio Workout",
        videoUrl: null, // 使用本地默认视频
      ),
    ];
    
    return CheckinListApiModel(
      products: mockProducts,
      total: mockProducts.length,
      currentPage: 1,
      pageSize: 10,
    );
  }
} 