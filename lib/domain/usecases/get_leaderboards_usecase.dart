import '../../data/repository/leaderboard_repository.dart';
import '../../domain/entities/leaderboard/leaderboard.dart';

class GetLeaderboardsUseCase {
  final LeaderboardRepository repository;

  GetLeaderboardsUseCase(this.repository);

  Future<LeaderboardListPage> execute({int page = 1, int size = 10}) {
    return repository.getLeaderboards(page: page, size: size);
  }
}

class GetLeaderboardRankingsUseCase {
  final LeaderboardRepository repository;

  GetLeaderboardRankingsUseCase(this.repository);

  Future<LeaderboardRankingsPage> execute({
    required String challengeId,
    int page = 1,
    int pageSize = 16,
  }) {
    return repository.getRankings(challengeId: challengeId, page: page, pageSize: pageSize);
  }
}


