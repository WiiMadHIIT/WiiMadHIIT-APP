import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'floating_logo.dart';
import 'circle_progress_painter.dart';
import 'layout_bg_type.dart';

class CountdownLandscapeLayout extends StatelessWidget {
  final int totalRounds;
  final int currentRound;
  final int counter;
  final int countdown;
  final int roundDuration;
  final bool isStarted;
  final bool isCounting;
  final bool showPreCountdown;
  final int preCountdown;
  final AnimationController bounceController;
  final Animation<double> bounceAnim;
  final PageController pageController;
  final VoidCallback onStartPressed;
  final VoidCallback onCountPressed;
  final double diameter;
  final String Function(int) formatTime;
  final bool showResultOverlay;
  final List<Map<String, dynamic>> history;
  final DraggableScrollableController draggableController;
  final Widget Function(ScrollController) buildHistoryRanking;
  final VoidCallback onResultOverlayTap;
  final VoidCallback onResultReset;
  final VoidCallback onResultBack;
  final VoidCallback onResultSetup;
  final Widget videoWidget;
  final LayoutBgType bgType;

  const CountdownLandscapeLayout({
    Key? key,
    required this.totalRounds,
    required this.currentRound,
    this.counter = 0,
    required this.countdown,
    required this.roundDuration,
    required this.isStarted,
    required this.isCounting,
    required this.showPreCountdown,
    required this.preCountdown,
    required this.bounceController,
    required this.bounceAnim,
    required this.pageController,
    required this.onStartPressed,
    required this.onCountPressed,
    required this.diameter,
    required this.formatTime,
    required this.showResultOverlay,
    required this.history,
    required this.draggableController,
    required this.buildHistoryRanking,
    required this.onResultOverlayTap,
    required this.onResultReset,
    required this.onResultBack,
    required this.onResultSetup,
    required this.videoWidget,
    required this.bgType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    final double logoTop = (screenHeight - counterDiameter) / 2 * 0.5;

    return Stack(
      children: [
        // 多种背景类型
        if (bgType == LayoutBgType.video)
          Positioned.fill(child: videoWidget)
        else if (bgType == LayoutBgType.black)
          Positioned.fill(child: Container(color: Colors.black))
        else
          Positioned.fill(child: Container(color: Colors.transparent)),
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
                  // 顶部浮动Logo（动态距离，苹果美学）
                  FloatingLogoPlus(
                    scale: 0.8,
                    top: logoTop,
                  ),
                  // 顶部轮次文本（左对齐，离左侧10px）
                  Positioned(
                    top: logoTop - 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'ROUND $currentRound/$totalRounds',
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
                  // 主计数器整体位置
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
                  if (showPreCountdown)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ROUND $currentRound/$totalRounds',
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
                                  '$preCountdown',
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
                  if (showResultOverlay)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onResultOverlayTap,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double maxWidth = constraints.maxWidth;
                            final double maxHeight = constraints.maxHeight;
                            final double iconSize = maxWidth * 0.10 + 32;
                            final double titleFont = maxWidth * 0.045 + 12;
                            final double congratFont = maxWidth * 0.035 + 10;
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
                                    Icon(Icons.emoji_events, color: AppColors.primary, size: iconSize),
                                    SizedBox(height: maxHeight * 0.03),
                                    Text(
                                      'Congratulations! You worked out for ${history[0]["minutes"]} minutes.',
                                      style: TextStyle(fontSize: congratFont, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: maxHeight * 0.025),
                                    Text('RANK:  ${history[0]["rank"]}', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    Text('ROUNDS:  $totalRounds', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: Colors.white)),
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
        ),
      ],
    );
  }

  Widget _buildMainCounter(BuildContext context, double counterDiameter, bool isWarning, Color mainColor, Gradient? progressGradient, Color trackColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: counterDiameter,
          height: counterDiameter,
          child: CustomPaint(
            painter: CircleProgressPainter(
              progress: isCounting ? countdown / 60.0 : 1.0,
              color: isWarning ? AppColors.primary : mainColor,
              gradient: isWarning ? null : progressGradient,
              trackColor: trackColor,
              shadow: mainColor.withOpacity(0.18),
              strokeWidth: 14,
            ),
          ),
        ),
        Container(
          width: counterDiameter - 24,
          height: counterDiameter - 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F9FB), Color(0xFFEDEEF2)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 22,
                offset: Offset(0, 6),
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
                : null,
          ),
        ),
        if (isStarted)
          Positioned.fill(
            child: Center(
              child: Text(
                formatTime(countdown),
                style: TextStyle(
                  fontSize: counterDiameter / 3.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
