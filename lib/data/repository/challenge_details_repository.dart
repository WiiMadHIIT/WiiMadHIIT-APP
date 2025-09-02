import '../api/challenge_details_api.dart';
import '../models/challenge_details_api_model.dart';
import '../../domain/entities/challenge_details/challenge_details.dart';
import '../../domain/entities/challenge_details/playoff_match.dart';
import '../../domain/entities/challenge_details/game_tracker_post.dart';
import '../../domain/entities/challenge_details/preseason_record.dart';

class ChallengeDetailsRepository {
  final ChallengeDetailsApi _challengeDetailsApi;

  ChallengeDetailsRepository(this._challengeDetailsApi);

  // 获取挑战基础信息
  Future<ChallengeBasic> getChallengeBasic(String challengeId) async {
    final ChallengeBasicApiModel apiModel = await _challengeDetailsApi.fetchChallengeBasic(challengeId);
    
    return ChallengeBasic(
      challengeId: apiModel.challengeId,
      challengeName: apiModel.challengeName,
      backgroundImage: apiModel.backgroundImage,
      videoUrl: apiModel.videoUrl,
      preseasonNotice: apiModel.preseasonNotice,  // 新增
      rules: _convertRules(apiModel.rules),
      gameTracker: _convertGameTracker(apiModel.gameTracker),
    );
  }

  // 获取季后赛数据
  Future<PlayoffData> getChallengePlayoffs(String challengeId) async {
    final ChallengePlayoffsApiModel apiModel = await _challengeDetailsApi.fetchChallengePlayoffs(challengeId);
    
    return PlayoffData(
      stages: apiModel.stages,
      matches: _convertMatches(apiModel.matches),
    );
  }

  // 获取季前赛数据
  Future<PreseasonData> getChallengePreseason(
    String challengeId, {
    int page = 1,
    int size = 10,
  }) async {
    final ChallengePreseasonApiModel apiModel = await _challengeDetailsApi.fetchChallengePreseason(
      challengeId,
      page: page,
      size: size,
    );
    
    return PreseasonData(
      records: apiModel.records.map((record) => _convertPreseasonRecord(record)).toList(),
      pagination: _convertPagination(apiModel.pagination),  // 新增
    );
  }

  ChallengeRules _convertRules(ChallengeRulesApiModel apiModel) {
    return ChallengeRules(
      title: apiModel.title,
      items: apiModel.items,
      details: apiModel.details,
    );
  }

  PlayoffMatch _convertPlayoffMatch(PlayoffMatchApiModel apiModel) {
    return PlayoffMatch(
      userId1: apiModel.userId1,
      avatar1: apiModel.avatar1,
      name1: apiModel.name1,
      userId2: apiModel.userId2,
      avatar2: apiModel.avatar2,
      name2: apiModel.name2,
      score1: apiModel.score1,
      score2: apiModel.score2,
      finished: apiModel.finished,
    );
  }

  PreseasonRecord _convertPreseasonRecord(PreseasonRecordApiModel apiModel) {
    return PreseasonRecord(
      id: apiModel.id,
      index: apiModel.index,
      name: apiModel.name,
      rank: apiModel.rank,
      counts: apiModel.counts,
    );
  }

  GameTrackerData _convertGameTracker(GameTrackerDataApiModel apiModel) {
    return GameTrackerData(
      posts: apiModel.posts.map((item) => _convertGameTrackerPost(item)).toList(),
    );
  }

  GameTrackerPost _convertGameTrackerPost(GameTrackerPostApiModel apiModel) {
    return GameTrackerPost(
      id: apiModel.id,
      announcement: apiModel.announcement,
      image: apiModel.image,
      desc: apiModel.desc,
      timestep: apiModel.timestep,
    );
  }

  // 转换季后赛对阵数据（用于新的API）
  Map<String, List<PlayoffMatch>> _convertMatches(Map<String, List<PlayoffMatchApiModel>> apiMatches) {
    return apiMatches.map((key, value) => MapEntry(
      key,
      value.map((match) => _convertPlayoffMatch(match)).toList(),
    ));
  }

  // 转换分页信息
  PaginationInfo _convertPagination(PaginationInfoApiModel apiModel) {
    return PaginationInfo(
      total: apiModel.total,
      currentPage: apiModel.currentPage,
      pageSize: apiModel.pageSize,
      totalPages: apiModel.totalPages,
    );
  }
} 