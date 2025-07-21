import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class CheckingTrainingPage extends StatefulWidget {
  final String trainingId;
  const CheckingTrainingPage({Key? key, required this.trainingId}) : super(key: key);

  @override
  State<CheckingTrainingPage> createState() => _CheckingTrainingPageState();
}

class _CheckingTrainingPageState extends State<CheckingTrainingPage> with TickerProviderStateMixin {
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

  // 假数据历史排名
  final List<Map<String, dynamic>> history = [
    {"rank": 1, "date": "May 19, 2025", "counts": 19},
    {"rank": 2, "date": "May 13, 2025", "counts": 18},
    {"rank": 3, "date": "May 13, 2025", "counts": 15},
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
                    'Total: ${tempRounds * tempMinutes} min',
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
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Container(
          width: 70,
          height: 120,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RotatedBox(
            quarterTurns: -1,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 48,
              diameterRatio: 1.2,
              physics: FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: value - min),
              onSelectedItemChanged: (i) => onChanged(i + min),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, i) {
                  final v = i + min;
                  final isSelected = v == value;
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Center(
                      child: Text(
                        '$v',
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 22,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : Colors.black38,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  );
                },
                childCount: max - min + 1,
              ),
            ),
          ),
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
      setState(() {
        countdown--;
        if (countdown <= 3) {
          // 变色
        }
      });
      _tick();
    } else {
      // 进入下一个ROUND或结束
      if (currentRound < totalRounds) {
        setState(() {
          currentRound++;
        });
        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        Future.delayed(const Duration(milliseconds: 600), _startPreCountdown);
      } else {
        // 训练结束
        setState(() {
          isCounting = false;
        });
      }
    }
  }

  void _onStartPressed() {
    _startPreCountdown();
  }

  void _onCountPressed() {
    if (!isCounting) return;
    bounceController.forward(from: 1.0);
    setState(() {
      counter++;
    });
  }

  Color get _bgColor => isCounting
      ? (countdown <= 3 ? const Color(0xFF34C759) : const Color(0xFFFF9500))
      : const Color(0xFFFF9500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalRounds,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // 顶部返回和大标题
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        'ROUND ${index + 1}/$totalRounds',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              // 中间大圆形倒计时/计数器
              Center(
                child: GestureDetector(
                  onTap: isStarted && isCounting ? _onCountPressed : (isStarted ? null : _onStartPressed),
                  child: AnimatedBuilder(
                    animation: bounceController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: bounceController.value,
                        child: child,
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CustomPaint(
                            painter: _CircleProgressPainter(
                              progress: isCounting ? countdown / (roundDuration * 60) : 1.0,
                              color: isCounting && countdown <= 3
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFFFFFFFF),
                              shadow: isCounting && countdown <= 3
                                  ? const Color(0xFF34C759).withOpacity(0.2)
                                  : const Color(0xFFFF9500).withOpacity(0.2),
                            ),
                          ),
                        ),
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isStarted && isCounting
                                ? Text(
                                    '$counter',
                                    style: const TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )
                                : Icon(Icons.play_arrow_rounded, size: 80, color: Colors.orange.shade400),
                          ),
                        ),
                        if (isStarted && isCounting)
                          Positioned(
                            bottom: 24,
                            left: 0,
                            right: 0,
                            child: Text(
                              _formatTime(countdown),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: countdown <= 3 ? const Color(0xFF34C759) : Colors.orange.shade400,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // 底部历史排名
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildHistoryRanking(),
              ),
              // 遮罩倒计时动画
              if (showPreCountdown)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
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
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryRanking() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Spacer(),
                    Text(
                      '${e["counts"]}',
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.sports_mma, color: Colors.black54, size: 18),
                  ],
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
  final Color shadow;
  _CircleProgressPainter({required this.progress, required this.color, required this.shadow});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bg = Paint()
      ..color = shadow
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint fg = Paint()
      ..color = color
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    canvas.drawCircle(center, radius, bg);
    double sweep = 2 * 3.1415926 * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1415926/2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
