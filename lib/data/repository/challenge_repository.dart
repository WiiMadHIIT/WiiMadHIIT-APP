import '../api/challenge_api.dart';
import '../models/challenge_api_model.dart';
import '../../domain/entities/challenge.dart';

class ChallengeRepository {
  final ChallengeApi _challengeApi;

  ChallengeRepository(this._challengeApi);

  /// 获取挑战列表（支持分页）
  Future<ChallengePage> getChallenges({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final ChallengeListApiModel apiModel = await _challengeApi.fetchChallenges(
        page: page,
        size: size,
      );
      
      // 转换为业务实体
      final challenges = apiModel.validChallenges.map((challenge) => Challenge(
        id: challenge.id,
        name: challenge.name,
        reward: challenge.reward,
        endDate: _parseDateTime(challenge.endDate),
        status: challenge.status,
        videoUrl: challenge.videoUrl,
        description: challenge.description,
      )).toList();

      return ChallengePage(
        challenges: challenges,
        total: apiModel.total,
        currentPage: apiModel.currentPage,
        pageSize: apiModel.pageSize,
      );
    } catch (e) {
      // 记录错误日志
      print('Error fetching challenges: $e');
      rethrow;
    }
  }

  /// 获取所有挑战列表（向后兼容）
  Future<List<Challenge>> getAllChallenges() async {
    final page = await getChallenges(page: 1, size: 1000); // 获取大量数据
    return page.challenges;
  }

  /// 根据状态获取挑战列表
  Future<List<Challenge>> getChallengesByStatus(String status) async {
    try {
      final page = await getChallenges(page: 1, size: 1000); // 获取大量数据
      
      // 筛选并返回
      return page.challenges.where((challenge) => 
        challenge.status.toLowerCase() == status.toLowerCase()
      ).toList();
    } catch (e) {
      print('Error fetching challenges by status $status: $e');
      rethrow;
    }
  }

  /// 获取进行中的挑战
  Future<List<Challenge>> getOngoingChallenges() async {
    return getChallengesByStatus('ongoing');
  }

  /// 获取已结束的挑战
  Future<List<Challenge>> getEndedChallenges() async {
    return getChallengesByStatus('ended');
  }

  /// 获取即将开始的挑战
  Future<List<Challenge>> getUpcomingChallenges() async {
    return getChallengesByStatus('upcoming');
  }

  /// 解析ISO 8601格式的日期时间字符串
  DateTime _parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // 如果解析失败，返回当前时间加1天作为默认值
      print('Error parsing date: $dateString, using default: ${e.toString()}');
      return DateTime.now().add(const Duration(days: 1));
    }
  }

  /// 刷新挑战数据（清除缓存，重新获取）
  Future<List<Challenge>> refreshChallenges() async {
    // 这里可以添加缓存清理逻辑
    return getAllChallenges();
  }

  /// 搜索挑战（按名称或描述）
  Future<List<Challenge>> searchChallenges(String query) async {
    try {
      final allChallenges = await getAllChallenges();
      if (query.isEmpty) return allChallenges;
      
      final lowercaseQuery = query.toLowerCase();
      return allChallenges.where((challenge) {
        return challenge.name.toLowerCase().contains(lowercaseQuery) ||
               (challenge.description != null && 
                challenge.description!.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      print('Error searching challenges: $e');
      rethrow;
    }
  }
}

/// 分页数据包装类
class ChallengePage {
  final List<Challenge> challenges;
  final int total;
  final int currentPage;
  final int pageSize;

  ChallengePage({
    required this.challenges,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  // 分页信息计算
  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;
} 