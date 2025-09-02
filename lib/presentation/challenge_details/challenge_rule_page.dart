import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/auth_guard_mixin.dart';
import 'dart:ui';
import 'dart:math';
import '../../routes/app_routes.dart';
import '../../widgets/projection_tutorial_sheet.dart';
import '../../widgets/training_error_content.dart';
import '../../widgets/training_loading_content.dart';
import '../../domain/entities/challenge_rule/challenge_rule.dart';
import '../../domain/entities/challenge_rule/challenge_config.dart';
import 'challenge_rule_viewmodel.dart';

/// 挑战规则页面，显示挑战规则、投影教程和开始挑战按钮
class ChallengeRulePage extends StatelessWidget {
  final String? challengeId;
  
  const ChallengeRulePage({
    Key? key,
    this.challengeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChallengeRuleViewModel(),
      // 🎯 苹果级优化：确保Provider在页面退出时自动清理
      // Provider会自动调用ViewModel的dispose方法
      child: _ChallengeRulePageContent(challengeId: challengeId),
    );
  }

  /// 从路由参数获取挑战ID
  String _getChallengeId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['challengeId'] as String? ?? 'default';
  }
}

class _ChallengeRulePageContent extends StatefulWidget {
  final String? challengeId;
  
  const _ChallengeRulePageContent({
    Key? key,
    this.challengeId,
  }) : super(key: key);

  @override
  State<_ChallengeRulePageContent> createState() => _ChallengeRulePageContentState();
}

