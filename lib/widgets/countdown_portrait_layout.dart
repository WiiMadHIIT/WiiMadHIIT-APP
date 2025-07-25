import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'floating_logo.dart';
import 'circle_progress_painter.dart';

// 竖屏倒计时训练布局
class CountdownPortraitLayout extends StatelessWidget {
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
  final Color dynamicBgColor;
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

  const CountdownPortraitLayout({
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
    required this.dynamicBgColor,
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
        Container(
          color: dynamicBgColor,
        ),
        Container(
          color: Colors.transparent,
          child: PageView.builder(
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
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
                            Opacity(
                              opacity: 0.82,
                              child: Container(
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
                            // 不再需要底部倒计时
                          ],
                        ),
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
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: AppColors.primary, size: 64),
                      SizedBox(height: 24),
                      Text('Training Complete!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      SizedBox(height: 16),
                      Text(
                        'Congratulations! You worked out for ${history[0]["minutes"]} minutes.',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 18),
                      Text('RANK:  ${history[0]["rank"]}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text('ROUNDS:  $totalRounds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('DATE:  ${history[0]["date"]}', style: TextStyle(fontSize: 18, color: Colors.white70)),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: onResultReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('Try Again', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(width: 24),
                          ElevatedButton(
                            onPressed: onResultSetup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('Reset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(width: 24),
                          OutlinedButton(
                            onPressed: onResultBack,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary, width: 2),
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('Back', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 26),
            onPressed: onResultBack,
            splashRadius: 22,
          ),
        ),
      ],
    );
  }
}
