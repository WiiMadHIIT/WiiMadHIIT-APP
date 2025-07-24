import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'floating_logo.dart';
import 'circle_progress_painter.dart';

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
  // 计数按钮回调
  final VoidCallback onCountPressed;
  // 背景色（动态变化）
  final Color dynamicBgColor;
  // 圆环直径
  final double diameter;
  // 格式化倒计时文本
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
        // 全屏背景色
        Container(
          width: screenWidth,
          height: screenHeight,
          color: dynamicBgColor,
        ),
        // 全屏黑色高透明遮罩
        Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black.withOpacity(0.18),
        ),
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
                                onTap: isStarted && isCounting ? onCountPressed : (isStarted ? null : onStartPressed),
                                child: AnimatedBuilder(
                                  animation: bounceController,
                                  builder: (context, child) => Transform.scale(
                                    scale: bounceController.value,
                                    child: child,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // 进度环
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
                                      // 内部白色圆
                                      Container(
                                        width: counterDiameter - 24,
                                        height: counterDiameter - 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 18,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
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
                                  ),
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
                                  child: Container(
                                    color: Colors.black.withOpacity(0.7),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.emoji_events, color: AppColors.primary, size: 64),
                                          SizedBox(height: 24),
                                          Text('训练完成!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                          SizedBox(height: 16),
                                          Text('RANK:  ${history[0]["rank"]}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                          Text('COUNT:  ${history[0]["counts"]}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                                child: Text('再来一次', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                                child: Text('重置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                                child: Text('返回', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
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
}
