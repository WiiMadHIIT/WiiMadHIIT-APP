import '../entities/challenge.dart';
import '../services/challenge_service.dart';
import '../../data/repository/challenge_repository.dart';

class GetChallengesUseCase {
  final ChallengeRepository _repository;
  final ChallengeService _service;

  GetChallengesUseCase(this._repository, this._service);

  /// 获取分页挑战列表
  Future<ChallengePage> execute({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final pageData = await _repository.getChallenges(page: page, size: size);
      
      // 验证数据
      if (!_service.validateChallengeData(pageData.challenges)) {
        throw Exception('Invalid challenge data received');
      }
      
      // 返回按优先级排序的挑战列表
      final sortedChallenges = _service.getChallengesByPriority(pageData.challenges);
      
      return ChallengePage(
        challenges: sortedChallenges,
        total: pageData.total,
        currentPage: pageData.currentPage,
        pageSize: pageData.pageSize,
      );
    } catch (e) {
      throw Exception('Failed to get challenges: $e');
    }
  }

  /// 获取所有挑战列表（向后兼容）
  Future<List<Challenge>> getAllChallenges() async {
    try {
      final challenges = await _repository.getAllChallenges();
      
      // 验证数据
      if (!_service.validateChallengeData(challenges)) {
        throw Exception('Invalid challenge data received');
      }
      
      // 返回按优先级排序的挑战列表
      return _service.getChallengesByPriority(challenges);
    } catch (e) {
      throw Exception('Failed to get challenges: $e');
    }
  }

  /// 根据状态获取挑战列表
  Future<List<Challenge>> getChallengesByStatus(String status) async {
    try {
      final challenges = await _repository.getChallengesByStatus(status);
      
      if (!_service.validateChallengeData(challenges)) {
        throw Exception('Invalid challenge data received for status: $status');
      }
      
      return challenges;
    } catch (e) {
      throw Exception('Failed to get challenges by status $status: $e');
    }
  }

  /// 获取进行中的挑战
  Future<List<Challenge>> getOngoingChallenges() async {
    try {
      return await _repository.getOngoingChallenges();
    } catch (e) {
      throw Exception('Failed to get ongoing challenges: $e');
    }
  }

  /// 获取已结束的挑战
  Future<List<Challenge>> getEndedChallenges() async {
    try {
      return await _repository.getEndedChallenges();
    } catch (e) {
      throw Exception('Failed to get ended challenges: $e');
    }
  }

  /// 获取即将开始的挑战
  Future<List<Challenge>> getUpcomingChallenges() async {
    try {
      return await _repository.getUpcomingChallenges();
    } catch (e) {
      throw Exception('Failed to get upcoming challenges: $e');
    }
  }

  /// 获取推荐挑战列表
  Future<List<Challenge>> getRecommendedChallenges() async {
    try {
      final challenges = await getAllChallenges();
      return _service.getRecommendedChallenges(challenges);
    } catch (e) {
      throw Exception('Failed to get recommended challenges: $e');
    }
  }

  /// 搜索挑战
  Future<List<Challenge>> searchChallenges(String query) async {
    try {
      final challenges = await getAllChallenges();
      return _service.searchChallenges(challenges, query);
    } catch (e) {
      throw Exception('Failed to search challenges: $e');
    }
  }

  /// 获取挑战统计信息
  Future<Map<String, int>> getChallengeStatistics() async {
    try {
      final challenges = await getAllChallenges();
      return _service.getChallengeStatistics(challenges);
    } catch (e) {
      throw Exception('Failed to get challenge statistics: $e');
    }
  }

  /// 获取热门挑战
  Future<List<Challenge>> getPopularChallenges() async {
    try {
      final challenges = await getAllChallenges();
      return _service.getPopularChallenges(challenges);
    } catch (e) {
      throw Exception('Failed to get popular challenges: $e');
    }
  }

  /// 获取即将到期的挑战
  Future<List<Challenge>> getExpiringSoonChallenges() async {
    try {
      final challenges = await getAllChallenges();
      return _service.getExpiringSoonChallenges(challenges);
    } catch (e) {
      throw Exception('Failed to get expiring soon challenges: $e');
    }
  }

  /// 获取可参与的挑战
  Future<List<Challenge>> getParticipatableChallenges() async {
    try {
      final challenges = await getAllChallenges();
      return _service.getParticipatableChallenges(challenges);
    } catch (e) {
      throw Exception('Failed to get participatable challenges: $e');
    }
  }

  /// 获取有视频资源的挑战
  Future<List<Challenge>> getChallengesWithVideos() async {
    try {
      final challenges = await getAllChallenges();
      return _service.getChallengesWithVideos(challenges);
    } catch (e) {
      throw Exception('Failed to get challenges with videos: $e');
    }
  }

  /// 刷新挑战数据
  Future<List<Challenge>> refreshChallenges() async {
    try {
      return await _repository.refreshChallenges();
    } catch (e) {
      throw Exception('Failed to refresh challenges: $e');
    }
  }
} 