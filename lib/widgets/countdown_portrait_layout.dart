import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'floating_logo.dart';
import 'circle_progress_painter.dart';
import 'layout_bg_type.dart';

class CountdownPortraitLayout extends StatelessWidget {
  final int totalRounds;
  final int currentRound;
  final int counter;
  final int countdown;
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
  final Widget videoWidget;
  final Widget selfieWidget;
  final LayoutBgType bgType;
  final VoidCallback onBgSwitchPressed;
  final Color dynamicBgColor;
  final bool isSubmittingResult; // 新增：是否正在提交结果

  const CountdownPortraitLayout({
    Key? key,
    required this.totalRounds,
    required this.currentRound,
    this.counter = 0,
    required this.countdown,
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
    required this.videoWidget,
    required this.selfieWidget,
    required this.bgType,
    required this.onBgSwitchPressed,
    required this.dynamicBgColor,
    required this.isSubmittingResult, // 新增
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
    return Stack(
      children: [
        // 多种背景类型
        if (bgType == LayoutBgType.video)
          Positioned.fill(child: videoWidget)
        else if (bgType == LayoutBgType.selfie)
          Positioned.fill(child: selfieWidget)
        else if (bgType == LayoutBgType.black)
          Positioned.fill(child: Container(color: Colors.black))
        else
          Positioned.fill(child: Container(color: dynamicBgColor)),
        if (bgType == LayoutBgType.video)
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.18))),
        // 主内容
        PageView.builder(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalRounds,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  FloatingLogo(margin: EdgeInsets.only(top: 24)),
                  Positioned(
                    top: (MediaQuery.of(context).padding.top) + 32 + 48 + 24 + 10 + 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'ROUND  ${index + 1}/$totalRounds',
                        style: TextStyle(
                          fontSize: 28,
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
                  Center(
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
                                child: _buildMainCounter(context, diameter, isWarning, mainColor, progressGradient, trackColor),
                              )
                            : _buildMainCounter(context, diameter, isWarning, mainColor, progressGradient, trackColor),
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
                ],
              );
            },
          ),
        if (showResultOverlay)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onResultOverlayTap,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxWidth = constraints.maxWidth;
                  final double maxHeight = constraints.maxHeight;
                  final double iconSize = (maxWidth * 0.08 + 24).clamp(32.0, 64.0);
                  final double congratFont = (maxWidth * 0.032 + 8).clamp(12.0, 20.0);
                  final double infoFont = (maxWidth * 0.028 + 6).clamp(10.0, 16.0);
                  final double dateFont = (maxWidth * 0.022 + 5).clamp(8.0, 14.0);
                  final double buttonFont = (maxWidth * 0.026 + 6).clamp(10.0, 16.0);
                  final double buttonPadH = (maxWidth * 0.035).clamp(12.0, 24.0);
                  final double buttonPadV = (maxHeight * 0.015).clamp(8.0, 16.0);
                  final double buttonRadius = 12;
                  final double buttonGap = (maxWidth * 0.025).clamp(8.0, 16.0);
                  final double verticalSpacing = (maxHeight * 0.015).clamp(8.0, 16.0);
                  return Container(
                    color: Colors.black.withOpacity(0.7),
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events, color: AppColors.primary, size: iconSize),
                              SizedBox(height: verticalSpacing),
                              Text(
                                'Congratulations! You worked out for ${_formatTimeForDisplay(history[0]["seconds"])} in $totalRounds rounds.',
                                style: TextStyle(fontSize: congratFont, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: verticalSpacing),
                              // 显示今天该项目的累计运动时长和排名
                              if (history[0]["daySeconds"] == null) ...[
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
                                    Text('Today\'s total: Loading...', style: TextStyle(fontSize: dateFont, color: Colors.white70, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                SizedBox(height: verticalSpacing),
                              ] else ...[
                                Text(
                                  'Today\'s total: ${_formatTimeForDisplay(history[0]["daySeconds"])}',
                                  style: TextStyle(fontSize: dateFont, color: Colors.white70, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: verticalSpacing),
                              ],
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
                                    Text('Rank: Loading...', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ],
                                ),
                              ] else ...[
                                Text('Rank: ${history[0]["rank"]}', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                              Text('Date: ${history[0]["date"]}', style: TextStyle(fontSize: dateFont, color: Colors.white70)),
                              SizedBox(height: verticalSpacing * 2),
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        DraggableScrollableSheet(
          controller: draggableController,
          initialChildSize: 0.2,
          minChildSize: 0.12,
          maxChildSize: 0.70,
          builder: (context, scrollController) {
            return buildHistoryRanking(scrollController);
          },
        ),
        // 左上角返回按钮 & 右上角背景切换按钮同行
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          right: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 26),
                onPressed: onResultBack,
                splashRadius: 22,
                tooltip: 'Back',
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: Icon(Icons.switch_video_rounded, color: Colors.white.withOpacity(0.82), size: 28),
                  onPressed: onBgSwitchPressed,
                  splashRadius: 22,
                  tooltip: 'Switch Background',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  highlightColor: Colors.white.withOpacity(0.08),
                  hoverColor: Colors.white.withOpacity(0.10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainCounter(BuildContext context, double diameter, bool isWarning, Color mainColor, Gradient? progressGradient, Color trackColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: diameter,
          height: diameter,
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
        Container(
          width: diameter - 24,
          height: diameter - 24,
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
                      Icon(Icons.play_arrow_rounded, size: diameter / 2.2, color: mainColor),
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
                : null, // formatTime(countdown)单独放到外层
          ),
        ),
        if (isStarted)
          Positioned.fill(
            child: Center(
              child: Text(
                formatTime(countdown),
                style: TextStyle(
                  fontSize: diameter / 3.2,
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

  String _formatTimeForDisplay(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes == 0) {
      return '$remainingSeconds seconds';
    } else if (remainingSeconds == 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      return '$minutes minute${minutes == 1 ? '' : 's'} $remainingSeconds second${remainingSeconds == 1 ? '' : 's'}';
    }
  }
}
