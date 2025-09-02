import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/bonus_api_model.dart';

class BonusApi {
  final Dio _dio = DioClient().dio;

  /// 获取奖励活动列表（支持分页）
  Future<BonusListApiModel> fetchBonusActivities({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/bonus/activities',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        return BonusListApiModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch bonus activities');
      }
    } catch (e) {
      // 如果网络请求失败，重新抛出异常
      rethrow;
    }
  }


} 