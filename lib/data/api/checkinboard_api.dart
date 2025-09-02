import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/checkinboard_api_model.dart';

class CheckinboardApi {
  late final Dio _dio;
  
  CheckinboardApi() {
    _dio = DioClient().dio;
  }

  Future<CheckinboardPageApiModel> fetchCheckinboards({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      '/api/checkin/checkinboard/list',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return CheckinboardPageApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch checkinboard list');
    }
  }

  Future<CheckinboardRankingsPageApiModel> fetchRankings({
    String? activity,
    String? activityId,
    int page = 1,
    int pageSize = 16,
  }) async {
    final response = await _dio.get(
      '/api/checkin/checkinboard/rankings',
      queryParameters: {
        if (activityId != null) 'activityId': activityId,
        if (activity != null) 'activity': activity,
        'page': page,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return CheckinboardRankingsPageApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch checkinboard rankings');
    }
  }

}
