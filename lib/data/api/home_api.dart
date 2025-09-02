import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/home_api_model.dart';

class HomeApi {
  final Dio _dio = DioClient().dio;

  // 新增：获取公告栏数据
  Future<HomeAnnouncementsApiModel> fetchHomeAnnouncements() async {
    final response = await _dio.get(
      '/api/home/announcements',
    );
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return HomeAnnouncementsApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch home announcements');
    }
  }

  // 新增：获取最近冠军数据
  Future<HomeChampionsApiModel> fetchHomeChampions() async {
    final response = await _dio.get(
      '/api/home/recent-champions',
    );
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return HomeChampionsApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch home champions');
    }
  }

  // 新增：获取活跃用户数据
  Future<HomeActiveUsersApiModel> fetchHomeActiveUsers() async {
    final response = await _dio.get(
      '/api/home/active-users',
    );
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return HomeActiveUsersApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch home active users');
    }
  }

  // 新增：获取公告栏数据的Mock方法
  Future<HomeAnnouncementsApiModel> fetchHomeAnnouncements_MOCK() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return HomeAnnouncementsApiModel(
      announcements: _generateMockAnnouncements(),
    );
  }

  // 新增：获取最近冠军数据的Mock方法
  Future<HomeChampionsApiModel> fetchHomeChampions_MOCK() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return HomeChampionsApiModel(
      recentChampions: _generateMockChampions(),
    );
  }

  // 新增：获取活跃用户数据的Mock方法
  Future<HomeActiveUsersApiModel> fetchHomeActiveUsers_MOCK() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return HomeActiveUsersApiModel(
      activeUsers: _generateMockActiveUsers(),
    );
  }

  /// 生成模拟公告数据
  /// 根据Java后端HomeServiceImpl.generateMockAnnouncements的实现
  List<AnnouncementApiModel> _generateMockAnnouncements() {
    return [
      AnnouncementApiModel(
        id: "1",
        title: "🔥 7-Day Streak Achieved!",
        subtitle: "Congratulations on maintaining a week of exercise habits!",
        priority: 1
      ),
      AnnouncementApiModel(
        id: "2",
        title: "🏆 Earned 3 XVector Voice Badges",
        subtitle: "Your voice recognition skills are getting amazing!",
        priority: 2
      ),
      AnnouncementApiModel(
        id: "3",
        title: "✅ Completed 12 Check-ins",
        subtitle: "You've reached 80% of this month's goal. Keep going!",
        priority: 3
      ),
      AnnouncementApiModel(
        id: "4",
        title: "📈 Rank Improved This Week",
        subtitle: "You've moved up 3 positions in your friends' leaderboard!",
        priority: 2
      ),
      AnnouncementApiModel(
        id: "5",
        title: "🎉 New Feature Available",
        subtitle: "AI Voice Coach is now open for experience!",
        priority: 1
      )
    ];
  }

  /// 生成模拟冠军数据
  /// 根据Java后端HomeServiceImpl.generateMockChampions的实现
  List<ChampionApiModel> _generateMockChampions() {
    final List<String> challenges = [
      "HIIT Challenge",
      "Yoga Masterclass", 
      "Strength Training",
      "Cardio Blast",
      "Flexibility Flow",
      "Boxing Workout",
      "Dance Fitness",
      "Pilates Core"
    ];
    
    final List<int> counts = [98, 96, 94, 93, 91, 89, 87, 85];
    
    return [
      ChampionApiModel(
        userId: "user_001",
        username: "Alex Johnson",
        challengeName: challenges[0],
        challengeId: "challenge_001",
        rank: 1,
        counts: counts[0],
        completedAt: DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch, // 2小时前
        avatar: "assets/images/avatar_default.png"
      ),
      ChampionApiModel(
        userId: "user_002", 
        username: "Sarah Williams",
        challengeName: challenges[1],
        challengeId: "challenge_002",
        rank: 2,
        counts: counts[1],
        completedAt: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch, // 1天前
        avatar: "assets/images/avatar_default.png"
      ),
      ChampionApiModel(
        userId: "user_003",
        username: "Michael Brown",
        challengeName: challenges[2],
        challengeId: "challenge_003", 
        rank: 3,
        counts: counts[2],
        completedAt: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch, // 2天前
        avatar: "assets/images/avatar_default.png"
      ),
      ChampionApiModel(
        userId: "user_004",
        username: "Emily Davis",
        challengeName: challenges[3],
        challengeId: "challenge_004",
        rank: 4,
        counts: counts[3],
        completedAt: DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch, // 3天前
        avatar: "assets/images/avatar_default.png"
      ),
      ChampionApiModel(
        userId: "user_005",
        username: "David Miller",
        challengeName: challenges[4],
        challengeId: "challenge_005",
        rank: 5,
        counts: counts[4],
        completedAt: DateTime.now().subtract(const Duration(days: 4)).millisecondsSinceEpoch, // 4天前
        avatar: "assets/images/avatar_default.png"
      )
    ];
  }

  /// 生成模拟活跃用户数据
  /// 根据Java后端HomeServiceImpl.generateMockActiveUsers的实现
  List<ActiveUserApiModel> _generateMockActiveUsers() {
    return [
      ActiveUserApiModel(
        userId: "user_001",
        username: "Alex Johnson",
        streakDays: 21,
        lastCheckinDate: DateTime.now().toIso8601String().split('T')[0], // 今天
        yearlyCheckins: 45,
        latestActivityName: "HIIT Challenge",
        avatar: "assets/images/avatar_default.png"
      ),
      ActiveUserApiModel(
        userId: "user_002",
        username: "Sarah Williams", 
        streakDays: 18,
        lastCheckinDate: DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0], // 1天前
        yearlyCheckins: 38,
        latestActivityName: "Yoga Masterclass",
        avatar: "assets/images/avatar_default.png"
      ),
      ActiveUserApiModel(
        userId: "user_003",
        username: "Michael Brown",
        streakDays: 15,
        lastCheckinDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T')[0], // 2天前
        yearlyCheckins: 42,
        latestActivityName: "Strength Training",
        avatar: "assets/images/avatar_default.png"
      ),
      ActiveUserApiModel(
        userId: "user_004",
        username: "Emily Davis",
        streakDays: 12,
        lastCheckinDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String().split('T')[0], // 3天前
        yearlyCheckins: 35,
        latestActivityName: "Cardio Blast",
        avatar: "assets/images/avatar_default.png"
      ),
      ActiveUserApiModel(
        userId: "user_005",
        username: "David Miller",
        streakDays: 9,
        lastCheckinDate: DateTime.now().subtract(const Duration(days: 4)).toIso8601String().split('T')[0], // 4天前
        yearlyCheckins: 28,
        latestActivityName: "Flexibility Flow",
        avatar: "assets/images/avatar_default.png"
      ),
      ActiveUserApiModel(
        userId: "user_006",
        username: "Jessica Taylor",
        streakDays: 7,
        lastCheckinDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String().split('T')[0], // 5天前
        yearlyCheckins: 25,
        latestActivityName: "Boxing Workout",
        avatar: "assets/images/avatar_default.png"
      ),
      ActiveUserApiModel(
        userId: "user_007",
        username: "Christopher Wilson",
        streakDays: 5,
        lastCheckinDate: DateTime.now().subtract(const Duration(days: 6)).toIso8601String().split('T')[0], // 6天前
        yearlyCheckins: 22,
        latestActivityName: "Dance Fitness",
        avatar: "assets/images/avatar_default.png"
      ),
      ActiveUserApiModel(
        userId: "user_008",
        username: "Amanda Anderson",
        streakDays: 3,
        lastCheckinDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T')[0], // 7天前
        yearlyCheckins: 18,
        latestActivityName: "Pilates Core",
        avatar: "assets/images/avatar_default.png"
      )
    ];
  }
}
