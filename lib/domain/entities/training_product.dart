import 'training_item.dart';

class TrainingProduct {
  final String productId;
  final TrainingPageConfig pageConfig;
  final List<TrainingItem> trainings;

  TrainingProduct({
    required this.productId,
    required this.pageConfig,
    required this.trainings,
  });

  // 获取活跃的训练项目
  List<TrainingItem> get activeTrainings {
    return trainings.where((training) => training.status == 'ACTIVE').toList();
  }

  // 获取训练项目数量
  int get trainingCount => trainings.length;

  // 获取活跃训练项目数量
  int get activeTrainingCount => activeTrainings.length;

  // 检查是否有可用的训练项目
  bool get hasAvailableTrainings => activeTrainings.isNotEmpty;

  // 获取平均完成率
  double get averageCompletionRate {
    if (activeTrainings.isEmpty) return 0.0;
    final totalRate = activeTrainings.fold<double>(0.0, (sum, training) => sum + training.completionRate);
    return totalRate / activeTrainings.length;
  }

  // 获取总参与人数
  int get totalParticipantCount {
    return activeTrainings.fold<int>(0, (sum, training) => sum + training.participantCount);
  }
}

class TrainingPageConfig {
  final String pageTitle;
  final String pageSubtitle;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? lastUpdated;

  TrainingPageConfig({
    required this.pageTitle,
    required this.pageSubtitle,
    this.videoUrl,
    this.thumbnailUrl,
    this.lastUpdated,
  });

  // 获取视频资源（优先网络，回退本地）
  String get displayVideoUrl {
    if (videoUrl != null && videoUrl!.isNotEmpty) {
      return videoUrl!;
    }
    return 'assets/video/video1.mp4'; // 默认本地视频
  }

  // 获取图片资源（优先网络，回退本地）
  String get displayThumbnailUrl {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      // 检查URL是否有效
      try {
        final uri = Uri.parse(thumbnailUrl!);
        if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
          return thumbnailUrl!;
        }
      } catch (e) {
        print('Invalid thumbnail URL: $thumbnailUrl');
      }
    }
    return 'assets/images/player_cover.png'; // 默认本地图片
  }

  // 判断是否使用网络视频
  bool get hasCustomVideo => videoUrl != null && videoUrl!.isNotEmpty;

  // 判断是否使用网络图片
  bool get hasCustomThumbnail {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(thumbnailUrl!);
        return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
      } catch (e) {
        return false;
      }
    }
    return false;
  }
} 