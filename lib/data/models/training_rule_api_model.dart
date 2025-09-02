class TrainingRuleApiModel {
  final String trainingId;
  final String productId;
  final List<TrainingRuleItemApiModel> trainingRules;
  final TrainingConfigApiModel trainingConfig;

  TrainingRuleApiModel({
    required this.trainingId,
    required this.productId,
    required this.trainingRules,
    required this.trainingConfig,
  });

  factory TrainingRuleApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingRuleApiModel(
      trainingId: json['trainingId'] ?? '',
      productId: json['productId'] ?? '',
      trainingRules: (json['trainingRules'] as List<dynamic>?)
          ?.map((rule) => TrainingRuleItemApiModel.fromJson(rule))
          .toList() ?? [],
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

class TrainingConfigApiModel {
  final String nextPageRoute;
  final bool isActivated;

  TrainingConfigApiModel({
    required this.nextPageRoute,
    required this.isActivated,
  });

  factory TrainingConfigApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingConfigApiModel(
      nextPageRoute: json['nextPageRoute'] ?? '/checkin_countdown',
      isActivated: json['isActivated'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextPageRoute': nextPageRoute,
      'isActivated': isActivated,
    };
  }
} 