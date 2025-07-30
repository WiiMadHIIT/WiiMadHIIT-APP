class ProjectionTutorial {
  final VideoInfo videoInfo;
  final List<TutorialStep> tutorialSteps;

  ProjectionTutorial({
    required this.videoInfo,
    required this.tutorialSteps,
  });

  // 业务逻辑方法
  bool get hasVideo => videoInfo.videoUrl.isNotEmpty;
  
  bool get hasTutorialSteps => tutorialSteps.isNotEmpty;
  
  int get stepCount => tutorialSteps.length;
  
  List<TutorialStep> get sortedSteps => List.from(tutorialSteps)
    ..sort((a, b) => a.number.compareTo(b.number));
  
  TutorialStep? get firstStep => tutorialSteps.isNotEmpty ? tutorialSteps.first : null;
  
  TutorialStep? get lastStep => tutorialSteps.isNotEmpty ? tutorialSteps.last : null;
}

class VideoInfo {
  final String videoUrl;
  final String title;

  VideoInfo({
    required this.videoUrl,
    required this.title,
  });

  // 业务逻辑方法
  bool get isValid => videoUrl.isNotEmpty && title.isNotEmpty;
  
  String get displayTitle => title.trim();
  
  bool get isNetworkVideo => videoUrl.startsWith('http');
  
  bool get isLocalVideo => videoUrl.startsWith('assets/');
}

class TutorialStep {
  final int number;
  final String title;
  final String description;

  TutorialStep({
    required this.number,
    required this.title,
    required this.description,
  });

  // 业务逻辑方法
  bool get isValid => number > 0 && title.isNotEmpty && description.isNotEmpty;
  
  String get displayTitle => title.trim();
  
  String get displayDescription => description.trim();
  
  String get stepNumberText => 'Step $number';
  
  bool get isFirstStep => number == 1;
  
  bool get isLastStep => number > 0; // 可以根据实际业务逻辑调整
} 