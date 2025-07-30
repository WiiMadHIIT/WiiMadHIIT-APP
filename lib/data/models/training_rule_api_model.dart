class TrainingRuleApiModel {
  final String trainingId;
  final String productId;
  final List<TrainingRuleItemApiModel> trainingRules;
  final ProjectionTutorialApiModel projectionTutorial;
  final TrainingConfigApiModel trainingConfig;

  TrainingRuleApiModel({
    required this.trainingId,
    required this.productId,
    required this.trainingRules,
    required this.projectionTutorial,
    required this.trainingConfig,
  });

  factory TrainingRuleApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingRuleApiModel(
      trainingId: json['trainingId'] ?? '',
      productId: json['productId'] ?? '',
      trainingRules: (json['trainingRules'] as List<dynamic>?)
          ?.map((rule) => TrainingRuleItemApiModel.fromJson(rule))
          .toList() ?? [],
      projectionTutorial: ProjectionTutorialApiModel.fromJson(
        json['projectionTutorial'] ?? {},
      ),
      trainingConfig: TrainingConfigApiModel.fromJson(
        json['trainingConfig'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainingId': trainingId,
      'productId': productId,
      'trainingRules': trainingRules.map((rule) => rule.toJson()).toList(),
      'projectionTutorial': projectionTutorial.toJson(),
      'trainingConfig': trainingConfig.toJson(),
    };
  }
}

class TrainingRuleItemApiModel {
  final String id;
  final String title;
  final String description;
  final int order;

  TrainingRuleItemApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
  });

  factory TrainingRuleItemApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingRuleItemApiModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
    };
  }
}

class ProjectionTutorialApiModel {
  final VideoInfoApiModel videoInfo;
  final List<TutorialStepApiModel> tutorialSteps;

  ProjectionTutorialApiModel({
    required this.videoInfo,
    required this.tutorialSteps,
  });

  factory ProjectionTutorialApiModel.fromJson(Map<String, dynamic> json) {
    return ProjectionTutorialApiModel(
      videoInfo: VideoInfoApiModel.fromJson(json['videoInfo'] ?? {}),
      tutorialSteps: (json['tutorialSteps'] as List<dynamic>?)
          ?.map((step) => TutorialStepApiModel.fromJson(step))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoInfo': videoInfo.toJson(),
      'tutorialSteps': tutorialSteps.map((step) => step.toJson()).toList(),
    };
  }
}

class VideoInfoApiModel {
  final String videoUrl;
  final String title;

  VideoInfoApiModel({
    required this.videoUrl,
    required this.title,
  });

  factory VideoInfoApiModel.fromJson(Map<String, dynamic> json) {
    return VideoInfoApiModel(
      videoUrl: json['videoUrl'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoUrl': videoUrl,
      'title': title,
    };
  }
}

class TutorialStepApiModel {
  final int number;
  final String title;
  final String description;

  TutorialStepApiModel({
    required this.number,
    required this.title,
    required this.description,
  });

  factory TutorialStepApiModel.fromJson(Map<String, dynamic> json) {
    return TutorialStepApiModel(
      number: json['number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'description': description,
    };
  }
}

class TrainingConfigApiModel {
  final String nextPageRoute;

  TrainingConfigApiModel({
    required this.nextPageRoute,
  });

  factory TrainingConfigApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingConfigApiModel(
      nextPageRoute: json['nextPageRoute'] ?? '/checkin_countdown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextPageRoute': nextPageRoute,
    };
  }
} 