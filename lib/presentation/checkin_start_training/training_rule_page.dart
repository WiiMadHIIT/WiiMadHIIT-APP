import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import 'dart:ui';
import 'dart:math';
import '../../routes/app_routes.dart';
import '../../widgets/projection_tutorial_sheet.dart';
import '../../domain/entities/training_rule.dart';
import '../../domain/entities/projection_tutorial.dart';
import '../../domain/entities/training_config.dart';
import 'training_rule_viewmodel.dart';



class TrainingRulePage extends StatelessWidget {
  final String? trainingId;
  final String? productId;
  
  const TrainingRulePage({
    Key? key,
    this.trainingId,
    this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TrainingRuleViewModel(),
      child: _TrainingRulePageContent(trainingId: trainingId, productId: productId),
    );
  }
}

class _TrainingRulePageContent extends StatefulWidget {
  final String? trainingId;
  final String? productId;
  
  const _TrainingRulePageContent({
    Key? key,
    this.trainingId,
    this.productId,
  }) : super(key: key);

  @override
  State<_TrainingRulePageContent> createState() => _TrainingRulePageContentState();
}

class _TrainingRulePageContentState extends State<_TrainingRulePageContent> 
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
    
    // 加载训练规则数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<TrainingRuleViewModel>(context, listen: false);
      if (widget.trainingId != null && widget.productId != null) {
        viewModel.loadTrainingRule(widget.trainingId!, widget.productId!);
      }
    });
  }

  /// 获取随机图标
  IconData _getRandomIcon() {
    final random = Random();
    final icons = [
      Icons.settings,
      Icons.timer,
      Icons.check_circle,
      Icons.warning,
      Icons.info,
      Icons.help,
      Icons.security,
      Icons.sports_esports,
      Icons.fitness_center,
      Icons.health_and_safety,
      Icons.psychology,
      Icons.science,
      Icons.engineering,
      Icons.build,
      Icons.construction,
      Icons.handyman,
      Icons.precision_manufacturing,
      Icons.memory,
      Icons.speed,
      Icons.tune,
    ];
    return icons[random.nextInt(icons.length)];
  }

  /// 获取随机颜色
  Color _getRandomColor() {
    final random = Random();
    final colors = [
      const Color(0xFF10B981), // 绿色
      const Color(0xFFF59E0B), // 橙色
      const Color(0xFFEF4444), // 红色
      const Color(0xFF3B82F6), // 蓝色
      const Color(0xFF8B5CF6), // 紫色
      const Color(0xFF06B6D4), // 青色
      const Color(0xFF84CC16), // 青绿色
      const Color(0xFFF97316), // 深橙色
      const Color(0xFFEC4899), // 粉色
      const Color(0xFF6366F1), // 靛蓝色
    ];
    return colors[random.nextInt(colors.length)];
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
      body: Consumer<TrainingRuleViewModel>(
        builder: (context, viewModel, child) {
          // 显示加载状态
          if (viewModel.isLoading) {
            return _buildLoadingState();
          }

          // 显示错误状态
          if (viewModel.hasError) {
            return _buildErrorState(viewModel);
          }

          // 显示数据状态
          return LayoutBuilder(
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
                                if (viewModel.hasTrainingRules)
                                  _buildTrainingRulesCard(cardPad, cardRadius, viewModel),
                                if (viewModel.hasTrainingRules) SizedBox(height: cardGap),
                                if (viewModel.hasProjectionTutorial)
                                  _buildProjectionTutorialCard(cardPad, cardRadius, viewModel),
                                if (viewModel.hasProjectionTutorial) SizedBox(height: sectionGap),
                                _buildStartTrainingButton(buttonHeight, buttonRadius, viewModel),
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
          // 装饰性背景图案
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
          
          // 标题内容
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Rules',
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
                  'Get ready for your workout',
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

  Widget _buildTrainingRulesCard(double pad, double radius, TrainingRuleViewModel viewModel) {
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
                'Training Rules',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: pad * 0.7),
          ...viewModel.sortedTrainingRules.map((rule) => Padding(
            padding: EdgeInsets.only(bottom: pad * 0.5),
            child: _buildRuleItem(
              icon: _getRandomIcon(),
              title: rule.displayTitle,
              description: rule.displayDescription,
              color: _getRandomColor(),
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

  Widget _buildProjectionTutorialCard(double pad, double radius, TrainingRuleViewModel viewModel) {
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
          onTap: () => _showProjectionTutorial(viewModel),
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
                        'Learn how to project your training to a flat surface',
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

  Widget _buildStartTrainingButton(double height, double radius, TrainingRuleViewModel viewModel) {
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
          onTap: () => _startTraining(viewModel),
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
                    'Start Training',
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

  void _showProjectionTutorial(TrainingRuleViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectionTutorialSheet(),
    );
  }



  void _startTraining(TrainingRuleViewModel viewModel) {
    // 显示确认对话框
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 320,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部图标区域
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Ready to Start?',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // 内容区域
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Make sure you have completed all the setup steps and are ready to begin your training session.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // 按钮区域
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // 根据训练配置动态跳转到相应页面
                                _navigateToTrainingPage(viewModel);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 根据训练配置动态跳转到相应的训练页面
  void _navigateToTrainingPage(TrainingRuleViewModel viewModel) {
    // 从ViewModel获取的 trainingConfig.nextPageRoute 决定跳转目标
    final nextPageRoute = viewModel.nextPageRoute;
    
    Navigator.pushNamed(
      context,
      nextPageRoute,
      arguments: {
        'trainingId': widget.trainingId,
        'productId': widget.productId,
      },
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading training rules...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(TrainingRuleViewModel viewModel) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // 返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: _buildBackButton(),
          ),
          // 错误内容
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load training rules',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error ?? 'Unknown error occurred',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}