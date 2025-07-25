import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'floating_logo.dart';
import 'circle_progress_painter.dart';
import 'layout_bg_type.dart';

// 竖屏训练布局
class TrainingPortraitLayout extends StatelessWidget {
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
  final Color dynamicBgColor;
  final VoidCallback onBgSwitchPressed;
  final LayoutBgType bgType;
  final Widget videoWidget;
  final double diameter;
  final String Function(int) formatTime;
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

  const TrainingPortraitLayout({
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
    required this.onCountPressed,
    required this.dynamicBgColor,
    required this.onBgSwitchPressed,
    required this.bgType,
    required this.videoWidget,
    required this.diameter,
    required this.formatTime,
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
        else if (bgType == LayoutBgType.selfie && selfieWidget != null)
          Positioned.fill(child: selfieWidget!)
        else if (bgType == LayoutBgType.black)
          Positioned.fill(child: Container(color: Colors.black))
        else
          Positioned.fill(child: Container(color: dynamicBgColor)),
        if (bgType == LayoutBgType.video)
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.18))),
        // 全屏黑色高透明遮罩
        // Container(
        //   color: Colors.black.withOpacity(0.38),
        // ),
        Container(
          color: Colors.transparent,
          child: PageView.builder(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalRounds,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // 浮动Logo（顶部到中间区域悬浮）
                  FloatingLogo(margin: EdgeInsets.only(top: 24)),
                  // ROUND文本放在FloatingLogo下方
                  Positioned(
                    top: (MediaQuery.of(context).padding.top) + 32 + 48 + 24 + 10 + 14, // logo top + logo height + margin
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'ROUND ${index + 1}/$totalRounds',
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
                      onTap: isStarted && isCounting ? onCountPressed : (isStarted ? null : onStartPressed),
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
                  // 遮罩倒计时动画
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
                ],
              );
            },
          ),
        ),
        // 结果遮罩全屏
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
                  final double iconSize = maxWidth * 0.10 + 32;
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
                          Icon(Icons.emoji_events, color: AppColors.primary, size: iconSize),
                          SizedBox(height: maxHeight * 0.03),
                          Text('Training Complete!', style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          SizedBox(height: maxHeight * 0.025),
                          Text('RANK:  ${history[0]["rank"]}', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          Text('COUNT:  ${history[0]["counts"]}', style: TextStyle(fontSize: infoFont, fontWeight: FontWeight.bold, color: Colors.white)),
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
        // 唯一的DraggableScrollableSheet始终在最上层
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
        // 进度条
        SizedBox(
          width: diameter,
          height: diameter,
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
        // 内部白色圆
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
                : Text(
                    '${counter}',
                    style: TextStyle(
                      fontSize: diameter / 3,
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
            bottom: diameter / 8,
            left: 0,
            right: 0,
            child: Text(
              formatTime(countdown),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: diameter / 7,
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
