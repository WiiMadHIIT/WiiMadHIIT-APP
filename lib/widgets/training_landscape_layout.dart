import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'floating_logo.dart';
import 'circle_progress_painter.dart';
import 'layout_bg_type.dart';

/// 横屏训练布局组件
/// 后续可在此文件内实现横屏专属的UI和交互
class TrainingLandscapeLayout extends StatelessWidget {
  // 训练总轮数
  final int totalRounds;
  // 当前轮次
  final int currentRound;
  // 当前计数
  final int counter;
  // 当前倒计时（秒）
  final int countdown;
  // 是否已开始
  final bool isStarted;
  // 是否正在计数
  final bool isCounting;
  // 是否显示预倒计时遮罩
  final bool showPreCountdown;
  // 预倒计时数字
  final int preCountdown;
  // 弹跳动画控制器
  final AnimationController bounceController;
  final Animation<double> bounceAnim;
  // 训练多轮切换的PageView控制器
  final PageController pageController;
  // 开始按钮回调
  final VoidCallback onStartPressed;

  // 背景色（动态变化）
  final Color dynamicBgColor;
  final LayoutBgType bgType;
  final Widget videoWidget;
  // 圆环直径
  final double diameter;
  // 格式化倒计时文本
  final String Function(int) formatTime;
  final int roundDuration; // 新增：轮次持续时间
  // 新增：结果遮罩和榜单参数
  final bool showResultOverlay;
  final List<Map<String, dynamic>> history;
  final DraggableScrollableController draggableController;
  final Widget Function(ScrollController) buildHistoryRanking;
  final VoidCallback onResultOverlayTap;
  final VoidCallback onResultReset;
  final VoidCallback onResultBack;
  final VoidCallback onResultSetup;
  final Widget? selfieWidget;
  final bool isSubmittingResult; // 新增：是否正在提交结果

