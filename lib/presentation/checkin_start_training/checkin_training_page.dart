import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../widgets/floating_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/circle_progress_painter.dart';
import '../../widgets/layout_bg_type.dart';
import '../../widgets/training_portrait_layout.dart';
import '../../widgets/training_landscape_layout.dart';
import 'package:camera/camera.dart';

class CheckinTrainingPage extends StatefulWidget {
  final String trainingId;
  const CheckinTrainingPage({Key? key, required this.trainingId}) : super(key: key);

  @override
  State<CheckinTrainingPage> createState() => _CheckinTrainingPageState();
}

class _CheckinTrainingPageState extends State<CheckinTrainingPage> with TickerProviderStateMixin {
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
  // 1. 在State中添加controller
  DraggableScrollableController? _portraitController;
  DraggableScrollableController? _landscapeController;

  // 背景切换相关
  LayoutBgType bgType = LayoutBgType.color;
  late AnimationController _videoFadeController;
  late VideoPlayerController _videoController;
  bool _videoReady = false;
  CameraController? _cameraController;
  Future<void>? _cameraInitFuture;

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
    _portraitController = DraggableScrollableController();
    _landscapeController = DraggableScrollableController();
    _videoController = VideoPlayerController.asset('assets/video/video1.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {
          _videoReady = true;
        });
        _videoController.play();
      });
    _videoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSetupDialog());
    // 初始化摄像头
    availableCameras().then((cameras) {
      if (cameras.isNotEmpty) {
        // 查找前置摄像头
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras[0], // 如果没有前置摄像头，使用第一个
        );
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        _cameraInitFuture = _cameraController!.initialize().then((_) {
          if (mounted) {
            setState(() {});
            // 启动摄像头预览
            _cameraController!.startImageStream((image) {
              // 保持摄像头活跃
            });
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait && _portraitController == null) {
      _portraitController = DraggableScrollableController();
    }
    if (orientation == Orientation.landscape && _landscapeController == null) {
      _landscapeController = DraggableScrollableController();
    }
  }

  @override
  void dispose() {
    
    bounceController.dispose();
    pageController.dispose();
    _portraitController?.dispose();
    _landscapeController?.dispose();
    _videoController.dispose();
    _videoFadeController.dispose();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  void _showSetupDialog() async {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      _showSetupDialogLandscape();
      return;
    }
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
                    '\t${tempRounds} Rounds × ${tempMinutes} min = ${tempRounds * tempMinutes} min',
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

  void _showSetupDialogLandscape() async {
  int tempRounds = totalRounds;
  int tempMinutes = roundDuration;
  final double screenWidth = MediaQuery.of(context).size.width;
  final double dialogWidth = screenWidth > 468 ? 420 : screenWidth - 48;
  final bool isFinalResult = showResultOverlay;
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: dialogWidth,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 28,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setStateModal) {
                return Stack(
                  children: [
                    // 右上角关闭按钮
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.black54),
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (isFinalResult) {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Set Rounds & Time',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _tiktokWheelPicker(
                                label: 'Rounds',
                                value: tempRounds,
                                min: 1,
                                max: 10,
                                onChanged: (v) => setStateModal(() => tempRounds = v),
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: _tiktokWheelPicker(
                                label: 'Minutes',
                                value: tempMinutes,
                                min: 1,
                                max: 60,
                                onChanged: (v) => setStateModal(() => tempMinutes = v),
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\t${tempRounds} Rounds × ${tempMinutes} min = ${tempRounds * tempMinutes} min',
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: 120,
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
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 8,
                            ),
                            child: Text('OK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
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

  void _insertRoundResult(int counts, {bool isFinal = false}) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = "${months[now.month - 1]} ${now.day}, ${now.year}";
    // 清空所有note
    for (var e in history) {
      e["note"] = "";
    }
    final result = {
      "date": dateStr,
      "counts": counts,
      "note": "current",
    };
    history.insert(0, result);
    // 排序并赋rank
  history.sort((a, b) => b["counts"].compareTo(a["counts"]));
  for (int i = 0; i < history.length; i++) {
    history[i]["rank"] = i + 1;
    }
  // 把note为current的移到首位，其余按rank排序
  final idx = history.indexWhere((e) => e["note"] == "current");
  if (idx > 0) {
    final current = history.removeAt(idx);
    history.insert(0, current);
    }
  }

  void _tick() async {
    if (!isCounting) return;
    if (countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        countdown--;
      });
      _tick();
    } else {
      if (!mounted) return;
      setState(() {
        _insertRoundResult(counter, isFinal: currentRound == totalRounds);
      });
      if (currentRound < totalRounds) {
        setState(() {
          currentRound++;
        });
        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        Future.delayed(const Duration(milliseconds: 600), _startPreCountdown);
      } else {
        setState(() {
          isCounting = false;
          showResultOverlay = true;
        });
        
        // 自动收起榜单
        Future.delayed(Duration(milliseconds: 50), () {
          final orientation = MediaQuery.of(context).orientation;
          final targetSize = orientation == Orientation.landscape ? 1.0 : 0.12;
          final controller = orientation == Orientation.portrait ? _portraitController : _landscapeController;
          controller?.animateTo(targetSize, duration: Duration(milliseconds: 400), curve: Curves.easeOutCubic);
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
    final orientation = MediaQuery.of(context).orientation;
    final bool isPortrait = orientation == Orientation.portrait;
    final DraggableScrollableController controller =
        isPortrait ? _portraitController! : _landscapeController!;

    final Widget videoWidget = _videoReady
        ? FadeTransition(
            opacity: _videoFadeController,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          )
        : Container(color: Colors.black);

    final Widget selfieWidget = (_cameraController != null && _cameraController!.value.isInitialized)
        ? LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;
              final cameraWidth = _cameraController!.value.previewSize?.width ?? 1;
              final cameraHeight = _cameraController!.value.previewSize?.height ?? 1;

              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: Center(
                  child: SizedBox(
                    width: cameraWidth,
                    height: cameraHeight,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              );
            },
          )
        : Container(color: Colors.black);

    final Widget mainContent = isPortrait
        ? TrainingPortraitLayout(
            totalRounds: totalRounds,
            currentRound: currentRound,
            counter: counter,
            countdown: countdown,
            isStarted: isStarted,
            isCounting: isCounting,
            showPreCountdown: showPreCountdown,
            preCountdown: preCountdown,
            bounceController: bounceController,
            bounceAnim: bounceAnim,
            pageController: pageController,
            onStartPressed: _onStartPressed,
            onCountPressed: _onCountPressed,
            dynamicBgColor: _dynamicBgColor,
            onBgSwitchPressed: _onBgSwitchPressed,
            bgType: bgType,
            videoWidget: videoWidget,
            selfieWidget: selfieWidget,
            diameter: diameter,
            formatTime: _formatTime,
            showResultOverlay: showResultOverlay,
            history: history,
            draggableController: controller,
            buildHistoryRanking: _buildHistoryRanking,
            onResultOverlayTap: () {
              controller.animateTo(
                1.0,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            },
            onResultReset: () {
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
            onResultBack: () {
              Navigator.pop(context);
            },
            onResultSetup: _showSetupDialog,
          )
        : TrainingLandscapeLayout(
            totalRounds: totalRounds,
            currentRound: currentRound,
            counter: counter,
            countdown: countdown,
            isStarted: isStarted,
            isCounting: isCounting,
            showPreCountdown: showPreCountdown,
            preCountdown: preCountdown,
            bounceController: bounceController,
            bounceAnim: bounceAnim,
            pageController: pageController,
            onStartPressed: _onStartPressed,
            onCountPressed: _onCountPressed,
            dynamicBgColor: _dynamicBgColor,
            bgType: bgType,
            videoWidget: videoWidget,
            selfieWidget: selfieWidget,
            diameter: diameter,
            formatTime: _formatTime,
            showResultOverlay: showResultOverlay,
            history: history,
            draggableController: controller,
            buildHistoryRanking: _buildHistoryRanking,
            onResultOverlayTap: () {
              controller.animateTo(
                1.0,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            },
            onResultReset: () {
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
            onResultBack: () {
              Navigator.pop(context);
            },
            onResultSetup: _showSetupDialog,
          );

    return Scaffold(
      body: mainContent,
    );
  }

  Widget _buildHistoryRanking(ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
        children: [
                // 顶部大面积可拖动区域
                Container(
                  height: 32,
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
                // 标题区域
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                      const SizedBox(width: 10),
          const Text(
            'TOP SCORES',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.0,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                        ),
                        child: Text(
                          '${history.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
               // 榜单表头
               Padding(
                 padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 2),
                 child: Row(
                   children: [
                     SizedBox(
                       width: 44,
                       child: Text('RANK', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                     ),
                     Expanded(
                       child: Text('DATE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                     ),
                     SizedBox(
                       width: 60,
                       child: Align(
                         alignment: Alignment.centerRight,
                         child: Text('COUNTS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                       ),
                     ),
                   ],
                 ),
               ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final e = history[index];
                final isCurrent = e["note"] == "current";
                final isTopThree = e["rank"] <= 3;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCurrent 
                        ? Colors.white.withOpacity(0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent
                        ? Border.all(color: Colors.redAccent, width: 2)
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                          // 排名徽章
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                              gradient: isTopThree && !isCurrent
                                  ? LinearGradient(
                                     colors: e["rank"] == 1
                                         ? [Color(0xFFFFF176), Color(0xFFFFA500)]
                                         : e["rank"] == 2
                                             ? [Color(0xFFB0BEC5), Color(0xFF90A4AE)]
                                             : [Color(0xFFBCAAA4), Color(0xFF8D6E63)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isCurrent
                                  ? Colors.redAccent
                                  : (isTopThree ? null : Colors.white.withOpacity(0.10)),
                            borderRadius: BorderRadius.circular(8),
                              boxShadow: isTopThree
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.18),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                        ),
                        child: Text(
                          '${e["rank"]}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : (isTopThree ? Colors.black : Colors.white),
                            fontWeight: FontWeight.bold,
                                fontSize: 12,
                          ),
                        ),
                      ),
                          const SizedBox(width: 12),
                          // 日期和当前标识
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                        e["date"],
                                    style: TextStyle(
                                      color: isCurrent ? Colors.white : Colors.white70,
                                      fontSize: 14,
                                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.redAccent, Colors.red],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                            borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withOpacity(0.18),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                          ),
                          child: const Text(
                                      'CURRENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                        letterSpacing: 0.6,
                            ),
                          ),
                        ),
                                ],
                              ],
                            ),
                          ),
                          // 计数和图标
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                      Text(
                        '${e["counts"]}',
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.fitness_center,
                                color: isCurrent ? Colors.white : Colors.white54,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: history.length,
            ),
          ),
          // 底部补空白
          SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onBgSwitchPressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
                Text('Choose Background', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBgTypeOption(
                      icon: Icons.format_paint_rounded,
                      label: 'Color',
                      type: LayoutBgType.color,
                    ),
                    _buildBgTypeOption(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      type: LayoutBgType.video,
                    ),
                    _buildBgTypeOption(
                      icon: Icons.camera_front_rounded,
                      label: 'Selfie',
                      type: LayoutBgType.selfie,
                    ),
                    _buildBgTypeOption(
                      icon: Icons.dark_mode_rounded,
                      label: 'Black',
                      type: LayoutBgType.black,
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBgTypeOption({
    required IconData icon,
    required String label,
    required LayoutBgType type,
  }) {
    final bool selected = bgType == type;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          bgType = type;
        });
        if (type == LayoutBgType.video && _videoReady) {
          _videoController.play();
          _videoFadeController.forward();
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(selected ? 10 : 8),
            decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: selected
                  ? [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))]
                  : [],
            ),
            child: Icon(icon, size: 32, color: selected ? Colors.white : Colors.black54),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.black : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
