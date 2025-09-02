import '../../data/repository/bonus_repository.dart';
import '../entities/bonus_activity.dart';

class GetBonusActivitiesUseCase {
  final BonusRepository repository;

  GetBonusActivitiesUseCase(this.repository);

  /// 获取分页奖励活动
  Future<BonusActivityPage> execute({
    int page = 1,
    int size = 10,
  }) async {
    return await repository.getBonusActivities(page: page, size: size);
  }


} 