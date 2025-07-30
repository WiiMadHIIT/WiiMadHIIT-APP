import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'dart:ui';
import '../../routes/app_routes.dart';
import '../../widgets/projection_tutorial_sheet.dart';

// ================== 伪数据 ==================
final Map<String, dynamic> fakeChallengeInfo = {
  "name": "Challenge Game",
  "type": "Competition",
  "level": "All Levels",
};

final List<Map<String, dynamic>> fakeChallengeRules = [
  {
    "icon": Icons.settings,
    "title": "Device Setup",
    "description": "Switch to P10 mode and P9 speed for optimal challenge experience",
    "color": const Color(0xFF10B981),
  },
  {
    "icon": Icons.timer,
    "title": "System Calibration",
    "description": "Wait 3 seconds after adjustment for system to respond",
    "color": const Color(0xFFF59E0B),
  },
  {
    "icon": Icons.check_circle,
    "title": "Ready Check",
    "description": "Ensure you are in a safe environment with proper space",
    "color": const Color(0xFFEF4444),
  },
];

final Map<String, dynamic> fakeVideoInfo = {
  "asset": "assets/video/video1.mp4",
  "duration": "2 min",
  "quality": "HD",
  "title": "Watch Challenge Tutorial",
  "subtitle": "Learn challenge setup step by step",
};

final List<Map<String, dynamic>> fakeTutorialSteps = [
  {
    "number": 1,
    "title": "Find a Flat Surface",
    "description": "Choose a wall or flat surface that is at least 2 meters wide and 1.5 meters tall.",
    "icon": Icons.wallpaper,
  },
  {
    "number": 2,
    "title": "Position Your Device",
    "description": "Place your device on a stable surface, approximately 1-2 meters from the projection surface.",
    "icon": Icons.phone_android,
  },
  {
    "number": 3,
    "title": "Enable Projection",
    "description": "Tap the projection button in the challenge interface to start casting.",
    "icon": Icons.cast_connected,
  },
  {
    "number": 4,
    "title": "Adjust Position",
    "description": "Use the on-screen controls to adjust the projection size and position.",
    "icon": Icons.tune,
  },
  {
    "number": 5,
    "title": "Start Challenge",
    "description": "Once the projection is properly set up, you can begin your challenge session.",
    "icon": Icons.play_circle,
  },
];
// ================== 伪数据 END ==================

class ChallengeRulePage extends StatefulWidget {
  final String? challengeId;
  final String? challengeName;
  final String? challengeType;
  final String? challengeLevel;
  
  const ChallengeRulePage({
    Key? key,
    this.challengeId,
    this.challengeName,
    this.challengeType,
    this.challengeLevel,
  }) : super(key: key);

  @override
  State<ChallengeRulePage> createState() => _ChallengeRulePageState();

  static ChallengeRulePage fromRoute(Map<String, dynamic> arguments) {
    return ChallengeRulePage(
      challengeId: arguments['challengeId'] as String?,
      challengeName: arguments['challengeName'] as String?,
      challengeType: arguments['challengeType'] as String?,
      challengeLevel: arguments['challengeLevel'] as String?,
    );
  }
}

class _ChallengeRulePageState extends State<ChallengeRulePage> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isProjectionTutorialVisible = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double horizontalPad = constraints.maxWidth < 600 ? 16 : 48;
          final double cardPad = constraints.maxWidth < 600 ? 16 : 28;
          final double cardRadius = constraints.maxWidth < 600 ? 16 : 22;
          final double buttonHeight = constraints.maxWidth < 600 ? 52 : 60;
          final double buttonRadius = constraints.maxWidth < 600 ? 14 : 18;
          final double sectionGap = constraints.maxWidth < 600 ? 16 : 28;
          final double cardGap = constraints.maxWidth < 600 ? 14 : 22;
          final double bottomGap = constraints.maxWidth < 600 ? 24 : 40;
          final double topGap = constraints.maxWidth < 600 ? 16 : 32;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: _buildBackButton(),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderBackground(),
                ),
              ),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPad, topGap, horizontalPad, bottomGap),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChallengeInfoCard(cardPad, cardRadius),
                            SizedBox(height: cardGap),
                            _buildChallengeRulesCard(cardPad, cardRadius),
                            SizedBox(height: cardGap),
                            _buildProjectionTutorialCard(cardPad, cardRadius),
                            SizedBox(height: sectionGap),
                            _buildStartChallengeButton(buttonHeight, buttonRadius),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Challenge Rules',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get ready for your challenge',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeInfoCard(double pad, double radius) {
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(pad * 0.7),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(radius * 0.75),
            ),
            child: Icon(
              Icons.emoji_events,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          SizedBox(width: pad * 0.7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fakeChallengeInfo["name"] ?? 'Challenge',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${fakeChallengeInfo["type"] ?? 'Competition'} • ${fakeChallengeInfo["level"] ?? 'All Levels'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeRulesCard(double pad, double radius) {
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(pad * 0.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(radius * 0.5),
                ),
                child: Icon(
                  Icons.rule,
                  color: const Color(0xFF6366F1),
                  size: 18,
                ),
              ),
              SizedBox(width: pad * 0.5),
              Text(
                'Challenge Rules',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: pad * 0.7),
          ...fakeChallengeRules.map((rule) => Padding(
            padding: EdgeInsets.only(bottom: pad * 0.5),
            child: _buildRuleItem(
              icon: rule["icon"],
              title: rule["title"],
              description: rule["description"],
              color: rule["color"],
              pad: pad,
              radius: radius,
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required double pad,
    required double radius,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(pad * 0.35),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(radius * 0.45),
          ),
          child: Icon(
            icon,
            color: color,
            size: 15,
          ),
        ),
        SizedBox(width: pad * 0.5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                  height: 1.32,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectionTutorialCard(double pad, double radius) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: _showProjectionTutorial,
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(pad * 0.7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(radius * 0.7),
                  ),
                  child: Icon(
                    Icons.cast,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                SizedBox(width: pad * 0.7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projection Tutorial',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Learn how to project your challenge to a flat surface',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartChallengeButton(double height, double radius) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: _startChallenge,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: height * 0.42,
                ),
                SizedBox(width: height * 0.18),
                Flexible(
                  child: Text(
                    'Start Challenge',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: height * 0.38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProjectionTutorial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectionTutorialSheet(),
    );
  }

  void _startChallenge() {
    // 跳转到 ChallengeGamePage，携带 challengeId 参数
    final id = widget.challengeId;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge id not found.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Ready to Start?',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Make sure you have completed all the setup steps and are ready to begin your challenge session.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.challengeGame,
                arguments: {'challengeId': id},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Start',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
