import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/challenge_game_api_model.dart';

class ChallengeGameApi {
  final Dio _dio = DioClient().dio;

  /// 获取挑战游戏数据和视频配置
  /// 包含历史排名数据和视频配置信息
  Future<Map<String, dynamic>> getChallengeGameDataAndVideoConfig(
    String challengeId, // 🎯 修改：使用challengeId
    {
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenge/game/data', // 🎯 修改：使用challenge相关的API路径
        queryParameters: {
          'challengeId': challengeId, // 🎯 修改：使用challengeId
          if (limit != null) 'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        final data = response.data['data'];
        return {
          'history': (data['history'] as List)
              .map((item) => ChallengeGameHistoryApiModel.fromJson(item))
              .toList(),
          'videoConfig': data['videoConfig'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get challenge game data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 模拟数据方法 - 根据Java后端的伪数据实现
  Future<Map<String, dynamic>> getChallengeGameDataAndVideoConfig_MOCK(
    String challengeId, {
    int? limit,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 生成挑战游戏数据
    final history = _generateMockChallengeGameHistory(challengeId, limit);
    final videoConfig = _generateMockChallengeGameVideoConfig(challengeId);
    
    return {
      'history': history,
      'videoConfig': videoConfig,
    };
  }

  /// 提交挑战游戏结果
  Future<ChallengeGameSubmitResponseApiModel> submitChallengeGameResult(
    ChallengeGameResultApiModel result,
  ) async {
    try {
      final response = await _dio.post(
        '/api/challenge/game/submit', // 🎯 修改：使用challenge相关的API路径
        data: result.toJson(),
      );

      if (response.statusCode == 200 && response.data['code'] == 'A200') {
        return ChallengeGameSubmitResponseApiModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit challenge game result');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 模拟提交挑战游戏结果
  Future<ChallengeGameSubmitResponseApiModel> submitChallengeGameResult_MOCK(
    ChallengeGameResultApiModel result,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 生成提交响应
    return _generateMockChallengeGameSubmitResponse(result);
  }

  /// 生成模拟挑战游戏历史记录
  /// 根据Java后端ChallengeServiceImpl.generateMockChallengeGameHistory的实现
  List<ChallengeGameHistoryApiModel> _generateMockChallengeGameHistory(String challengeId, int? limit) {
    final List<ChallengeGameHistoryApiModel> history = [];
    
    // 设置默认限制
    final int maxLimit = (limit != null) ? (limit < 10 ? limit : 10) : 10;
    
    // 根据挑战ID生成不同的历史数据
    int baseCounts = 20; // 挑战游戏通常有更高的次数
    if (challengeId.contains("pro")) {
      baseCounts = 30; // 专业挑战有更高的次数
    } else if (challengeId.contains("beginner")) {
      baseCounts = 15; // 初学者挑战次数相对较少
    }
    
    // 生成历史记录
    for (int i = 0; i < maxLimit; i++) {
      final int timestamp = DateTime.now().subtract(Duration(days: i)).millisecondsSinceEpoch; // 每天一条记录
      final int counts = baseCounts + (DateTime.now().millisecondsSinceEpoch % 10).toInt(); // 随机变化
      final int rank = i + 1;
      
      final String? note = (i == 0) ? "current" : null; // 第一条记录标记为当前
      
      final ChallengeGameHistoryApiModel historyItem = ChallengeGameHistoryApiModel(
        id: "challenge_history_${challengeId}_$i",
        rank: rank,
        counts: counts,
        timestamp: timestamp,
        note: note,
        name: "User${i + 1}", // 用户名
        userId: "user_${i + 1}"  // 用户ID
      );
      
      history.add(historyItem);
    }
    
    return history;
  }

  /// 生成模拟挑战游戏视频配置
  /// 根据Java后端ChallengeServiceImpl.generateMockChallengeGameVideoConfig的实现
  ChallengeGameVideoConfigApiModel _generateMockChallengeGameVideoConfig(String challengeId) {
    String? portraitUrl;
    String? landscapeUrl;
    
    // 根据挑战ID设置不同的视频URL
    if (challengeId.contains("pro")) {
      portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/challenge-cdn@main/video/video1.mp4";
      landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/challenge-cdn@main/video/video1.mp4";
    } else if (challengeId.contains("beginner")) {
      portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/challenge-cdn@main/video/video1.mp4";
      landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/challenge-cdn@main/video/video1.mp4";
    } else {
      portraitUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/challenge-cdn@main/video/video1.mp4";
      landscapeUrl = "https://cdn.jsdelivr.net/gh/WiiMadHIIT/challenge-cdn@main/video/video1.mp4";
    }
    
    return ChallengeGameVideoConfigApiModel(
      portraitUrl: portraitUrl,
      landscapeUrl: landscapeUrl,
    );
  }

  /// 生成模拟挑战游戏提交响应
  /// 根据Java后端ChallengeServiceImpl.generateMockChallengeGameSubmitResponse的实现
  ChallengeGameSubmitResponseApiModel _generateMockChallengeGameSubmitResponse(ChallengeGameResultApiModel request) {
    // 模拟生成一个随机排名（1-10之间）
    final int rank = (DateTime.now().millisecondsSinceEpoch % 10).toInt() + 1;
    
    // 生成一个唯一的ID
    final String id = "challenge_submit_${DateTime.now().millisecondsSinceEpoch}";
    
    // 🎯 根据挑战ID生成不同的剩余次数
    int allowedTimes;
    final String challengeId = request.challengeId;
    
    switch (challengeId) {
      case "pk1":
        // 7-Day HIIT Showdown: 提交后减少1次，从5次变为4次
        allowedTimes = 4;
        break;
      case "pk2":
        // 30-Day Fitness Marathon: 提交后减少1次，从3次变为2次
        allowedTimes = 2;
        break;
      case "pk3":
        // Strength Training Challenge: 已用完次数
        allowedTimes = 0;
        break;
      default:
        // 默认挑战: 提交后减少1次，从初始次数变为0
        allowedTimes = 0;
        break;
    }
    
    return ChallengeGameSubmitResponseApiModel(
      id: id,
      rank: rank,
      allowedTimes: allowedTimes // 🎯 新增：返回剩余挑战次数
    );
  }
} 