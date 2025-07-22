import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../widgets/floating_logo.dart';
import '../../core/theme/app_colors.dart';

class CheckingTrainingPage extends StatefulWidget {
  final String trainingId;
  const CheckingTrainingPage({Key? key, required this.trainingId}) : super(key: key);

  @override
  State<CheckingTrainingPage> createState() => _CheckingTrainingPageState();
}

class _CheckingTrainingPageState extends State<CheckingTrainingPage> with TickerProviderStateMixin {
  Map<String, dynamic>? currentResult;
  int totalRounds = 1;
  int roundDuration = 1; // 单位：分钟
  int currentRound = 1;
  int countdown = 0; // 秒
  int counter = 0;
  bool isStarted = false;
  bool isCounting = false;
  bool showPreCountdown = false;
  int preCountdown = 3;
  late AnimationController bounceController;
  late Animation<double> bounceAnim;
  late PageController pageController;
  int _lastBounceTime = 0;
  bool showResultOverlay = false;

  // 假数据历史排名
  final List<Map<String, dynamic>> history = [
    {"rank": 1, "date": "May 19, 2025", "counts": 19, "note": ""},
    {"rank": 2, "date": "May 13, 2025", "counts": 18, "note": ""},
    {"rank": 3, "date": "May 13, 2025", "counts": 15, "note": ""},
  ];