class _ChallengeRulePageContentState extends State<_ChallengeRulePageContent> 
    with TickerProviderStateMixin, AuthGuardMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isProjectionTutorialVisible = false;
  
  // 🎯 添加 ViewModel 引用，用于管理生命周期
  ChallengeRuleViewModel? _viewModel;
  
  // 🎯 添加异步操作取消标志
  bool _mounted = true;

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
    
    // 🎯 在第一个帧渲染后智能加载挑战规则数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        _viewModel = Provider.of<ChallengeRuleViewModel>(context, listen: false);
        // 优先使用 widget.challengeId，失败时回退到路由参数
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final challengeId = widget.challengeId ?? 
            args?['challengeId'] as String? ?? 
            'default';
        if (challengeId != 'default') {
          // 🎯 苹果级优化：智能判断是否需要重新加载数据
          if (_viewModel!.needsReload) {
            print('🎯 Loading challenge rule data for: $challengeId');
            _viewModel!.loadChallengeRule(challengeId);
          } else {
            print('🎯 Using cached challenge rule data for: $challengeId');
          }
        }
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
  
  /// 🎯 苹果级优化：清理ViewModel中的内存数据
  void _cleanupViewModelData() {
    try {
      if (mounted && _viewModel != null) {
        // 🎯 使用智能清理策略：保留核心数据，避免重新请求API
        _viewModel!.smartCleanup();
        
        print('🎯 ChallengeRuleViewModel smart cleanup completed');
      }
    } catch (e) {
      print('⚠️ Warning: Error cleaning up ChallengeRuleViewModel data: $e');
    }
  }

  void _startAnimations() async {
    // 🎯 检查组件是否仍然挂载
    if (!_mounted) return;
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_mounted) return;
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_mounted) return;
    _slideController.forward();
  }

  @override
  void dispose() {
    // 🎯 标记组件已销毁
    _mounted = false;
    
    // 🎯 释放动画控制器
    _fadeController.dispose();
    _slideController.dispose();
    
    // 🎯 苹果级优化：清理ViewModel中的内存数据
    _cleanupViewModelData();
    
    // 🎯 清理 ViewModel 引用
    _viewModel = null;
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<ChallengeRuleViewModel>(
        builder: (context, viewModel, child) {
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
                  // 🎯 SliverAppBar 始终可见，提供一致的导航体验
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
                  // 🎯 内容区域：根据状态显示不同内容
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
                                // 🎯 根据状态显示不同内容
                                if (viewModel.isLoading)
                                  TrainingRuleLoadingContent()
                                else if (viewModel.hasError)
                                  TrainingRuleErrorContent(
                                    onRetry: () => viewModel.refresh(),
                                  )
                                else ...[
                                  // 🎯 正常数据状态
                                  if (viewModel.hasChallengeRules)
                                    _buildChallengeRulesCard(cardPad, cardRadius, viewModel),
                                  if (viewModel.hasChallengeRules) SizedBox(height: cardGap),
                                  if (viewModel.hasProjectionTutorial)
                                    _buildProjectionTutorialCard(cardPad, cardRadius, viewModel),
                                  if (viewModel.hasProjectionTutorial) SizedBox(height: sectionGap),
                                  _buildStartChallengeButton(buttonHeight, buttonRadius, viewModel),
                                ],
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

  Widget _buildChallengeRulesCard(double pad, double radius, ChallengeRuleViewModel viewModel) {
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
          ...viewModel.sortedChallengeRules.map((rule) => Padding(
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

  Widget _buildProjectionTutorialCard(double pad, double radius, ChallengeRuleViewModel viewModel) {
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

  Widget _buildStartChallengeButton(double height, double radius, ChallengeRuleViewModel viewModel) {
    // 🎯 根据挑战状态决定按钮样式和功能
    final bool canStart = viewModel.canStartChallenge;
    final Color buttonColor = canStart ? AppColors.primary : Colors.grey;
    final Color textColor = canStart ? Colors.white : Colors.grey[600]!;
    
    // 🎯 智能文本处理：根据状态和文本长度选择合适的显示方式
    String displayText;
    double fontSize;
    int maxLines;
    bool showInfoIcon = false;
    
    if (canStart) {
      // 可以开始挑战 - 显示简洁的"Start Challenge"
      displayText = 'Start Challenge';
      fontSize = height * 0.38;
      maxLines = 1;
      showInfoIcon = false;
    } else {
      // 不能开始挑战 - 智能处理状态描述文本
      final statusText = viewModel.challengeStatusDescription;
      
      // 根据文本长度选择不同的显示策略
      if (statusText.length <= 20) {
        // 短文本：直接显示，保持按钮美观
        displayText = statusText;
        fontSize = height * 0.38;
        maxLines = 1;
        showInfoIcon = false;
      } else if (statusText.length <= 35) {
        // 中等长度：稍微缩小字体，保持单行
        displayText = statusText;
        fontSize = height * 0.32;
        maxLines = 1;
        showInfoIcon = false;
      } else {
        // 长文本：显示简化版本，添加信息图标提示
        displayText = _getSimplifiedStatusText(statusText);
        fontSize = height * 0.35;
        maxLines = 1;
        showInfoIcon = true;
      }
    }
    
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: canStart ? [
            buttonColor,
            buttonColor.withOpacity(0.8),
          ] : [
            Colors.grey[300]!,
            Colors.grey[300]!,
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: canStart ? [
          BoxShadow(
            color: buttonColor.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: canStart ? () => _startChallenge(viewModel) : () => _showStatusDetails(viewModel),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canStart ? Icons.play_arrow : (showInfoIcon ? Icons.info_outline : Icons.lock),
                  color: textColor,
                  size: height * 0.42,
                ),
                SizedBox(width: height * 0.18),
                Flexible(
                  child: Text(
                    displayText,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 🎯 长文本时显示提示箭头
                if (showInfoIcon) ...[
                  SizedBox(width: height * 0.12),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textColor.withOpacity(0.7),
                    size: height * 0.25,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 获取简化的状态文本，保持按钮美观
  String _getSimplifiedStatusText(String fullText) {
    if (fullText.contains('not activated')) {
      return 'Challenge Not Activated';
    } else if (fullText.contains('qualification')) {
      return 'Qualification Required';
    } else if (fullText.contains('equipment')) {
      return 'Equipment Required';
    } else if (fullText.contains('ready')) {
      return 'Ready to Start';
    } else {
      // 默认截取前20个字符
      return fullText.length > 20 ? '${fullText.substring(0, 20)}...' : fullText;
    }
  }

  /// 🎯 显示详细状态信息对话框
  void _showStatusDetails(ChallengeRuleViewModel viewModel) {
    final statusText = viewModel.challengeStatusDescription;
    final isActivated = viewModel.isActivated;
    final isQualified = viewModel.isQualified;
    
    // 根据状态生成详细说明
    String title;
    String content;
    IconData icon;
    Color iconColor;
    
    if (!isActivated && !isQualified) {
      title = 'Equipment & Activation Required';
      content = 'You need to obtain the required challenge equipment and activate the challenge before participating. Please check our equipment store and complete the activation process.';
      icon = Icons.shopping_cart;
      iconColor = Colors.orange;
    } else if (!isActivated) {
      title = 'Challenge Not Activated';
      content = 'This challenge is not currently activated. Please wait for the challenge to be activated or contact support for assistance.';
      icon = Icons.pause_circle;
      iconColor = Colors.red;
    } else {
      title = 'Qualification Required';
      content = 'You need to meet the challenge requirements and rules before participating. Please review the challenge conditions and complete the qualification process.';
      icon = Icons.assignment;
      iconColor = Colors.amber;
    }
    
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
            maxHeight: MediaQuery.of(context).size.height * 0.7,
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
                      iconColor,
                      iconColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
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
                        content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // 按钮区域
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: iconColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Got it',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  void _showProjectionTutorial(ChallengeRuleViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectionTutorialSheet(),
    );
  }

  void _startChallenge(ChallengeRuleViewModel viewModel) {
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
                        'Ready to unleash your inner champion? Let\'s make some magic happen! ✨',
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
                                _navigateToChallengePage(viewModel);
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

  /// 根据挑战配置动态跳转到相应的挑战页面
  void _navigateToChallengePage(ChallengeRuleViewModel viewModel) {
    // 从ViewModel获取的 challengeConfig.nextPageRoute 决定跳转目标
    final nextPageRoute = viewModel.nextPageRoute;
    
    Navigator.pushNamed(
      context,
      nextPageRoute,
      arguments: {
        'challengeId': widget.challengeId,
        'totalRounds': viewModel.totalRounds,
        'roundDuration': viewModel.roundDuration,
        'allowedTimes': viewModel.allowedTimes, // 🎯 新增：传递剩余挑战次数
      },
    );
  }
}

