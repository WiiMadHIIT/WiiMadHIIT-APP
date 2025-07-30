import '../../data/repository/bonus_repository.dart';

class ClaimBonusUseCase {
  final BonusRepository repository;

  ClaimBonusUseCase(this.repository);

  /// 领取奖励
  Future<Map<String, dynamic>> execute(String activityId) async {
    try {
      final result = await repository.claimBonus(activityId);
      return result;
    } catch (e) {
      throw Exception('Failed to claim bonus: $e');
    }
  }
} 