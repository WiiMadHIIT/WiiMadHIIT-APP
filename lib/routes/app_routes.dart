import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/profile/profile_page.dart';
import '../presentation/challenge/challenge_page.dart';
import '../presentation/challenge_details/challenge_details_page.dart';
import '../presentation/challenge_details/challenge_rule_page.dart';
import '../presentation/challenge_details/challenge_game_page.dart';
import '../presentation/home/home_page.dart';
import '../presentation/leaderboard/leaderboard_page.dart';
import '../presentation/checkinboard/checkinboard_page.dart';

import '../presentation/checkin_start_training/training_list_page.dart';
import '../presentation/checkin_start_training/training_rule_page.dart';
import '../presentation/checkin_start_training/checkin_training_page.dart';
import '../presentation/checkin_start_training/checkin_training_voice_page.dart';
import '../presentation/checkin_start_training/checkin_countdown_page.dart';
import '../presentation/checkin_start_training/checkin_training_viewmodel.dart';
import '../presentation/checkin_start_training/checkin_training_voice_viewmodel.dart';
import '../presentation/checkin_start_training/checkin_countdown_viewmodel.dart';
import '../presentation/login/login_page.dart';
import '../presentation/checkin/checkin_page.dart';
import '../presentation/bonus/bonus_page.dart';

import '../domain/usecases/get_checkin_training_data_and_video_config_usecase.dart';
import '../domain/usecases/get_training_voice_data_and_video_config_usecase.dart';
import '../domain/usecases/get_training_countdown_data_and_video_config_usecase.dart';
import '../domain/services/checkin_training_service.dart';
import '../domain/services/training_voice_service.dart';
import '../domain/services/training_countdown_service.dart';
import '../data/repository/checkin_training_repository.dart';
import '../data/repository/checkin_training_voice_repository.dart';
import '../data/repository/training_countdown_repository.dart';
import '../data/api/checkin_training_api.dart';
import '../data/api/checkin_training_voice_api.dart';
import '../data/api/training_countdown_api.dart';
import '../knock_voice/stream_audio_detector_example.dart';
import '../knock_voice/tone_specific_audio_detector_example.dart';
// import '../knock_voice/yamnet_test_page.dart';

class AppRoutes {
  // 路由常量
  static const String home = '/home';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String challenge = '/challenge';
  static const String checkin = '/checkin';
  static const String bonus = '/bonus';

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
  static const String streamAudioDetectorExample = '/stream_audio_detector_example';
  static const String toneSpecificAudioDetectorExample = '/tone_specific_audio_detector_example';

  // 路由表
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) {
      return const LoginPage();
    },
    profile: (context) => const ProfilePage(),
    challenge: (context) => const ChallengePage(),
    challengeDetails: (_) => const ChallengeDetailsPage(),
    challengeRule: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ChallengeRulePage(
        challengeId: args?['challengeId'] as String?,
      );
    },
    challengeGame: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ChallengeGamePage(
        challengeId: args?['challengeId'] ?? '',
        totalRounds: args?['totalRounds'] as int?,
        roundDuration: args?['roundDuration'] as int?,
        allowedTimes: args?['allowedTimes'] as int?, // 🎯 新增：传递剩余挑战次数
      );
    },
    checkin: (context) => const CheckinPage(),
    bonus: (context) => const BonusPage(),
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
    checkinTraining: (context) => _buildCheckinTrainingPage(context),
    checkinTrainingVoice: (context) => _buildCheckinTrainingVoicePage(context),
    checkinCountdown: (context) => _buildCheckinCountdownPage(context),
    streamAudioDetectorExample: (_) => const StreamAudioDetectorExample(),
    toneSpecificAudioDetectorExample: (_) => const ToneSpecificAudioDetectorExample(),
  };

  /// 构建倒计时训练页面
  static Widget _buildCheckinTrainingPage(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    return ChangeNotifierProvider(
      create: (context) => CheckinTrainingViewModel(
        getCheckinTrainingDataAndVideoConfigUseCase: GetCheckinTrainingDataAndVideoConfigUseCase(
          CheckinTrainingRepositoryImpl(CheckinTrainingApi()),
        ),
        submitCheckinTrainingResultUseCase: SubmitCheckinTrainingResultUseCase(
          CheckinTrainingRepositoryImpl(CheckinTrainingApi()),
        ),
        checkinTrainingService: CheckinTrainingService(),
      ),
      child: CheckinTrainingPage(
        trainingId: args?['trainingId'] ?? '',
        productId: args?['productId'] ?? '',
      ),
    );
  }

  /// 构建语音训练页面
  static Widget _buildCheckinTrainingVoicePage(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    return ChangeNotifierProvider(
      create: (context) => CheckinTrainingVoiceViewModel(
        getTrainingVoiceDataAndVideoConfigUseCase: GetTrainingVoiceDataAndVideoConfigUseCase(
          CheckinTrainingVoiceRepositoryImpl(CheckinTrainingVoiceApi()),
        ),
        getTrainingVoiceHistoryUseCase: GetTrainingVoiceHistoryUseCase(
          CheckinTrainingVoiceRepositoryImpl(CheckinTrainingVoiceApi()),
        ),
        submitTrainingVoiceResultUseCase: SubmitTrainingVoiceResultUseCase(
          CheckinTrainingVoiceRepositoryImpl(CheckinTrainingVoiceApi()),
        ),
        getTrainingVoiceVideoConfigUseCase: GetTrainingVoiceVideoConfigUseCase(
          CheckinTrainingVoiceRepositoryImpl(CheckinTrainingVoiceApi()),
        ),
        trainingVoiceService: TrainingVoiceService(),
      ),
      child: CheckinTrainingVoicePage(
        trainingId: args?['trainingId'] ?? '',
        productId: args?['productId'] ?? '',
      ),
    );
  }

  /// 构建倒计时训练页面
  static Widget _buildCheckinCountdownPage(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    return ChangeNotifierProvider(
      create: (context) => CheckinCountdownViewModel(
        getTrainingCountdownDataAndVideoConfigUseCase: GetTrainingCountdownDataAndVideoConfigUseCase(
          TrainingCountdownRepositoryImpl(TrainingCountdownApi()),
        ),
        getTrainingCountdownHistoryUseCase: GetTrainingCountdownHistoryUseCase(
          TrainingCountdownRepositoryImpl(TrainingCountdownApi()),
        ),
        submitTrainingCountdownResultUseCase: SubmitTrainingCountdownResultUseCase(
          TrainingCountdownRepositoryImpl(TrainingCountdownApi()),
        ),
        getTrainingCountdownVideoConfigUseCase: GetTrainingCountdownVideoConfigUseCase(
          TrainingCountdownRepositoryImpl(TrainingCountdownApi()),
        ),
        trainingCountdownService: TrainingCountdownService(),
      ),
      child: CheckinCountdownPage(
        trainingId: args?['trainingId'] ?? '',
        productId: args?['productId'] ?? '',
      ),
    );
  }

  // 获取带参数的登录路由
  static String getLoginRoute({String? redirectPath}) {
    if (redirectPath != null) {
      return '$login?redirect=${Uri.encodeComponent(redirectPath)}';
    }
    return login;
  }
}