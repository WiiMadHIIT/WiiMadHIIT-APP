import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/challenge_details_api_model.dart';

class ChallengeDetailsApi {
  final Dio _dio = DioClient().dio;

  // 获取挑战基础信息
  Future<ChallengeBasicApiModel> fetchChallengeBasic(String challengeId) async {
    final response = await _dio.get('/api/challenge/$challengeId/basic');
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ChallengeBasicApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }

  // 获取季后赛数据
  Future<ChallengePlayoffsApiModel> fetchChallengePlayoffs(String challengeId) async {
    final response = await _dio.get('/api/challenge/$challengeId/playoffs');
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ChallengePlayoffsApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }

  // 获取季前赛数据
  Future<ChallengePreseasonApiModel> fetchChallengePreseason(
    String challengeId, {
    int page = 1,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/api/challenge/$challengeId/preseason',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ChallengePreseasonApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }

  /// 模拟数据方法 - 根据Java后端的伪数据实现
  Future<ChallengeBasicApiModel> fetchChallengeBasic_MOCK(String challengeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 根据挑战ID生成对应的基础信息数据
    return _generateMockChallengeBasic(challengeId);
  }

  Future<ChallengePlayoffsApiModel> fetchChallengePlayoffs_MOCK(String challengeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 根据挑战ID生成对应的季后赛数据
    return _generateMockChallengePlayoffs(challengeId);
  }

  Future<ChallengePreseasonApiModel> fetchChallengePreseason_MOCK(String challengeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 根据挑战ID生成对应的季前赛数据
    return _generateMockChallengePreseason(challengeId);
  }

  /// 生成模拟挑战基础信息数据
  ChallengeBasicApiModel _generateMockChallengeBasic(String challengeId) {
    // 生成挑战规则数据
    final rules = ChallengeRulesApiModel(
      title: "Challenge Rules",
      items: [
        "1. Complete the daily workout to earn points.",
        "2. Rankings are based on total points.",
        "3. Top 3 will receive exclusive rewards!",
        "4. Minimum 10 minutes workout per day required.",
        "5. Points are calculated based on workout intensity and duration."
      ],
      details: "Here you can provide a more detailed description of the challenge rules, scoring, rewards, and any other information participants should know.\n\n" +
          "You can also add links, images, or FAQs as needed. This challenge is designed to motivate participants to maintain consistent fitness routines " +
          "while competing with others in a friendly environment."
    );

    // 生成游戏追踪数据
    final gameTrackerPosts = [
      GameTrackerPostApiModel(
        id: "post_001",
        announcement: "🏆 Congratulations!\nYou are the WINNER of the 10 SEC MAX Challenge!",
        image: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png",
        desc: "Share your achievement with friends and stay tuned for the next challenge!",
        timestep: DateTime.now().millisecondsSinceEpoch
      ),
      GameTrackerPostApiModel(
        id: "post_002",
        announcement: "🔥 New Record!\nYou hit 50 punches in 10 seconds!",
        image: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png",
        desc: "Keep pushing your limits and break more records!",
        timestep: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch
      ),
      GameTrackerPostApiModel(
        id: "post_003",
        announcement: "⚡ Daily Challenge Completed!\nPerfect form, maximum effort!",
        image: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png",
        desc: "Consistency is key to success. Great job today!",
        timestep: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch
      ),
      GameTrackerPostApiModel(
        id: "post_004",
        announcement: "🎯 Weekly Goal Achieved!\nYou've completed 7 days in a row!",
        image: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png",
        desc: "Amazing dedication! Keep up the great work!",
        timestep: DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch
      ),
      GameTrackerPostApiModel(
        id: "post_005",
        announcement: "💪 Strength Training Master!\nNew personal best in bench press!",
        image: "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png",
        desc: "Your hard work is paying off!",
        timestep: DateTime.now().subtract(const Duration(days: 4)).millisecondsSinceEpoch
      )
    ];

    final gameTracker = GameTrackerDataApiModel(posts: gameTrackerPosts);

    // 根据挑战ID生成不同的挑战名称和背景
    String challengeName;
    String backgroundImage;
    String videoUrl;
    
    switch (challengeId) {
      case "pk1":
        challengeName = "7-Day HIIT Showdown";
        backgroundImage = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png";
        videoUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video1.mp4";
        break;
      case "pk2":
        challengeName = "30-Day Fitness Marathon";
        backgroundImage = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png";
        videoUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video2.mp4";
        break;
      case "pk3":
        challengeName = "Strength Training Challenge";
        backgroundImage = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png";
        videoUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video3.mp4";
        break;
      default:
        challengeName = "10 SEC MAX Challenge";
        backgroundImage = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/thumbnails/avatar_default.png";
        videoUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/hiit-cdn@main/video/video1.mp4";
        break;
    }

    return ChallengeBasicApiModel(
      challengeId: challengeId,
      challengeName: challengeName,
      backgroundImage: backgroundImage,
      videoUrl: videoUrl,
      preseasonNotice: "Preseason is for warm-up and fun! Results here do not affect the official playoffs. Enjoy and challenge yourself!",  // 新增
      rules: rules,
      gameTracker: gameTracker
    );
  }

  /// 生成模拟季后赛数据
  ChallengePlayoffsApiModel _generateMockChallengePlayoffs(String challengeId) {
    // 生成季后赛阶段名称映射
    final Map<String, String> stages = {
      "round32": "1/32 PLAYOFF",
      "round16": "1/16 FINALS",
      "round8": "1/8 FINALS",
      "round4": "1/4 FINALS",
      "semi": "SEMI FINAL",
      "finalMatch": "FINAL"
    };

    // 生成季后赛对阵数据
    final Map<String, List<PlayoffMatchApiModel>> matches = {};
    
    // Round 32 对阵
    final round32Matches = [
      PlayoffMatchApiModel(
        userId1: "user_001",
        avatar1: "https://randomuser.me/api/portraits/men/1.jpg",
        name1: "Player1",
        userId2: "user_002",
        avatar2: "https://randomuser.me/api/portraits/men/2.jpg",
        name2: "Player2",
        score1: 45,
        score2: 41,
        finished: true
      ),
      PlayoffMatchApiModel(
        userId1: "user_003",
        avatar1: "https://randomuser.me/api/portraits/men/3.jpg",
        name1: "Player3",
        userId2: "user_004",
        avatar2: "https://randomuser.me/api/portraits/men/4.jpg",
        name2: "Player4",
        score1: 38,
        score2: 42,
        finished: true
      )
    ];
    matches["round32"] = round32Matches;

    // Round 16 对阵
    final round16Matches = [
      PlayoffMatchApiModel(
        userId1: "user_015",
        avatar1: "https://randomuser.me/api/portraits/men/15.jpg",
        name1: "Player15",
        userId2: "user_016",
        avatar2: "https://randomuser.me/api/portraits/men/16.jpg",
        name2: "Player16",
        score1: 42,
        score2: 38,
        finished: true
      ),
      PlayoffMatchApiModel(
        userId1: "user_017",
        avatar1: "https://randomuser.me/api/portraits/men/17.jpg",
        name1: "Player17",
        userId2: "user_018",
        avatar2: "https://randomuser.me/api/portraits/men/18.jpg",
        name2: "Player18",
        score1: 39,
        score2: 44,
        finished: true
      )
    ];
    matches["round16"] = round16Matches;

    // Round 8 对阵
    final round8Matches = [
      PlayoffMatchApiModel(
        userId1: "user_005",
        avatar1: "https://randomuser.me/api/portraits/men/5.jpg",
        name1: "Karateboxarwjs",
        userId2: "user_006",
        avatar2: "https://randomuser.me/api/portraits/men/6.jpg",
        name2: "JaylenF",
        score1: 45,
        score2: 41,
        finished: true
      ),
      PlayoffMatchApiModel(
        userId1: "user_007",
        avatar1: "https://randomuser.me/api/portraits/men/7.jpg",
        name1: "Player7",
        userId2: "user_008",
        avatar2: "https://randomuser.me/api/portraits/men/8.jpg",
        name2: "Player8",
        score1: 39,
        score2: 43,
        finished: true
      )
    ];
    matches["round8"] = round8Matches;

    // Round 4 对阵
    final round4Matches = [
      PlayoffMatchApiModel(
        userId1: "user_009",
        avatar1: "https://randomuser.me/api/portraits/men/9.jpg",
        name1: "Player9",
        userId2: "user_010",
        avatar2: "https://randomuser.me/api/portraits/men/10.jpg",
        name2: "Player10",
        finished: false
      )
    ];
    matches["round4"] = round4Matches;

    // Semi Final 对阵
    final semiMatches = [
      PlayoffMatchApiModel(
        userId1: "user_011",
        avatar1: "https://randomuser.me/api/portraits/men/11.jpg",
        name1: "Player11",
        userId2: "user_012",
        avatar2: "https://randomuser.me/api/portraits/men/12.jpg",
        name2: "Player12",
        finished: false
      )
    ];
    matches["semi"] = semiMatches;

    // Final 对阵
    final finalMatches = [
      PlayoffMatchApiModel(
        userId1: "user_013",
        avatar1: "https://randomuser.me/api/portraits/men/13.jpg",
        name1: "Player13",
        userId2: "user_014",
        avatar2: "https://randomuser.me/api/portraits/men/14.jpg",
        name2: "Player14",
        finished: false
      )
    ];
    matches["finalMatch"] = finalMatches;

    return ChallengePlayoffsApiModel(
      challengeId: challengeId,
      stages: stages,
      matches: matches
    );
  }

  /// 生成模拟季前赛数据
  ChallengePreseasonApiModel _generateMockChallengePreseason(String challengeId) {
    // 生成季前赛数据
    final preseasonRecords = [
      PreseasonRecordApiModel(
        id: "record_001",
        index: 1,
        name: "HIIT 7-Day Challenge",
        rank: "2nd",
        counts: 42
      ),
      PreseasonRecordApiModel(
        id: "record_002",
        index: 2,
        name: "Yoga Masters Cup",
        rank: "1st",
        counts: 38
      ),
      PreseasonRecordApiModel(
        id: "record_003",
        index: 3,
        name: "Strength Training Bootcamp",
        rank: "3rd",
        counts: 31
      ),
      PreseasonRecordApiModel(
        id: "record_004",
        index: 4,
        name: "Cardio Blast Challenge",
        rank: "4th",
        counts: 27
      )
    ];

    // 生成分页信息
    final pagination = PaginationInfoApiModel(
      total: 25,
      currentPage: 1,
      pageSize: 10,
      totalPages: 3,
    );

    return ChallengePreseasonApiModel(
      challengeId: challengeId,
      records: preseasonRecords,
      pagination: pagination
    );
  }
} 