import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/checkin_api_model.dart';

class CheckinApi {
  final Dio _dio = DioClient().dio;

  /// 获取Checkin产品列表
  Future<CheckinListApiModel> fetchCheckinProducts() async {
    final response = await _dio.get('/api/checkin/products');
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return CheckinListApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch checkin products');
    }
  }

  /// 获取模拟Checkin产品列表（临时使用）
  // Future<CheckinListApiModel> fetchCheckinProducts() async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 500));
    
  //   final mockProducts = [
  //     CheckinProductApiModel(
  //       id: "hiit_pro_001",
  //       name: "HIIT Pro Training",
  //       description: "High-Intensity Interval Training for maximum results",
  //       iconUrl: null,  // 使用随机图标
  //       videoUrl: null, // 使用本地默认视频
  //     ),
  //     CheckinProductApiModel(
  //       id: "yoga_flex_002",
  //       name: "Yoga Flex Training",
  //       description: "Daily Yoga Flexibility and Mindfulness",
  //       iconUrl: null,  // 使用随机图标
  //       videoUrl: null, // 使用本地默认视频
  //     ),
  //     CheckinProductApiModel(
  //       id: "cardio_003",
  //       name: "Cardio Training",
  //       description: "Daily Cardio Workout",
  //       iconUrl: null,  // 使用随机图标
  //       videoUrl: null, // 使用本地默认视频
  //     ),
  //   ];
    
  //   return CheckinListApiModel(products: mockProducts);
  // }
} 