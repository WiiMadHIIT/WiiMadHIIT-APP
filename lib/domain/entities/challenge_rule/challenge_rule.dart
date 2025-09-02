class ChallengeRule {
  final String id;
  final String title;
  final String description;
  final int order;

  ChallengeRule({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
  });

  // 业务逻辑方法
  bool get isValid => id.isNotEmpty && title.isNotEmpty && description.isNotEmpty;
  
  String get displayTitle => title.trim();
  
  String get displayDescription => description.trim();
  
  bool get isFirstRule => order == 1;
  
  bool get isLastRule => order > 0; // 可以根据实际业务逻辑调整
} 