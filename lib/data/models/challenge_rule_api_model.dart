class ChallengeRuleApiModel {
  final String challengeId;
  final int totalRounds;
  final int roundDuration;
  final List<ChallengeRuleItemApiModel> challengeRules;
  final ChallengeConfigApiModel challengeConfig;

  ChallengeRuleApiModel({
    required this.challengeId,
    required this.totalRounds,
    required this.roundDuration,
    required this.challengeRules,
    required this.challengeConfig,
  });

  factory ChallengeRuleApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeRuleApiModel(
      challengeId: json['challengeId'] ?? '',
      totalRounds: json['totalRounds'] ?? 3,
      roundDuration: json['roundDuration'] ?? 80,
      challengeRules: (json['challengeRules'] as List<dynamic>?)
          ?.map((rule) => ChallengeRuleItemApiModel.fromJson(rule))
          .toList() ?? [],
      challengeConfig: ChallengeConfigApiModel.fromJson(
        json['challengeConfig'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'totalRounds': totalRounds,
      'roundDuration': roundDuration,
      'challengeRules': challengeRules.map((rule) => rule.toJson()).toList(),
      'challengeConfig': challengeConfig.toJson(),
    };
  }
}

class ChallengeRuleItemApiModel {
  final String id;
  final String title;
  final String description;
  final int order;

  ChallengeRuleItemApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
  });

  factory ChallengeRuleItemApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeRuleItemApiModel(
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

 

class ChallengeConfigApiModel {
  final String nextPageRoute;
  final bool isActivated;
  final bool isQualified;
  final int allowedTimes;

  ChallengeConfigApiModel({
    required this.nextPageRoute,
    required this.isActivated,
    required this.isQualified,
    required this.allowedTimes,
  });

  factory ChallengeConfigApiModel.fromJson(Map<String, dynamic> json) {
    return ChallengeConfigApiModel(
      nextPageRoute: json['nextPageRoute'] ?? '/challenge_game',
      isActivated: json['isActivated'] ?? false,
      isQualified: json['isQualified'] ?? false,
      allowedTimes: json['allowedTimes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextPageRoute': nextPageRoute,
      'isActivated': isActivated,
      'isQualified': isQualified,
      'allowedTimes': allowedTimes,
    };
  }
} 