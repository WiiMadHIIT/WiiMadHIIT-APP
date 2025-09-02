import '../../data/repository/checkinboard_repository.dart';
import '../../domain/entities/checkinboard/checkinboard.dart';

class GetCheckinboardUseCase {
  final CheckinboardRepository repository;

  GetCheckinboardUseCase(this.repository);

  Future<CheckinboardPage> execute({int page = 1, int pageSize = 10}) {
    return repository.getCheckinboards(page: page, pageSize: pageSize);
  }
}

class GetCheckinboardRankingsUseCase {
  final CheckinboardRepository repository;

  GetCheckinboardRankingsUseCase(this.repository);

  Future<CheckinboardRankingsPage> execute({String? activity, String? activityId, int page = 1, int pageSize = 16}) async {
    return repository.getRankingsPage(activity: activity, activityId: activityId, page: page, pageSize: pageSize);
  }
}
