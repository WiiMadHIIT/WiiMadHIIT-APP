class BonusApiModel {
  final String id;
  final String name;
  final String description;
  final String reward;
  final String regionLimit;
  final String videoUrl;
  final String? thumbnailUrl;
  final String status;
  final String startDate;
  final String endDate;
  final bool isClaimed;
  final bool isEligible;
  final int claimCount;
  final int maxClaimCount;
  final String category;
  final String difficulty;

  BonusApiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.reward,
    required this.regionLimit,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.isClaimed,
    required this.isEligible,
    required this.claimCount,
    required this.maxClaimCount,
    required this.category,
    required this.difficulty,
  });

  factory BonusApiModel.fromJson(Map<String, dynamic> json) {
    return BonusApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      reward: json['reward'] as String,
      regionLimit: json['regionLimit'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      status: json['status'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      isClaimed: json['isClaimed'] as bool,
      isEligible: json['isEligible'] as bool,
      claimCount: json['claimCount'] as int,
      maxClaimCount: json['maxClaimCount'] as int,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'reward': reward,
    'regionLimit': regionLimit,
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl,
    'status': status,
    'startDate': startDate,
    'endDate': endDate,
    'isClaimed': isClaimed,
    'isEligible': isEligible,
    'claimCount': claimCount,
    'maxClaimCount': maxClaimCount,
    'category': category,
    'difficulty': difficulty,
  };
}

class BonusListApiModel {
  final List<BonusApiModel> activities;

  BonusListApiModel({
    required this.activities,
  });

  factory BonusListApiModel.fromJson(Map<String, dynamic> json) {
    final activitiesList = json['activities'] as List;
    final activities = activitiesList
        .map((activity) => BonusApiModel.fromJson(activity as Map<String, dynamic>))
        .toList();
    
    return BonusListApiModel(activities: activities);
  }

  Map<String, dynamic> toJson() => {
    'activities': activities.map((activity) => activity.toJson()).toList(),
  };
} 