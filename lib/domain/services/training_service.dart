import '../entities/training_product.dart';
import '../entities/training_item.dart';

class TrainingService {
  /// 获取推荐训练项目
  List<TrainingItem> getRecommendedTrainings(List<TrainingItem> trainings) {
    return trainings.where((training) => training.isActive).toList();
  }

  /// 根据难度等级筛选训练
  List<TrainingItem> filterTrainingsByLevel(List<TrainingItem> trainings, int level) {
    return trainings.where((training) => training.isActive && training.level == level).toList();
  }

  /// 获取热门训练项目
  List<TrainingItem> getPopularTrainings(List<TrainingItem> trainings) {
    return trainings.where((training) => 
      training.isActive && training.isPopular
    ).toList();
  }

  /// 获取高完成率训练项目
  List<TrainingItem> getHighCompletionTrainings(List<TrainingItem> trainings) {
    // 已移除完成率概念，返回空或按其他规则调整
    return [];
  }

  /// 搜索训练项目
  List<TrainingItem> searchTrainings(List<TrainingItem> trainings, String query) {
    if (query.isEmpty) return trainings;
    
    return trainings.where((training) => 
      training.isActive && 
      (training.name.toLowerCase().contains(query.toLowerCase()) ||
       training.description.toLowerCase().contains(query.toLowerCase()) ||
       training.level.toString().contains(query))
    ).toList();
  }

  /// 验证训练产品数据
  bool validateTrainingProduct(TrainingProduct product) {
    if (product.productId.isEmpty) return false;
    if (product.pageConfig.pageTitle.isEmpty) return false;
    if (product.pageConfig.pageSubtitle.isEmpty) return false;
    if (product.trainings.isEmpty) return false;
    
    // 验证每个训练项目
    for (final training in product.trainings) {
      if (!_validateTrainingItem(training)) return false;
    }
    
    return true;
  }

  /// 验证训练项目数据
  bool _validateTrainingItem(TrainingItem training) {
    if (training.id.isEmpty) return false;
    if (training.name.isEmpty) return false;
    if (training.level <= 0) return false;
    if (training.description.isEmpty) return false;
    if (training.participantCount < 0) return false;
    if (training.status.isEmpty) return false;
    
    return true;
  }

  /// 获取训练统计信息
  Map<String, dynamic> getTrainingStatistics(List<TrainingItem> trainings) {
    final activeTrainings = trainings.where((t) => t.isActive).toList();
    
    if (activeTrainings.isEmpty) {
      return {
        'totalCount': 0,
        'activeCount': 0,
        'totalParticipantCount': 0,
        'popularCount': 0,
        'highCompletionCount': 0,
      };
    }

    final totalCompletionRate = 0.0; // 已移除完成率
    final totalParticipantCount = activeTrainings.fold<int>(
      0, (sum, training) => sum + training.participantCount
    );
    final popularCount = activeTrainings.where((t) => t.isPopular).length;
    final highCompletionCount = activeTrainings.where((t) => t.isHighCompletion).length;

    return {
      'totalCount': trainings.length,
      'activeCount': activeTrainings.length,
      'totalParticipantCount': totalParticipantCount,
      'popularCount': popularCount,
      'highCompletionCount': 0,
    };
  }
} 