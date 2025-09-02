 import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'floating_logo.dart';
import 'circle_progress_painter.dart';
import 'layout_bg_type.dart';

// 竖屏挑战游戏布局
class ChallengePortraitLayout extends StatelessWidget {
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
  final Color dynamicBgColor;
  final VoidCallback onBgSwitchPressed;
  final LayoutBgType bgType;
  final Widget videoWidget;
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
  final Widget? selfieWidget;
  final bool isSubmittingResult; // 新增：是否正在提交结果
  final int allowedTimes; // 🎯 新增：剩余尝试次数

  const ChallengePortraitLayout({
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
    required this.onBgSwitchPressed,
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
    required this.allowedTimes, // 🎯 新增：剩余尝试次数
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
                  
                  // 🎯 响应式尺寸计算，防止溢出，同时保证良好的用户体验
                  final double iconSize = (maxWidth * 0.08 + 20).clamp(24.0, 40.0);
                  final double titleFont = (maxWidth * 0.06 + 16).clamp(18.0, 28.0); // 🎯 增大标题字体
                  final double infoFont = (maxWidth * 0.032 + 8).clamp(12.0, 18.0); // 🎯 增大信息字体
                  final double dateFont = (maxWidth * 0.026 + 6).clamp(10.0, 16.0); // 🎯 增大日期字体
                  final double buttonFont = (maxWidth * 0.030 + 8).clamp(12.0, 18.0); // 🎯 增大按钮字体
                  final double buttonPadH = (maxWidth * 0.04 + 8).clamp(12.0, 24.0);
                  final double buttonPadV = (maxHeight * 0.016 + 4).clamp(8.0, 16.0);
                  final double buttonRadius = 16;
                  final double buttonGap = (maxWidth * 0.035 + 4).clamp(8.0, 20.0);
                  return Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          // Icon(Icons.emoji_events, color: AppColors.primary, size: iconSize * 0.8), // 🎯 减小图标尺寸
                          // SizedBox(height: maxHeight * 0.025),
                          Text('Challenge Complete!', style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          SizedBox(height: maxHeight * 0.02),
                          // 🎯 添加剩余次数提示
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: allowedTimes > 0 ? AppColors.primary.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: allowedTimes > 0 ? AppColors.primary.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              allowedTimes > 0 
                                  ? '${allowedTimes} attempts remaining' 
                                  : 'No attempts left',
                              style: TextStyle(
                                fontSize: infoFont * 0.9,
                                color: allowedTimes > 0 ? AppColors.primary : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: maxHeight * 0.02),
                          // 显示用户在totalRounds次挑战中的最佳成绩
                          Text(
                            'Best Score in $totalRounds Rounds',
                            style: TextStyle(
                              fontSize: dateFont,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: maxHeight * 0.015),
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
                          Text('DATE:  ${history[0]["date"]}', style: TextStyle(fontSize: dateFont, color: Colors.white70)),
                          SizedBox(height: maxHeight * 0.04),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: allowedTimes > 0 ? onResultReset : null, // 🎯 检查剩余尝试次数
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: allowedTimes > 0 ? AppColors.primary : Colors.grey, // 🎯 根据剩余次数设置颜色
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: buttonPadH, vertical: buttonPadV),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                                  elevation: allowedTimes > 0 ? 8 : 0, // 🎯 根据剩余次数设置阴影
                                ),
                                child: Text(
                                  allowedTimes > 0 ? 'Restart (${allowedTimes})' : 'No Attempts', // 🎯 显示剩余次数或简洁提示
                                  style: TextStyle(fontSize: buttonFont, fontWeight: FontWeight.bold),
                                ),
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
              progress: isCounting ? countdown / roundDuration.toDouble() : 1.0,
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