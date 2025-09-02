import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/leaderboard_api_model.dart';

class LeaderboardApi {
  final Dio _dio = DioClient().dio;

  Future<LeaderboardListPageApiModel> fetchLeaderboards({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/api/challenge/leaderboard/list',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return LeaderboardListPageApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch leaderboards');
    }
  }

  Future<LeaderboardRankingsPageApiModel> fetchRankings({
    required String challengeId,
    int page = 1,
    int pageSize = 16,
  }) async {
    final response = await _dio.get(
      '/api/challenge/leaderboard/rankings',
      queryParameters: {
        'challengeId': challengeId,
        'page': page,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return LeaderboardRankingsPageApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch rankings');
    }
  }
}