  const TrainingLandscapeLayout({
    Key? key,
    required this.totalRounds,
    required this.currentRound,
    required this.counter,
    required this.countdown,
    required this.isStarted,
    required this.isCounting,
    required this.showPreCountdown,
    required this.preCountdown,
    required this.bounceController,
    required this.bounceAnim,
    required this.pageController,
    required this.onStartPressed,
    required this.dynamicBgColor,
    required this.bgType,
    required this.videoWidget,
    required this.diameter,
    required this.formatTime,
    required this.roundDuration, // 新增
    // 新增
    required this.showResultOverlay,
    required this.history,
    required this.draggableController,
    required this.buildHistoryRanking,
    required this.onResultOverlayTap,
    required this.onResultReset,
    required this.onResultBack,
    required this.onResultSetup,
    this.selfieWidget,
    required this.isSubmittingResult, // 新增
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 横屏下的主色、进度环渐变、轨道色
    final bool isWarning = isCounting && countdown <= 3;
    final Color mainColor = isWarning ? AppColors.primary : Color(0xFF00BF60);
    final Gradient? progressGradient = isWarning
        ? LinearGradient(
            colors: [Color(0xFF00FF7F), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : null;
    final Color trackColor = Color(0xFFF3F4F6);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double leftPanelWidth = screenWidth * 2 / 3;
    final double rightPanelWidth = screenWidth * 1 / 3;
    final double counterDiameter = screenHeight * 3 / 5;
    // 计算进度环顶部到屏幕顶部的距离百分比
    final double counterTop = (screenHeight - counterDiameter) / 2;
    final double logoTop = counterTop / 2 * 0.5;
    final double roundTextTop = screenHeight * 5 / 7;
    
    return Stack(
      children: [
        // 多种背景类型
        if (bgType == LayoutBgType.video)
          Positioned.fill(child: videoWidget)
        else if (bgType == LayoutBgType.selfie && selfieWidget != null)
          Positioned.fill(child: selfieWidget!)
        else if (bgType == LayoutBgType.black)
          Positioned.fill(child: Container(color: Colors.black))
        else
          Positioned.fill(child: Container(color: dynamicBgColor)),
        if (bgType == LayoutBgType.video)
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.18))),
        // 主内容
        Row(
          children: [
            // 左侧主计数器区域
            SizedBox(
              width: leftPanelWidth,
              height: screenHeight,
              child: Stack(
                children: [
                  Container(
                    width: leftPanelWidth,
                    height: screenHeight,
                    child: PageView.builder(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalRounds,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            // 顶部浮动Logo（动态距离，苹果美学）
                            FloatingLogoPlus(
                              scale: 0.8,
                              top: logoTop,
                            ),
                            // 顶部轮次文本（左对齐，离左侧10px）
                            Positioned(
                                top: logoTop - 16, // logo top + logo height + margin
                                left: 0,
                                right: 0,
                                child: Center(
                                    child: Text(
                                        'ROUND ${index + 1}/$totalRounds',
                                        style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                        shadows: [
                                            Shadow(
                                            color: Colors.black.withOpacity(0.18),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                            ),
                                        ],
                                        ),
                                    ),
                                ),
                            ),
                            // 主计数器
                            Align(
                              alignment: Alignment(0, 5/7*2-1), // y=5/7处
                              child: GestureDetector(
                                onTap: isStarted ? null : onStartPressed,
                                child: AnimatedBuilder(
                                  animation: bounceController,
                                  builder: (context, child) => Transform.scale(
                                    scale: bounceController.value,
                                    child: child,
                                  ),
                                  child: (bgType != LayoutBgType.color)
                                      ? Opacity(
                                          opacity: 0.82,
                                          child: _buildMainCounter(context, counterDiameter, isWarning, mainColor, progressGradient, trackColor),
                                        )
                                      : _buildMainCounter(context, counterDiameter, isWarning, mainColor, progressGradient, trackColor),
                                ),
                              ),
                            ),
                            // 预倒计时遮罩动画
                            if (showPreCountdown)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.7),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'ROUND ${currentRound}/$totalRounds',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                            shadows: [
                                              Shadow(color: Colors.black54, blurRadius: 12),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 400),
                                          switchInCurve: Curves.easeOutCubic,
                                          switchOutCurve: Curves.easeInCubic,
                                          layoutBuilder: (currentChild, previousChildren) => Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ...previousChildren,
                                              if (currentChild != null) currentChild,
                                            ],
                                          ),
                                          transitionBuilder: (child, anim) => FadeTransition(
                                            opacity: anim,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 0.4),
                                                end: Offset.zero,
                                              ).animate(anim),
                                              child: child,
                                            ),
                                          ),
                                          child: Text(
                                            '${preCountdown}',
                                            key: ValueKey(preCountdown),
                                            style: const TextStyle(
                                              fontSize: 120,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(color: Colors.black54, blurRadius: 12),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            // 结果遮罩只覆盖左侧
                            if (showResultOverlay)
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: onResultOverlayTap,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final double maxWidth = constraints.maxWidth;
                                      final double maxHeight = constraints.maxHeight;
                                      final double iconSize = maxWidth * 0.05 + 12;
                                      final double titleFont = maxWidth * 0.045 + 12;
                                      final double infoFont = maxWidth * 0.032 + 8;
                                      final double dateFont = maxWidth * 0.025 + 7;
                                      final double buttonFont = maxWidth * 0.030 + 8;
                                      final double buttonPadH = maxWidth * 0.045;
                                      final double buttonPadV = maxHeight * 0.018;
                                      final double buttonRadius = 16;
                                      final double buttonGap = maxWidth * 0.04;
                                      return Container(
                                        color: Colors.black.withOpacity(0.7),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                              // Icon(Icons.emoji_events, color: AppColors.primary, size: iconSize),
                                              // SizedBox(height: maxHeight * 0.01),
                                              Text('Training Complete!', style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                              SizedBox(height: maxHeight * 0.025),
                                              // 显示用户在totalRounds次挑战中的最佳成绩
                                              Text(
                                                'Best Score in $totalRounds Rounds',
                                                style: TextStyle(
                                                  fontSize: dateFont,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: maxHeight * 0.02),
                                              // 排名显示逻辑：如果为null则显示加载中，否则显示实际排名
                                              if (history[0]["rank"] == null) ...[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('RANK: Loading...', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                                  ],
                                                ),
                                              ] else ...[
                                                Text('RANK:  ${history[0]["rank"]}', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                              ],
                                              Text('COUNT:  ${history[0]["counts"]}', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: Colors.white)),
                                              Text('PACE:  ${history[0]["countsPerMin"]}/min', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: Colors.white)),
                                              Text('(Your speed demon rating! 🚀)', style: TextStyle(fontSize: dateFont, color: Colors.white60, fontStyle: FontStyle.italic)),
                                              Text('DATE:  ${history[0]["date"]}', style: TextStyle(fontSize: dateFont, color: Colors.white70)),
                                              SizedBox(height: maxHeight * 0.04),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: onResultReset,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors.primary,
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.symmetric(horizontal: buttonPadH, vertical: buttonPadV),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                                                      elevation: 8,
                                                    ),
                                                    child: Text('Restart', style: TextStyle(fontSize: buttonFont, fontWeight: FontWeight.bold)),
                                                  ),
                                                  SizedBox(width: buttonGap),
                                                  ElevatedButton(
                                                    onPressed: onResultSetup,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white,
                                                      foregroundColor: AppColors.primary,
                                                      padding: EdgeInsets.symmetric(horizontal: buttonPadH, vertical: buttonPadV),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                                                      elevation: 8,
                                                    ),
                                                    child: Text('Reset', style: TextStyle(fontSize: buttonFont, fontWeight: FontWeight.bold)),
                                                  ),
                                                  SizedBox(width: buttonGap),
                                                  OutlinedButton(
                                                    onPressed: onResultBack,
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: AppColors.primary,
                                                      side: BorderSide(color: AppColors.primary, width: 2),
                                                      padding: EdgeInsets.symmetric(horizontal: buttonPadH, vertical: buttonPadV),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                                                    ),
                                                    child: Text('Back', style: TextStyle(fontSize: buttonFont, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // 右侧榜单区域
            SizedBox(
              width: rightPanelWidth,
              height: screenHeight,
              child: DraggableScrollableSheet(
                controller: draggableController,
                initialChildSize: 1.0,
                minChildSize: 0.5,
                maxChildSize: 1.0,
                expand: true,
                builder: (context, scrollController) {
                  return buildHistoryRanking(scrollController);
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMainCounter(BuildContext context, double counterDiameter, bool isWarning, Color mainColor, Gradient? progressGradient, Color trackColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 进度环
        SizedBox(
          width: counterDiameter,
          height: counterDiameter,
          child: CustomPaint(
            painter: CircleProgressPainter(
              progress: isCounting ? countdown / roundDuration.toDouble() : 1.0,
              color: isWarning ? AppColors.primary : mainColor,
              gradient: isWarning ? null : progressGradient,
              trackColor: trackColor,
              shadow: mainColor.withOpacity(0.18),
              strokeWidth: 14,
            ),
          ),
        ),
        // 内部白色圆 - 参考elegant_refresh_button的透明效果
        Container(
          width: counterDiameter - 24,
          height: counterDiameter - 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 🎨 苹果风格渐变背景 - 透明效果
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.05),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            // 🎨 精致的边框
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            // 🎨 苹果风格阴影
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: !isStarted
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: counterDiameter / 2.2, color: mainColor),
                      SizedBox(height: 8),
                      Text(
                        'Tap to Start',
                        style: TextStyle(
                          fontSize: 18,
                          color: mainColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '${counter}',
                    style: TextStyle(
                      fontSize: counterDiameter / 3,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.5,
                    ),
                  ),
          ),
        ),
        // 倒计时数字
        if (isStarted && isCounting)
          Positioned(
            bottom: counterDiameter / 8,
            left: 0,
            right: 0,
            child: Text(
              formatTime(countdown),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: counterDiameter / 7,
                fontWeight: FontWeight.bold,
                color: mainColor,
                letterSpacing: 2,
              ),
            ),
          ),
      ],
    );
  }
}
