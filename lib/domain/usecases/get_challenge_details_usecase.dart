import '../../data/repository/challenge_details_repository.dart';
import '../entities/challenge_details/challenge_details.dart';

// 获取挑战基础信息用例
class GetChallengeBasicUseCase {
  final ChallengeDetailsRepository repository;

  GetChallengeBasicUseCase(this.repository);

  Future<ChallengeBasic> execute(String challengeId) {
    return repository.getChallengeBasic(challengeId);
  }
}

// 获取季后赛数据用例
class GetChallengePlayoffsUseCase {
  final ChallengeDetailsRepository repository;

  GetChallengePlayoffsUseCase(this.repository);

  Future<PlayoffData> execute(String challengeId) {
    return repository.getChallengePlayoffs(challengeId);
  }
}

// 获取季前赛数据用例
class GetChallengePreseasonUseCase {
  final ChallengeDetailsRepository repository;

  GetChallengePreseasonUseCase(this.repository);

  Future<PreseasonData> execute(
    String challengeId, {
    int page = 1,
    int size = 10,
  }) {
    return repository.getChallengePreseason(
      challengeId,
      page: page,
      size: size,
    );
  }
}