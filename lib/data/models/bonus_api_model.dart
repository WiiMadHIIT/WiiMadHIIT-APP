class BonusApiModel {
  final String id;
  final String name;
  final String description;
  final String reward;
  final String regionLimit;
  final String videoUrl;
  final String activityName;
  final String activityDescription;
  final String activityCode;
  final String activityUrl;
  final int startTimeStep;
  final int endTimeStep;

  BonusApiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.reward,
    required this.regionLimit,
    required this.videoUrl,
    required this.activityName,
    required this.activityDescription,
    required this.activityCode,
    required this.activityUrl,
    required this.startTimeStep,
    required this.endTimeStep,
  });

  factory BonusApiModel.fromJson(Map<String, dynamic> json) {
    return BonusApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      reward: json['reward'] as String,
      regionLimit: json['regionLimit'] as String,
      videoUrl: json['videoUrl'] as String,
      activityName: json['activityName'] as String,
      activityDescription: json['activityDescription'] as String,
      activityCode: json['activityCode'] as String,
      activityUrl: json['activityUrl'] as String,
      startTimeStep: json['startTimeStep'] as int,
      endTimeStep: json['endTimeStep'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'reward': reward,
    'regionLimit': regionLimit,
    'videoUrl': videoUrl,
    'activityName': activityName,
    'activityDescription': activityDescription,
    'activityCode': activityCode,
    'activityUrl': activityUrl,
    'startTimeStep': startTimeStep,
    'endTimeStep': endTimeStep,
  };
}

class BonusListApiModel {
  final List<BonusApiModel> activities;
  final int total;
  final int currentPage;
  final int pageSize;

  BonusListApiModel({
    required this.activities,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory BonusListApiModel.fromJson(Map<String, dynamic> json) {
    final activitiesList = json['activities'] as List;
    final activities = activitiesList
        .map((activity) => BonusApiModel.fromJson(activity as Map<String, dynamic>))
        .toList();
    
    return BonusListApiModel(
      activities: activities,
      total: json['total'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
    'activities': activities.map((activity) => activity.toJson()).toList(),
    'total': total,
    'currentPage': currentPage,
    'pageSize': pageSize,
  };

  // 分页信息计算
  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;
} 