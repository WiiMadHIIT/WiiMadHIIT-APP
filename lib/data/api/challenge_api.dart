import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/challenge_api_model.dart';

class ChallengeApi {
  final Dio _dio = DioClient().dio;

  /// 获取挑战列表（支持分页）
  Future<ChallengeListApiModel> fetchChallenges({
    int page = 1,
    int size = 10,
  }) async {
    try {
      print('ChallengeApi: 开始请求 /api/challenge/list?page=$page&size=$size');
      final response = await _dio.get(
        '/api/challenge/list',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      print('ChallengeApi: 请求成功，状态码: ${response.statusCode}');
      print('ChallengeApi: 响应数据: ${response.data}');
      
      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        print('ChallengeApi: 解析响应数据...');
        final result = ChallengeListApiModel.fromJson(response.data['data']);
        print('ChallengeApi: 解析成功，获取到 ${result.challenges.length} 个挑战');
        return result;
      } else {
        print('ChallengeApi: 响应格式错误，状态码: ${response.statusCode}, 响应: ${response.data}');
        throw Exception(response.data['message'] ?? 'Failed to fetch challenges');
      }
    } catch (e) {
      print('ChallengeApi: 请求失败: $e');
      rethrow;
    }
  }

  /// 获取模拟挑战列表（临时使用，用于开发测试）
  Future<ChallengeListApiModel> fetchChallenges_MOCK() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    final mockChallenges = [
      ChallengeApiModel(
        id: "pk1",
        name: "7-Day HIIT Showdown",
        reward: "🏆 \$200 Amazon Gift Card",
        endDate: "2024-01-15T23:59:59Z",
        status: "ongoing",
        videoUrl: "https://example.com/videos/hiit-showdown.mp4",
        description: "Push your limits in this high-intensity interval training battle!",
      ),
      ChallengeApiModel(
        id: "pk2",
        name: "Yoga Masters Cup",
        reward: "🥇 Gold Medal & Exclusive Badge",
        endDate: "2024-01-10T23:59:59Z",
        status: "ended",
        videoUrl: "https://example.com/videos/yoga-masters.mp4",
        description: "Compete for flexibility and balance in the ultimate yoga challenge.",
      ),
      ChallengeApiModel(
        id: "pk3",
        name: "Strength Warriors",
        reward: "💪 Champion Title & Gym Gear",
        endDate: "2024-01-20T23:59:59Z",
        status: "upcoming",
        videoUrl: "https://example.com/videos/strength-warriors.mp4",
        description: "Show your power in this strength training competition.",
      ),
      ChallengeApiModel(
        id: "pk4",
        name: "Endurance Marathon",
        reward: "🏃 \$500 Cash Prize",
        endDate: "2024-01-12T23:59:59Z",
        status: "ongoing",
        videoUrl: "https://example.com/videos/endurance-marathon.mp4",
        description: "Test your stamina in a marathon-style endurance challenge.",
      ),
    ];
    
    return ChallengeListApiModel(
      challenges: mockChallenges,
      total: mockChallenges.length,
      currentPage: 1,
      pageSize: 10,
    );
  }
} 