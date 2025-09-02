class ProfileApiModel {
  final UserApiModel user;
  final UserStatsApiModel stats;
  final List<HonorApiModel> honors;
  final List<ChallengeRecordApiModel> challengeRecords;
  final List<CheckinRecordApiModel> checkinRecords;
  final List<ActivateApiModel> activate;

  ProfileApiModel({
    required this.user,
    required this.stats,
    required this.honors,
    required this.challengeRecords,
    required this.checkinRecords,
    required this.activate,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      user: UserApiModel.fromJson(json['user'] as Map<String, dynamic>),
      stats: UserStatsApiModel.fromJson(json['stats'] as Map<String, dynamic>),
      honors: (json['honors'] as List<dynamic>)
          .map((e) => HonorApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      challengeRecords: (json['challengeRecords'] as List<dynamic>)
          .map((e) => ChallengeRecordApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkinRecords: (json['checkinRecords'] as List<dynamic>)
          .map((e) => CheckinRecordApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      activate: (json['activate'] as List<dynamic>)
          .map((e) => ActivateApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'stats': stats.toJson(),
    'honors': honors.map((e) => e.toJson()).toList(),
    'challengeRecords': challengeRecords.map((e) => e.toJson()).toList(),
    'checkinRecords': checkinRecords.map((e) => e.toJson()).toList(),
    'activate': activate.map((e) => e.toJson()).toList(),
  };
}

class UserApiModel {
  final String userId;
  final String username;
  final String email;
  final String avatarUrl;

  UserApiModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.avatarUrl,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'email': email,
    'avatarUrl': avatarUrl,
  };
}

class UserStatsApiModel {
  final int currentStreak;
  final int daysThisYear;
  final int daysAllTime;

  UserStatsApiModel({
    required this.currentStreak,
    required this.daysThisYear,
    required this.daysAllTime,
  });

  factory UserStatsApiModel.fromJson(Map<String, dynamic> json) {
    return UserStatsApiModel(
      currentStreak: json['currentStreak'] as int,
      daysThisYear: json['daysThisYear'] as int,
      daysAllTime: json['daysAllTime'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'daysThisYear': daysThisYear,
    'daysAllTime': daysAllTime,
  };
}

class HonorApiModel {
  final String id;
  final String icon;
  final String label;
  final String description;
  final int timestep;

  HonorApiModel({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.timestep,
  });

  factory HonorApiModel.fromJson(Map<String, dynamic> json) {
    return HonorApiModel(
      id: json['id'] as String,
      icon: json['icon'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
      timestep: json['timestep'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'icon': icon,
    'label': label,
    'description': description,
    'timestep': timestep,
  };
}

class ChallengeRecordApiModel {
  final String id;
  final String challengeId;
  final int index;
  final String name;
  final String status;
  final int timestep;
  final String rank;

  ChallengeRecordApiModel({
    required this.id,
    required this.challengeId,
    required this.index,
    required this.name,
    required this.status,
    required this.timestep,
    required this.rank,
  });

  factory ChallengeRecordApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeRecordApiModel(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      index: json['index'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      timestep: json['timestep'] as int,
      rank: json['rank'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'challengeId': challengeId,
    'index': index,
    'name': name,
    'status': status,
    'timestep': timestep,
    'rank': rank,
  };
}

class CheckinRecordApiModel {
  final String id;
  final String productId;
  final int index;
  final String name;
  final String status;
  final int timestep;
  final String rank;

  CheckinRecordApiModel({
    required this.id,
    required this.productId,
    required this.index,
    required this.name,
    required this.status,
    required this.timestep,
    required this.rank,
  });

  factory CheckinRecordApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinRecordApiModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      index: json['index'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      timestep: json['timestep'] as int,
      rank: json['rank'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'index': index,
    'name': name,
    'status': status,
    'timestep': timestep,
    'rank': rank,
  };
}

class ActivateApiModel {
  final String challengeId;
  final String challengeName;
  final String productId;
  final String productName;

  ActivateApiModel({
    required this.challengeId,
    required this.challengeName,
    required this.productId,
    required this.productName,
  });

  factory ActivateApiModel.fromJson(Map<String, dynamic> json) {
    return ActivateApiModel(
      challengeId: json['challengeId'] as String,
      challengeName: json['challengeName'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'challengeId': challengeId,
    'challengeName': challengeName,
    'productId': productId,
    'productName': productName,
  };
}

// 新增：激活分页模型（不含 equipmentIds）
class ActivatePageApiModel {
  final List<ActivateApiModel> activate;
  final int total;
  final int currentPage;
  final int pageSize;

  ActivatePageApiModel({
    required this.activate,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory ActivatePageApiModel.fromJson(Map<String, dynamic> json) {
    return ActivatePageApiModel(
      activate: (json['activate'] as List<dynamic>)
          .map((e) => ActivateApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'activate': activate.map((e) => e.toJson()).toList(),
    'total': total,
    'currentPage': currentPage,
    'pageSize': pageSize,
  };
}

// 新增：激活码请求模型
class ActivationRequestApiModel {
  final String productId;
  final String activationCode;

  ActivationRequestApiModel({
    required this.productId,
    required this.activationCode,
  });

  factory ActivationRequestApiModel.fromJson(Map<String, dynamic> json) {
    return ActivationRequestApiModel(
      productId: json['productId'] as String,
      activationCode: json['activationCode'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'activationCode': activationCode,
  };
}

// 新增：激活码响应模型
class ActivationResponseApiModel {
  final bool submitted;
  final String message;

  ActivationResponseApiModel({
    required this.submitted,
    required this.message,
  });

  factory ActivationResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ActivationResponseApiModel(
      submitted: json['submitted'] as bool,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'submitted': submitted,
    'message': message,
  };
}

// 新增：用户信息更新响应模型
class ProfileUpdateResponseApiModel {
  final bool updated;
  final String message;

  ProfileUpdateResponseApiModel({
    required this.updated,
    required this.message,
  });

  factory ProfileUpdateResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponseApiModel(
      updated: json['updated'] as bool,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'updated': updated,
    'message': message,
  };
}

// 新增：打卡分页模型
class CheckinPageApiModel {
  final List<CheckinRecordApiModel> checkinRecords;
  final int total;
  final int currentPage;
  final int pageSize;

  CheckinPageApiModel({
    required this.checkinRecords,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory CheckinPageApiModel.fromJson(Map<String, dynamic> json) {
    return CheckinPageApiModel(
      checkinRecords: (json['checkinRecords'] as List<dynamic>)
          .map((e) => CheckinRecordApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'checkinRecords': checkinRecords.map((e) => e.toJson()).toList(),
    'total': total,
    'currentPage': currentPage,
    'pageSize': pageSize,
  };
}

// 新增：挑战分页模型
class ChallengePageApiModel {
  final List<ChallengeRecordApiModel> challengeRecords;
  final int total;
  final int currentPage;
  final int pageSize;

  ChallengePageApiModel({
    required this.challengeRecords,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory ChallengePageApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengePageApiModel(
      challengeRecords: (json['challengeRecords'] as List<dynamic>)
          .map((e) => ChallengeRecordApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'challengeRecords': challengeRecords.map((e) => e.toJson()).toList(),
    'total': total,
    'currentPage': currentPage,
    'pageSize': pageSize,
  };
}

// 新增：删除账号响应模型
class ProfileDeleteResponseApiModel {
  final bool deleted;
  final String message;
  final int deletedAt;

  ProfileDeleteResponseApiModel({
    required this.deleted,
    required this.message,
    required this.deletedAt,
  });

  factory ProfileDeleteResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileDeleteResponseApiModel(
      deleted: json['deleted'] as bool,
      message: json['message'] as String,
      deletedAt: json['deletedAt'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'deleted': deleted,
    'message': message,
    'deletedAt': deletedAt,
  };
}
