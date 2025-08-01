import 'package:flutter/material.dart';
import '../presentation/profile/profile_page.dart';
import '../presentation/challenge/challenge_page.dart';
import '../presentation/challenge_details/challenge_details_page.dart';
import '../presentation/challenge_details/challenge_rule_page.dart';
import '../presentation/challenge_details/challenge_game_page.dart';
import '../presentation/home/home_page.dart';
import '../presentation/leaderboard/leaderboard_page.dart';
import '../presentation/checkinboard/checkinboard_page.dart';
import '../presentation/profile1/profile_page.dart';

import '../presentation/checkin_start_training/training_list_page.dart';
import '../presentation/checkin_start_training/training_rule_page.dart';
import '../presentation/checkin_start_training/checkin_training_page.dart';
import '../presentation/checkin_start_training/checkin_training_voice_page.dart';
import '../presentation/checkin_start_training/checkin_countdown_page.dart';
import '../presentation/checkin_start_training/audio_test_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String challenge = '/challenge';
  static const String profile = '/profile';
  static const String profile1 = '/profile1';

  static const String challengeDetails = '/challenge_details';
  static const String challengeRule = '/challenge_rule';
  static const String challengeGame = '/challenge_game';

  static const String leaderboard = '/leaderboard';
  static const String checkinboard = '/checkinboard';

  static const String trainingList = '/training_list';
  static const String trainingRule = '/training_rule';
  static const String checkinTraining = '/checkin_training';
  static const String checkinTrainingVoice = '/checkin_training_voice';
  static const String checkinCountdown = '/checkin_countdown';
  static const String audioTest = '/audio_test';

  static Map<String, WidgetBuilder> get routes => {
    profile: (_) => const ProfilePage(),
    profile1: (_) => const ProfilePage1(),
    challenge: (_) => const ChallengePage(),
    challengeDetails: (_) => const ChallengeDetailsPage(),
    challengeRule: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ChallengeRulePage.fromRoute(args ?? {});
    },
    challengeGame: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ChallengeGamePage(challengeId: args?['challengeId'] ?? '');
    },
    home: (_) => const HomePage(),
    leaderboard: (_) => LeaderboardPage(),
    checkinboard: (_) => CheckinboardPage(),
    trainingList: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return TrainingListPage(productId: args?['productId'] ?? '');
    },
    trainingRule: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return TrainingRulePage(
        trainingId: args?['trainingId'] ?? '',
        productId: args?['productId'] ?? '',
      );
    },
    checkinTraining: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return CheckinTrainingPage(
        trainingId: args?['trainingId'] ?? '',
        productId: args?['productId'] ?? '',
      );
    },
    checkinTrainingVoice: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return CheckinTrainingVoicePage(
        trainingId: args?['trainingId'] ?? '',
        productId: args?['productId'] ?? '',
      );
    },
    checkinCountdown: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return CheckinCountdownPage(
        trainingId: args?['trainingId'] ?? '',
        productId: args?['productId'] ?? '',
      );
    },
    audioTest: (_) => const AudioTestPage(),
  };
}