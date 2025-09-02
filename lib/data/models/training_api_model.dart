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

  TrainingPageConfigApiModel({
    required this.pageTitle,
    required this.pageSubtitle,
    this.videoUrl,
    this.thumbnailUrl,
  });

  factory TrainingPageConfigApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingPageConfigApiModel(
      pageTitle: json['pageTitle'] ?? '',
      pageSubtitle: json['pageSubtitle'] ?? '',
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageTitle': pageTitle,
      'pageSubtitle': pageSubtitle,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

class TrainingItemApiModel {
  final String id;
  final String name;
  final int level;
  final String description;
  final int participantCount;
  final String status;

  TrainingItemApiModel({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.participantCount,
    required this.status,
  });

  factory TrainingItemApiModel.fromJson(Map<String, dynamic> json) {
    return TrainingItemApiModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: (json['level'] ?? 0) is int ? (json['level'] ?? 0) : int.tryParse((json['level'] ?? '0').toString()) ?? 0,
      description: json['description'] ?? '',
      participantCount: json['participantCount'] ?? 0,
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
      'status': status,
    };
  }
} 