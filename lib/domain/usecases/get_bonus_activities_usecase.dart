import '../../data/repository/bonus_repository.dart';
import '../entities/bonus_activity.dart';

class GetBonusActivitiesUseCase {
  final BonusRepository repository;

  GetBonusActivitiesUseCase(this.repository);

  /// 获取所有奖励活动
  Future<List<BonusActivity>> execute() async {
    return await repository.getBonusActivities();
  }

  /// 获取指定分类的活动
  Future<List<BonusActivity>> executeByCategory(String category) async {
    final activities = await repository.getBonusActivities();
    return activities.where((activity) => 
      activity.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  /// 获取指定难度的活动
  Future<List<BonusActivity>> executeByDifficulty(String difficulty) async {
    final activities = await repository.getBonusActivities();
    return activities.where((activity) => 
      activity.difficulty.toLowerCase() == difficulty.toLowerCase()
    ).toList();
  }

  /// 获取活跃的活动
  Future<List<BonusActivity>> executeActiveOnly() async {
    final activities = await repository.getBonusActivities();
    return activities.where((activity) => activity.isActive).toList();
  }
} 