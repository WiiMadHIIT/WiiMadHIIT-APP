import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../domain/entities/challenge_details/challenge_details.dart';

/// 苹果风格的高级挑战规则详情上弹窗口
/// 设计理念：简洁、优雅、现代化，符合苹果设计语言
class ChallengeRulesSheet extends StatefulWidget {
  final ChallengeRules rules;
  final String challengeName;
  
  const ChallengeRulesSheet({
    Key? key,
    required this.rules,
    required this.challengeName,
  }) : super(key: key);

  @override
  State<ChallengeRulesSheet> createState() => _ChallengeRulesSheetState();
}

class _ChallengeRulesSheetState extends State<ChallengeRulesSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 滑动动画控制器
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    // 淡入动画控制器
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 从底部滑入的动画
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // 淡入动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // 启动动画
    _fadeController.forward();
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  /// 关闭动画
  Future<void> _closeSheet() async {
    await Future.wait([
      _slideController.reverse(),
      _fadeController.reverse(),
    ]);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85; // 最大高度为屏幕的85%
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black.withOpacity(0.4 * _fadeAnimation.value),
            child: GestureDetector(
              onTap: _closeSheet,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 点击空白区域关闭
                    Expanded(
                      child: GestureDetector(
                        onTap: _closeSheet,
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    // 规则详情卡片
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: maxHeight,
                          minHeight: 200,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, -10),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 60,
                              offset: const Offset(0, -20),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 顶部拖拽指示器
                            _buildDragHandle(),
                            
                            // 标题区域
                            _buildHeader(),
                            
                            // 规则内容区域
                            Flexible(
                              child: _buildRulesContent(),
                            ),
                            
                            // 底部操作区域
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 构建拖拽指示器
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
  
  /// 构建标题区域
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 挑战名称
          Text(
            widget.challengeName,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 22,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // 规则标题
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rule,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.rules.title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建规则内容区域 - 苹果风格的精简设计
  Widget _buildRulesContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 规则项目列表 - 主要展示内容
            if (widget.rules.items.isNotEmpty) ...[
              // 优雅的标题设计
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Rules & Guidelines',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // 规则项目列表
              ...widget.rules.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 苹果风格的序号徽章
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // 规则内容卡片
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[100]!,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            item,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.grey[800],
                              height: 1.6,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else ...[
              // 空状态设计
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rule_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No rules available',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rules will be updated soon',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // 底部间距
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  /// 构建底部操作区域 - 苹果风格的单按钮设计
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[100]!,
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _closeSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              // 苹果风格的按钮样式
              textStyle: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                letterSpacing: -0.4,
              ),
            ),
            child: const Text('Got it'),
          ),
        ),
      ),
    );
  }
}

/// 显示挑战规则详情的便捷方法
void showChallengeRulesSheet({
  required BuildContext context,
  required ChallengeRules rules,
  required String challengeName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (context) => ChallengeRulesSheet(
      rules: rules,
      challengeName: challengeName,
    ),
  );
}