  @override
  void initState() {
    super.initState();
    bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 1.0,
      upperBound: 1.18,
    );
    bounceAnim = CurvedAnimation(parent: bounceController, curve: Curves.easeOut);
    pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSetupDialog());
  }

  @override
  void dispose() {
    bounceController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _showSetupDialog() async {
    int tempRounds = totalRounds;
    int tempMinutes = roundDuration;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: EdgeInsets.only(
                left: 24, right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 32,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Set Rounds & Time',
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tiktokWheelPicker(
                        label: 'Rounds',
                        value: tempRounds,
                        min: 1,
                        max: 10,
                        onChanged: (v) => setStateModal(() => tempRounds = v),
                        color: Colors.orange,
                      ),
                      SizedBox(width: 32),
                      _tiktokWheelPicker(
                        label: 'Minutes',
                        value: tempMinutes,
                        min: 1,
                        max: 60,
                        onChanged: (v) => setStateModal(() => tempMinutes = v),
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Text(
                    '	${tempRounds} Rounds × ${tempMinutes} min = ${tempRounds * tempMinutes} min',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          totalRounds = tempRounds;
                          roundDuration = tempMinutes;
                          currentRound = 1;
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: Text('OK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _tiktokWheelPicker({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required Color color,
  }) {
    final controller = FixedExtentScrollController(initialItem: value - min);
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 70,
              height: 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 44,
                diameterRatio: 1.2,
                physics: FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) => onChanged(i + min),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, i) {
                    final v = i + min;
                    final isSelected = v == value;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: isSelected
                          ? BoxDecoration(
                              color: color.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color, width: 2),
                            )
                          : null,
                      child: Text(
                        '$v',
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 20,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : Colors.black38,
                          letterSpacing: 1.1,
                        ),
                      ),
                    );
                  },
                  childCount: max - min + 1,
                ),
              ),
            ),
            // 顶部渐变遮罩
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 28,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
            ),
            // 底部渐变遮罩
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 28,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startPreCountdown() {
    setState(() {
      showPreCountdown = true;
      preCountdown = 3;
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (preCountdown > 1) {
        setState(() => preCountdown--);
      } else {
        timer.cancel();
        setState(() {
          showPreCountdown = false;
        });
        _startRound();
      }
    });
  }

  void _startRound() {
    setState(() {
      isStarted = true;
      isCounting = true;
      countdown = roundDuration * 60;
      counter = 0;
    });
    _tick();
  }

  void _tick() async {
    if (!isCounting) return;
    if (countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        countdown--;
        if (countdown <= 3) {
          // 变色
        }
      });
      _tick();
    } else {
      if (!mounted) return;
      // 进入下一个ROUND或结束
      if (currentRound < totalRounds) {
        setState(() {
          currentRound++;
        });
        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        Future.delayed(const Duration(milliseconds: 600), _startPreCountdown);
      } else {
        // 训练结束，插入本次成绩
        final now = DateTime.now();
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final dateStr = "${months[now.month - 1]} ${now.day}, ${now.year}";
        final result = {
          "date": dateStr,
          "counts": counter,
          "note": "current",
        };
        setState(() {
          isCounting = false;
          // 先移除已有current
          history.removeWhere((e) => e["note"] == "current");
          // 插入本次结果到首位
          history.insert(0, result);
          // 排序得到排名
          final sorted = List<Map<String, dynamic>>.from(history);
          sorted.sort((a, b) => b["counts"].compareTo(a["counts"]));
          for (int i = 0; i < sorted.length; i++) {
            sorted[i]["rank"] = i + 1;
          }
          // 找到本次结果的排名
          final myRank = sorted.indexWhere((e) => e["note"] == "current") + 1;
          history[0]["rank"] = myRank;
          // 其余历史排名也赋rank
          int hIdx = 1;
          for (int i = 0; i < sorted.length; i++) {
            if (sorted[i]["note"] != "current") {
              history[hIdx]["rank"] = sorted[i]["rank"];
              hIdx++;
              if (hIdx >= history.length) break;
            }
          }
          showResultOverlay = true;
        });
      }
    }
  }

  void _onStartPressed() {
    _startPreCountdown();
  }

  void _onCountPressed() async {
    if (!isCounting) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final interval = now - _lastBounceTime;
    _lastBounceTime = now;

    bounceController.stop();

    if (interval > 400) {
      // 非常慢的点击，柔和弹跳
      bounceController.value = 1.0;
      await bounceController.animateTo(1.18, duration: Duration(milliseconds: 200), curve: Curves.easeInOutCubic);
      if (mounted) {
        await bounceController.animateTo(1.0, duration: Duration(milliseconds: 300), curve: Curves.elasticOut);
      }
    } else if (interval > 200) {
      // 中速点击，正常弹跳
      bounceController.value = 1.0;
      await bounceController.animateTo(1.18, duration: Duration(milliseconds: 120), curve: Curves.easeOut);
      if (mounted) {
        await bounceController.animateTo(1.0, duration: Duration(milliseconds: 180), curve: Curves.elasticOut);
      }
    } else {
      // 快速点击，快速回弹
      bounceController.value = 1.18;
      bounceController.animateTo(1.0, duration: Duration(milliseconds: 100), curve: Curves.easeOut);
    }

    setState(() {
      counter++;
    });
  }
  // 背景色 绿色 0xFF00FF7F #00FF7F
  // 绿色 0xFF34C759 #34C759
  // 蓝色 0xFF007AFF  #007AFF
  // 纯蓝色 0xFF0000FF  #0000FF
  // 橙色 0xFF007AFF  #FF9500
  // 红色 0xFFFF3B30  #FF3B30
  // #00FFFF  #7FCFFF #007F3F #00A352 #33CCFF #00BF60
  // #FF0080  #A300FF #7FFF00
  // #FF8500  #FFA300 #00C2FF 
  // #E0E0E0  #004F28 #FFA07A
  // #00FFFF  #BF00FF #E0E0E0
  Color get _bgColor => isCounting
    ? (countdown <= 3 ? const Color(0xFF00FF7F) : const Color(0xFFF2F2F2))
    : const Color(0xFFF2F2F2);

  Color get _dynamicBgColor {
    if (isCounting && countdown > 3) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final interval = now - _lastBounceTime;
      double t = (1.0 - (interval.clamp(0, 800) / 800));
      return Color.lerp(Color(0xFFFFCC66), Color(0xFFF97316), t)!;
    } else if (isCounting && countdown <= 3) {
      return Color(0xFF00FF7F);
    } else {
      return Color(0xFFFFCC66);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double diameter = MediaQuery.of(context).size.width * 3 / 4;
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: _dynamicBgColor,
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
                    // SafeArea仅保留返回按钮
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: isStarted && isCounting ? _onCountPressed : (isStarted ? null : _onStartPressed),
                        child: AnimatedBuilder(
                          animation: bounceController,
                          builder: (context, child) => Transform.scale(
                            scale: bounceController.value,
                            child: child,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 进度条
                              SizedBox(
                                width: diameter,
                                height: diameter,
                                child: CustomPaint(
                                  painter: _CircleProgressPainter(
                                    progress: isCounting ? countdown / (roundDuration * 60) : 1.0,
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
                                    '$counter',
                                    style: TextStyle(
                                      fontSize: diameter / 3,
                                      fontWeight: FontWeight.bold,
                                      color: isWarning ? AppColors.primary : Colors.black87,
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
                                    _formatTime(countdown),
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
                          ),
                        ),
                      ),
                    ),
                    // 底部历史排名可拖拽弹窗
                    DraggableScrollableSheet(
                      initialChildSize: 0.22,
                      minChildSize: 0.15,
                      maxChildSize: 0.6,
                      builder: (context, scrollController) {
                        return _buildHistoryRanking(scrollController);
                      },
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
                                  'ROUND ${index + 1}/$totalRounds',
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
            Positioned.fill(
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
                            onPressed: () {
                              setState(() {
                                showResultOverlay = false;
                                currentRound = 1;
                                counter = 0;
                                isStarted = false;
                                isCounting = false;
                                showPreCountdown = false;
                              });
                              _startPreCountdown();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('再来一次', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(width: 24),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary, width: 2),
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('返回重置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryRanking(ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        children: [
          const Text(
            'TOP SCORES',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              SizedBox(width: 8),
              Text('RANK', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
              SizedBox(width: 32),
              Text('DATE', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
              Spacer(),
              Text('COUNTS', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          ...history.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Container(
                  decoration: e["note"] == "current"
                      ? BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary, width: 2),
                        )
                      : null,
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: e["rank"] == 1 ? Colors.orange.shade400 : Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${e["rank"]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Text(
                        e["date"],
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                      ),
                      if (e["note"] == "current")
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'MY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${e["counts"]}',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.sports_mma, color: Colors.black54, size: 18),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Gradient? gradient;
  final Color trackColor;
  final Color shadow;
  final double strokeWidth;
  _CircleProgressPainter({
    required this.progress,
    required this.color,
    this.gradient,
    required this.trackColor,
    required this.shadow,
    this.strokeWidth = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint track = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint fg = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2)
      ..strokeCap = StrokeCap.round;
    if (gradient != null) {
      fg.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    final Paint glow = Paint()
      ..color = shadow
      ..strokeWidth = strokeWidth + 6
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    // 轨迹
    canvas.drawCircle(center, radius, track);
    // glow
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1415926/2, 2 * 3.1415926 * progress, false, glow);
    // 主进度
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1415926/2, 2 * 3.1415926 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
