import '../entities/training_product.dart';
import '../entities/training_item.dart';

class TrainingService {
  /// 获取推荐训练项目
  List<TrainingItem> getRecommendedTrainings(List<TrainingItem> trainings) {
    return trainings.where((training) => training.isActive).toList();
  }

  /// 根据难度等级筛选训练
  List<TrainingItem> filterTrainingsByLevel(List<TrainingItem> trainings, String level) {
    return trainings.where((training) => 
      training.isActive && training.level.toLowerCase() == level.toLowerCase()
    ).toList();
  }

  /// 获取热门训练项目
  List<TrainingItem> getPopularTrainings(List<TrainingItem> trainings) {
    return trainings.where((training) => 
      training.isActive && training.isPopular
    ).toList();
  }

  /// 获取高完成率训练项目
  List<TrainingItem> getHighCompletionTrainings(List<TrainingItem> trainings) {
    return trainings.where((training) => 
      training.isActive && training.isHighCompletion
    ).toList();
  }

  /// 搜索训练项目
  List<TrainingItem> searchTrainings(List<TrainingItem> trainings, String query) {
    if (query.isEmpty) return trainings;
    
    return trainings.where((training) => 
      training.isActive && 
      (training.name.toLowerCase().contains(query.toLowerCase()) ||
       training.description.toLowerCase().contains(query.toLowerCase()) ||
       training.level.toLowerCase().contains(query.toLowerCase()))
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
    if (training.level.isEmpty) return false;
    if (training.description.isEmpty) return false;
    if (training.participantCount < 0) return false;
    if (training.completionRate < 0 || training.completionRate > 100) return false;
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
        'averageCompletionRate': 0.0,
        'totalParticipantCount': 0,
        'popularCount': 0,
        'highCompletionCount': 0,
      };
    }

    final totalCompletionRate = activeTrainings.fold<double>(
      0.0, (sum, training) => sum + training.completionRate
    );
    final totalParticipantCount = activeTrainings.fold<int>(
      0, (sum, training) => sum + training.participantCount
    );
    final popularCount = activeTrainings.where((t) => t.isPopular).length;
    final highCompletionCount = activeTrainings.where((t) => t.isHighCompletion).length;

    return {
      'totalCount': trainings.length,
      'activeCount': activeTrainings.length,
      'averageCompletionRate': totalCompletionRate / activeTrainings.length,
      'totalParticipantCount': totalParticipantCount,
      'popularCount': popularCount,
      'highCompletionCount': highCompletionCount,
    };
  }
} 