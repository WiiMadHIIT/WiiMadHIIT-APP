import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/bonus_api_model.dart';

class BonusApi {
  final Dio _dio = DioClient().dio;

  /// 获取奖励活动列表
  Future<BonusListApiModel> fetchBonusActivities_REAL() async {
    final response = await _dio.get('/api/bonus/activities');
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return BonusListApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch bonus activities');
    }
  }

  /// 领取奖励
  Future<Map<String, dynamic>> claimBonus(String activityId) async {
    final response = await _dio.post('/api/bonus/claim', data: {
      'activityId': activityId,
    });
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Failed to claim bonus');
    }
  }

  /// 获取单个奖励活动详情
  Future<BonusApiModel> fetchBonusActivity(String activityId) async {
    final response = await _dio.get('/api/bonus/activity/$activityId');
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return BonusApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch bonus activity');
    }
  }

  /// 获取模拟奖励活动列表（临时使用）
  /// 参考 BonusServiceImpl.java 中的 createMockActivities
  Future<BonusListApiModel> fetchBonusActivities() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockActivities = [
      BonusApiModel(
        id: "bonus_001",
        name: "Spring Challenge 01",
        description: "Join the spring fitness challenge and win big! Complete daily workouts to unlock exclusive rewards and boost your fitness journey.",
        reward: "Up to 1000 WiiCoins + Exclusive Badge",
        regionLimit: "US, Canada, UK",
        videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video1.mp4",
        thumbnailUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/player_cover.png",
        status: "ACTIVE",
        startDate: "2024-03-01T00:00:00Z",
        endDate: "2024-06-01T00:00:00Z",
        isClaimed: false,
        isEligible: true,
        claimCount: 1250,
        maxClaimCount: 10000,
        category: "CHALLENGE",
        difficulty: "MEDIUM",
      ),
      BonusApiModel(
        id: "bonus_002",
        name: "Yoga Marathon 02",
        description: "Complete 30 days of yoga for a special bonus. Build strength, flexibility, and inner peace with our guided yoga sessions.",
        reward: "500 WiiCoins + Yoga Mat",
        regionLimit: "Global",
        videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video2.mp4",
        thumbnailUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/player_cover.png",
        status: "ACTIVE",
        startDate: "2024-02-15T00:00:00Z",
        endDate: "2024-05-15T00:00:00Z",
        isClaimed: false,
        isEligible: true,
        claimCount: 890,
        maxClaimCount: 5000,
        category: "MARATHON",
        difficulty: "EASY",
      ),
      BonusApiModel(
        id: "bonus_003",
        name: "HIIT Pro Bonus 03",
        description: "Push your HIIT limits and unlock rewards. High-intensity interval training for maximum calorie burn and fitness gains.",
        reward: "700 WiiCoins + Pro T-shirt",
        regionLimit: "US Only",
        videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video3.mp4",
        thumbnailUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/player_cover.png",
        status: "ACTIVE",
        startDate: "2024-03-15T00:00:00Z",
        endDate: "2024-06-15T00:00:00Z",
        isClaimed: false,
        isEligible: true,
        claimCount: 650,
        maxClaimCount: 3000,
        category: "CHALLENGE",
        difficulty: "HARD",
      ),
    ];
    
    return BonusListApiModel(activities: mockActivities);
  }

  /// 模拟领取奖励（临时使用）
  Future<Map<String, dynamic>> claimMockBonus(String activityId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 模拟领取奖励的逻辑
    final result = <String, dynamic>{
      "activityId": activityId,
      "claimed": true,
      "claimedAt": DateTime.now().toIso8601String(),
      "message": "Bonus claimed successfully!",
    };
    
    return result;
  }

  /// 模拟获取单个奖励活动详情（临时使用）
  Future<BonusApiModel> fetchMockBonusActivity(String activityId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 根据activityId返回对应的活动详情
    switch (activityId) {
      case "bonus_001":
        return BonusApiModel(
          id: "bonus_001",
          name: "Spring Challenge 01",
          description: "Join the spring fitness challenge and win big! Complete daily workouts to unlock exclusive rewards and boost your fitness journey.",
          reward: "Up to 1000 WiiCoins + Exclusive Badge",
          regionLimit: "US, Canada, UK",
          videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video1.mp4",
          thumbnailUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/player_cover.png",
          status: "ACTIVE",
          startDate: "2024-03-01T00:00:00Z",
          endDate: "2024-06-01T00:00:00Z",
          isClaimed: false,
          isEligible: true,
          claimCount: 1250,
          maxClaimCount: 10000,
          category: "CHALLENGE",
          difficulty: "MEDIUM",
        );
      case "bonus_002":
        return BonusApiModel(
          id: "bonus_002",
          name: "Yoga Marathon 02",
          description: "Complete 30 days of yoga for a special bonus. Build strength, flexibility, and inner peace with our guided yoga sessions.",
          reward: "500 WiiCoins + Yoga Mat",
          regionLimit: "Global",
          videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video2.mp4",
          thumbnailUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/player_cover.png",
          status: "ACTIVE",
          startDate: "2024-02-15T00:00:00Z",
          endDate: "2024-05-15T00:00:00Z",
          isClaimed: false,
          isEligible: true,
          claimCount: 890,
          maxClaimCount: 5000,
          category: "MARATHON",
          difficulty: "EASY",
        );
      case "bonus_003":
        return BonusApiModel(
          id: "bonus_003",
          name: "HIIT Pro Bonus 03",
          description: "Push your HIIT limits and unlock rewards. High-intensity interval training for maximum calorie burn and fitness gains.",
          reward: "700 WiiCoins + Pro T-shirt",
          regionLimit: "US Only",
          videoUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video3.mp4",
          thumbnailUrl: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/player_cover.png",
          status: "ACTIVE",
          startDate: "2024-03-15T00:00:00Z",
          endDate: "2024-06-15T00:00:00Z",
          isClaimed: false,
          isEligible: true,
          claimCount: 650,
          maxClaimCount: 3000,
          category: "CHALLENGE",
          difficulty: "HARD",
        );
      default:
        throw Exception('Activity not found');
    }
  }
} 