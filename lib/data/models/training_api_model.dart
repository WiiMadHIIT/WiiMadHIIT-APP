class TrainingProductApiModel {
  final String productId;
  final TrainingPageConfigApiModel pageConfig;
  final List<TrainingItemApiModel> trainings;

  TrainingProductApiModel({
    required this.productId,
    required this.pageConfig,
    required this.trainings,
  });

  factory TrainingProductApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingProductApiModel(
      productId: json['productId'] ?? '',
      pageConfig: TrainingPageConfigApiModel.fromJson(json['pageConfig'] ?? {}),
      trainings: (json['trainings'] as List?)
          ?.map((training) => TrainingItemApiModel.fromJson(training))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'pageConfig': pageConfig.toJson(),
      'trainings': trainings.map((training) => training.toJson()).toList(),
    };
  }
}

class TrainingPageConfigApiModel {
  final String pageTitle;
  final String pageSubtitle;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? lastUpdated;

  TrainingPageConfigApiModel({
    required this.pageTitle,
    required this.pageSubtitle,
    this.videoUrl,
    this.thumbnailUrl,
    this.lastUpdated,
  });

  factory TrainingPageConfigApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingPageConfigApiModel(
      pageTitle: json['pageTitle'] ?? '',
      pageSubtitle: json['pageSubtitle'] ?? '',
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      lastUpdated: json['lastUpdated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageTitle': pageTitle,
      'pageSubtitle': pageSubtitle,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'lastUpdated': lastUpdated,
    };
  }
}

class TrainingItemApiModel {
  final String id;
  final String name;
  final String level;
  final String description;
  final int participantCount;
  final double completionRate;
  final String status;

  TrainingItemApiModel({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.participantCount,
    required this.completionRate,
    required this.status,
  });

  factory TrainingItemApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingItemApiModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      description: json['description'] ?? '',
      participantCount: json['participantCount'] ?? 0,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'description': description,
      'participantCount': participantCount,
      'completionRate': completionRate,
      'status': status,
    };
  }
} 