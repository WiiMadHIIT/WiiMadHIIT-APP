import 'package:flutter/material.dart';
import '../presentation/profile/profile_page.dart';
import '../presentation/challenge/challenge_page.dart';
import '../presentation/challenge/challenge_details_page.dart';
import '../presentation/home/home_page.dart';

class AppRoutes {
  static const String profile = '/profile';
  static const String challenge = '/challenge';
  static const String challengeDetails = '/challenge_details';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    profile: (_) => const ProfilePage(),
    challenge: (_) => const ChallengePage(),
    challengeDetails: (_) => const ChallengeDetailsPage(),
    home: (_) => const HomePage(),
  };
}