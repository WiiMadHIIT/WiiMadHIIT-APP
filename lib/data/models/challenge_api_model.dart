class ChallengeApiModel {
  final String id;             // 挑战唯一ID
  final String name;           // 挑战名称/标题
  final String reward;         // 奖励内容描述
  final String endDate;        // 结束时间 (ISO 8601格式字符串)
  final String status;         // 挑战状态 (字符串格式: 'ongoing', 'ended', 'upcoming')
  final String? videoUrl;      // 视频URL (远程或本地资源路径，可选)
  final String? description;   // 挑战描述信息 (可选)

  ChallengeApiModel({
    required this.id,
    required this.name,
    required this.reward,
    required this.endDate,
    required this.status,
    this.videoUrl,
    this.description,
  });

  factory ChallengeApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      reward: json['reward'] as String,
      endDate: json['endDate'] as String,
      status: json['status'] as String,
      videoUrl: json['videoUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'reward': reward,
    'endDate': endDate,
    'status': status,
    'videoUrl': videoUrl,
    'description': description,
  };

  /// 验证数据完整性
  bool get isValid {
    return id.isNotEmpty && 
           name.isNotEmpty && 
           reward.isNotEmpty && 
           endDate.isNotEmpty && 
           status.isNotEmpty;
  }

  /// 获取状态枚举值
  String get statusEnum {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return 'ongoing';
      case 'ended':
        return 'ended';
      case 'upcoming':
        return 'upcoming';
      default:
        return 'upcoming';
    }
  }

  /// 检查是否有视频资源
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  /// 检查是否有描述信息
  bool get hasDescription => description != null && description!.isNotEmpty;
}

class ChallengeListApiModel {
  final List<ChallengeApiModel> challenges;
  final int total;
  final int currentPage;
  final int pageSize;

  ChallengeListApiModel({
    required this.challenges,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory ChallengeListApiModel.fromJson(Map<String, dynamic> json) {
    final challengesList = json['challenges'] as List;
    final challenges = challengesList
        .map((challenge) => ChallengeApiModel.fromJson(challenge as Map<String, dynamic>))
        .toList();
    
    return ChallengeListApiModel(
      challenges: challenges,
      total: json['total'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
    'challenges': challenges.map((challenge) => challenge.toJson()).toList(),
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

  /// 获取有效的挑战列表
  List<ChallengeApiModel> get validChallenges {
    return challenges.where((challenge) => challenge.isValid).toList();
  }

  /// 根据状态筛选挑战
  List<ChallengeApiModel> getChallengesByStatus(String status) {
    return challenges.where((challenge) => 
      challenge.status.toLowerCase() == status.toLowerCase()
    ).toList();
  }

  /// 获取进行中的挑战
  List<ChallengeApiModel> get ongoingChallenges {
    return getChallengesByStatus('ongoing');
  }

  /// 获取已结束的挑战
  List<ChallengeApiModel> get endedChallenges {
    return getChallengesByStatus('ended');
  }

  /// 获取即将开始的挑战
  List<ChallengeApiModel> get upcomingChallenges {
    return getChallengesByStatus('upcoming');
  }
} 