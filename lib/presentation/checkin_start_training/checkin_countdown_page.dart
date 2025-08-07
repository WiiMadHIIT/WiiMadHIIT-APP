import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import '../../widgets/floating_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/circle_progress_painter.dart';
import '../../widgets/layout_bg_type.dart';
import '../../widgets/countdown_portrait_layout.dart';
import '../../widgets/countdown_landscape_layout.dart';
import '../../widgets/tiktok_wheel_picker.dart';
import 'package:camera/camera.dart';

class CheckinCountdownPage extends StatefulWidget {
  final String trainingId;
  final String? productId;
  const CheckinCountdownPage({Key? key, required this.trainingId, this.productId}) : super(key: key);

  @override
  State<CheckinCountdownPage> createState() => _CheckinCountdownPageState();
}

class _CheckinCountdownPageState extends State<CheckinCountdownPage> with TickerProviderStateMixin {
  Map<String, dynamic>? currentResult;
  int totalRounds = 1;
  int roundDuration = 60; // 单位：秒（修改为秒）
  int currentRound = 1;
  int countdown = 0; // 秒
  bool isStarted = false;
  bool isCounting = false;
  bool showPreCountdown = false;
  int preCountdown = 10;
  late AnimationController bounceController;
  late Animation<double> bounceAnim;
  late PageController pageController;
  int _lastBounceTime = 0;
  bool showResultOverlay = false;
  bool _isSetupDialogOpen = false;
  DraggableScrollableController? _portraitController;
  DraggableScrollableController? _landscapeController;

  // 新增：Timer管理
  Timer? _preCountdownTimer;

  // 视频相关
  late VideoPlayerController _videoController;
  late AnimationController _videoFadeController;
  bool _videoReady = false;
  LayoutBgType bgType = LayoutBgType.video;
  bool _videoFading = false;
  CameraController? _cameraController;
  Future<void>? _cameraInitFuture;
  bool _cameraPermissionGranted = false; // 新增：相机权限状态
  bool _isInitializingCamera = false; // 新增：相机初始化状态

  // 历史排名数据 - 从API获取
  List<Map<String, dynamic>> history = [];
  
  // 历史数据加载状态
  bool _isLoadingHistory = false;
  String? _historyError;

  // 最终结果 - 用于API请求
  // finalResult= {
  //   "productId": widget.productId,
  //   "trainingId": widget.trainingId,
  //   "totalRounds": totalRounds,
  //   "roundDuration": roundDuration,
  //   "date": DateTime.now().toIso8601String(),
  //   "seconds": 0,
  // };
  Map<String, dynamic> finalResult = {};
  
  // API请求状态
  bool _isSubmittingResult = false;

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
    
    // 初始化finalResult
    finalResult = {
      "productId": widget.productId,
      "trainingId": widget.trainingId,
      "totalRounds": totalRounds,
      "roundDuration": roundDuration,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "seconds": 0
    };
    
    countdown = roundDuration; // 直接使用秒，不需要乘以60
    
    // 🎯 加载历史训练数据（不依赖权限，优先加载）
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await _loadTrainingHistory();
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSetupDialog());
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
    // 取消Timer
    _preCountdownTimer?.cancel();
    
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

  void _tiktokVideoSwitch() async {
    if (!_videoReady) return;
    setState(() => _videoFading = true);
    await _videoFadeController.reverse();
    // 这里可以切换不同视频，暂时只用同一个视频
    await _videoController.seekTo(Duration.zero);
    await _videoController.play();
    await _videoFadeController.forward();
    setState(() => _videoFading = false);
  }

  // 新增：请求相机权限并初始化相机
  Future<bool> _requestCameraPermissionAndInitialize() async {
    if (_cameraPermissionGranted && _cameraController != null) {
      return true;
    }

    if (_isInitializingCamera) {
      return false; // 正在初始化中，避免重复请求
    }

    setState(() {
      _isInitializingCamera = true;
    });

    try {
      // 检查可用相机
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showCameraErrorDialog('No cameras available on this device.');
        return false;
      }

      // 查找前置摄像头
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0], // 如果没有前置摄像头，使用第一个
      );

      // 创建相机控制器
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // 初始化相机（这会触发权限请求）
      await _cameraController!.initialize();
      
      // 启动图像流以保持相机活跃
      await _cameraController!.startImageStream((image) {
        // 保持摄像头活跃
      });

      setState(() {
        _cameraPermissionGranted = true;
        _isInitializingCamera = false;
      });

      return true;
    } catch (e) {
      print('Camera initialization error: $e');
      setState(() {
        _isInitializingCamera = false;
      });
      
      // 根据错误类型显示不同的提示
      if (e.toString().contains('permission')) {
        _showCameraPermissionDeniedDialog();
      } else {
        _showCameraErrorDialog('Failed to initialize camera. Please try again.');
      }
      
      return false;
    }
  }

  // 新增：显示相机权限被拒绝的对话框
  void _showCameraPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text(
          'To use the selfie background feature, please grant camera permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 可以在这里添加跳转到设置页面的逻辑
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // 新增：显示相机错误对话框
  void _showCameraErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSetupDialog() async {
    setState(() {
      _isSetupDialogOpen = true;
    });
    
    int tempRounds = totalRounds;
    int tempMinutes = roundDuration ~/ 60; // 从秒转换为分钟
    int tempSeconds = roundDuration % 60; // 从秒转换为秒数
    
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return OrientationBuilder(
          builder: (context, orientation) {
            // 如果方向改变为横屏，关闭当前对话框并打开横屏对话框
            if (orientation == Orientation.landscape) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isSetupDialogOpen = false;
                });
                Navigator.of(context).pop();
                _showSetupDialogLandscape();
              });
            }
            
            return StatefulBuilder(
              builder: (context, setStateModal) {
                final totalSeconds = tempRounds * (tempMinutes * 60 + tempSeconds);
                final totalMinutes = totalSeconds ~/ 60;
                final remainingSeconds = totalSeconds % 60;
                
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40, height: 4,
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          'Set Rounds & Time',
                          style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1,
                          ),
                                                ),
                        SizedBox(height: 16),
                        
                        // 设置区域 - 轮次和时间并排
                      Row(
                        children: [
                          // 轮次设置
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Rounds',
                                    style: TextStyle(
                                      fontSize: 15, 
                                      fontWeight: FontWeight.w600, 
                                      color: Colors.orange.shade700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TikTokWheelPicker(
                                    label: '',
                                    value: tempRounds,
                                    min: 1,
                                    max: 10,
                                    onChanged: (v) => setStateModal(() => tempRounds = v),
                                    color: Colors.orange,
                                    compact: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(width: 16),
                          
                          // 时间设置
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.deepPurple.withOpacity(0.1), width: 1),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Duration',
                                    style: TextStyle(
                                      fontSize: 15, 
                                      fontWeight: FontWeight.w600, 
                                      color: Colors.deepPurple.shade700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // 分钟选择器
                                      Expanded(
                                        child: TikTokWheelPicker(
                                          label: 'Min',
                                          value: tempMinutes,
                                          min: 0,
                                          max: 60,
                                          onChanged: (v) => setStateModal(() => tempMinutes = v),
                                          color: Colors.deepPurple,
                                          compact: true,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6),
                                        child: Text(
                                          ':',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple.shade400,
                                          ),
                                        ),
                                      ),
                                      // 秒选择器
                                      Expanded(
                                        child: TikTokWheelPicker(
                                          label: 'Sec',
                                          value: tempSeconds,
                                          min: 0,
                                          max: 59,
                                          onChanged: (v) => setStateModal(() => tempSeconds = v),
                                          color: Colors.deepPurple,
                                          compact: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // 总时间显示
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${tempRounds} Rounds × ${tempMinutes.toString().padLeft(2, '0')}:${tempSeconds.toString().padLeft(2, '0')} = ${totalMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.black87, 
                                fontWeight: FontWeight.w600, 
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // 确认按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              totalRounds = tempRounds;
                              roundDuration = tempMinutes * 60 + tempSeconds; // 转换为秒
                              currentRound = 1;
                              countdown = roundDuration; // 直接使用roundDuration（已经是秒）
                              _isSetupDialogOpen = false;
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          child: Text(
                            'OK', 
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.2
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                    ),
                );
              },
            );
          },
        );
      },
    );
    
    // 对话框关闭后重置状态
    setState(() {
      _isSetupDialogOpen = false;
    });
  }

  void _showSetupDialogLandscape() async {
    setState(() {
      _isSetupDialogOpen = true;
    });
    
    int tempRounds = totalRounds;
    int tempMinutes = roundDuration ~/ 60; // 从秒转换为分钟
    int tempSeconds = roundDuration % 60; // 从秒转换为秒数
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 468 ? 420 : screenWidth - 48;
    final bool isFinalResult = showResultOverlay;
    
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return OrientationBuilder(
          builder: (context, orientation) {
            // 如果方向改变为竖屏，关闭当前对话框并打开竖屏对话框
            if (orientation == Orientation.portrait) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isSetupDialogOpen = false;
                });
                Navigator.of(context).pop();
                _showSetupDialog();
              });
            }
            
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
                      final totalSeconds = tempRounds * (tempMinutes * 60 + tempSeconds);
                      final totalMinutes = totalSeconds ~/ 60;
                      final remainingSeconds = totalSeconds % 60;
                      
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                        child: Stack(
                          children: [
                            // 右上角关闭按钮
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.close_rounded, color: Colors.black54),
                                onPressed: () {
                                  setState(() {
                                    _isSetupDialogOpen = false;
                                  });
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
                                SizedBox(height: 2),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Set Rounds & Time',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1),
                                  ),
                                ),
                                
                                // 设置区域 - 轮次和时间并排
                                Row(
                                  children: [
                                    // 轮次设置
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Rounds',
                                              style: TextStyle(
                                                fontSize: 13, 
                                                fontWeight: FontWeight.w600, 
                                                color: Colors.orange.shade700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            TikTokWheelPicker(
                                              label: '',
                                              value: tempRounds,
                                              min: 1,
                                              max: 10,
                                              onChanged: (v) => setStateModal(() => tempRounds = v),
                                              color: Colors.orange,
                                              compact: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    SizedBox(width: 12),
                                    
                                    // 时间设置
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.deepPurple.withOpacity(0.1), width: 1),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Duration',
                                              style: TextStyle(
                                                fontSize: 13, 
                                                fontWeight: FontWeight.w600, 
                                                color: Colors.deepPurple.shade700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // 分钟选择器
                                                Expanded(
                                                  child: TikTokWheelPicker(
                                                    label: 'Min',
                                                    value: tempMinutes,
                                                    min: 0,
                                                    max: 60,
                                                    onChanged: (v) => setStateModal(() => tempMinutes = v),
                                                    color: Colors.deepPurple,
                                                    compact: true,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                                  child: Text(
                                                    ':',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.deepPurple.shade400,
                                                    ),
                                                  ),
                                                ),
                                                // 秒选择器
                                                Expanded(
                                                  child: TikTokWheelPicker(
                                                    label: 'Sec',
                                                    value: tempSeconds,
                                                    min: 0,
                                                    max: 59,
                                                    onChanged: (v) => setStateModal(() => tempSeconds = v),
                                                    color: Colors.deepPurple,
                                                    compact: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 8),
                                
                                // 总时间显示
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '${tempRounds} × ${tempMinutes.toString().padLeft(2, '0')}:${tempSeconds.toString().padLeft(2, '0')} = ${totalMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.black87, 
                                          fontWeight: FontWeight.w600, 
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                SizedBox(height: 12),
                                
                                // 确认按钮
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        totalRounds = tempRounds;
                                        roundDuration = tempMinutes * 60 + tempSeconds; // 转换为秒
                                        currentRound = 1;
                                        countdown = roundDuration; // 直接使用roundDuration（已经是秒）
                                        _isSetupDialogOpen = false;
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
                                    child: Text(
                                      'OK', 
                                      style: TextStyle(
                                        fontSize: 15, 
                                        fontWeight: FontWeight.bold, 
                                        letterSpacing: 1.1
                                      )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    
    // 对话框关闭后重置状态
    setState(() {
      _isSetupDialogOpen = false;
    });
  }

  // 获取历史训练数据
  Future<void> _loadTrainingHistory() async {
    if (_isLoadingHistory) return; // 防止重复请求
    
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      print('🔄 Loading training history for trainingId: ${widget.trainingId}, productId: ${widget.productId}');
      
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 800));
      
      // 模拟API返回的历史数据
      final apiResponse = await _getTrainingHistoryApi();
      
      if (mounted) {
        setState(() {
          history = apiResponse;
          _isLoadingHistory = false;
        });
        print('✅ Training history loaded successfully: ${history.length} records');
      }
    } catch (e) {
      print('❌ Error loading training history: $e');
      if (mounted) {
        setState(() {
          _historyError = e.toString();
          _isLoadingHistory = false;
        });
      }
    }
  }

  // 模拟获取历史数据的API请求
  Future<List<Map<String, dynamic>>> _getTrainingHistoryApi() async {
    // 模拟网络请求
    await Future.delayed(Duration(milliseconds: 500));
    
    // 根据trainingId和productId返回不同的模拟数据
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    // 模拟历史数据 - 使用 countdown 页面特有的数据结构
    final mockHistoryData = [
      {
        "id": "662553355",
        "rank": 1,
        "timestamp": now.subtract(Duration(days: 2)).millisecondsSinceEpoch,
        "daySeconds": 1140,
        "seconds": 1140,
        "note": "",
      },
      {
        "id": "662553356",
        "rank": 2,
        "timestamp": now.subtract(Duration(days: 5)).millisecondsSinceEpoch,
        "daySeconds": 1080,
        "seconds": 1080,
        "note": "",
      },
      {
        "id": "662553357",
        "rank": 3,
        "timestamp": now.subtract(Duration(days: 8)).millisecondsSinceEpoch,
        "daySeconds": 900,
        "seconds": 900,
        "note": "",
      },
      {
        "id": "662553358",
        "rank": 4,
        "timestamp": now.subtract(Duration(days: 12)).millisecondsSinceEpoch,
        "daySeconds": 840,
        "seconds": 840,
        "note": "",
      },
      {
        "id": "662553359",
        "rank": 5,
        "timestamp": now.subtract(Duration(days: 15)).millisecondsSinceEpoch,
        "daySeconds": 720,
        "seconds": 720,
        "note": "",
      },
    ];
    
    // 转换为UI显示格式
    return mockHistoryData.map((item) {
      final date = DateTime.fromMillisecondsSinceEpoch(item["timestamp"] as int);
      final dateStr = "${months[date.month - 1]} ${date.day}, ${date.year}";
      
      return {
        "rank": item["rank"],
        "date": dateStr,
        "daySeconds": item["daySeconds"],
        "seconds": item["seconds"],
        "note": item["note"],
        "id": item["id"],
      };
    }).toList();
  }

  // 刷新历史数据
  Future<void> _refreshHistory() async {
    if (_isLoadingHistory) return;
    await _loadTrainingHistory();
  }

  void _startPreCountdown() {
    // 取消之前的Timer（如果存在）
    _preCountdownTimer?.cancel();
    
    countdown = roundDuration;
    setState(() {
      showPreCountdown = true;
      preCountdown = 10;
    });
    _preCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (preCountdown > 1) {
        setState(() => preCountdown--);
      } else {
        timer.cancel();
        _preCountdownTimer = null; // 清空引用
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
      countdown = roundDuration; // 直接使用秒，不需要乘以60
    });
    _tick();
  }

  // 立即显示训练结果（排名为null，等待API返回）
  void _showImmediateResult() {
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
    
    final totalSeconds = totalRounds * roundDuration; // 直接使用秒
    
    // 立即添加结果到history，rank为null表示正在加载
    final result = {
      "rank": null, // 暂时为null，等待API返回
      "date": dateStr,
      "daySeconds": totalSeconds,
      "seconds": totalSeconds,
      "note": "current",
      "totalRounds": totalRounds,
      "roundDuration": roundDuration,
      "id": "temp_${DateTime.now().millisecondsSinceEpoch}", // 临时ID
      "trainingId": widget.trainingId,
      "productId": widget.productId,
    };
    
    history.insert(0, result);
    
    // 排序并赋rank（除了当前结果）
    history.sort((a, b) => b["seconds"].compareTo(a["seconds"]));
    for (int i = 0; i < history.length; i++) {
      if (history[i]["rank"] != null) { // 只更新非当前结果的rank
        history[i]["rank"] = i + 1;
      }
    }
    
    // 把当前结果移到首位
    final idx = history.indexWhere((e) => e["note"] == "current");
    if (idx > 0) {
      final current = history.removeAt(idx);
      history.insert(0, current);
    }
    
    setState(() {
      showResultOverlay = true;
      isCounting = false;
    });
    
    // 自动收起榜单
    Future.delayed(Duration(milliseconds: 50), () {
      final orientation = MediaQuery.of(context).orientation;
      final targetSize = orientation == Orientation.landscape ? 1.0 : 0.12;
      final controller = orientation == Orientation.portrait ? _portraitController : _landscapeController;
      controller?.animateTo(targetSize, duration: Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    });
  }

  // 提交最终结果到后端
  Future<void> _submitFinalResult() async {
    if (_isSubmittingResult) return; // 防止重复提交
    
    setState(() {
      _isSubmittingResult = true;
    });

    try {
      final totalSeconds = totalRounds * roundDuration; // 直接使用秒
      
      // 更新finalResult
      finalResult["productId"] = widget.productId;
      finalResult["trainingId"] = widget.trainingId;
      finalResult["totalRounds"] = totalRounds;
      finalResult["roundDuration"] = roundDuration;
      finalResult["seconds"] = totalSeconds;
      finalResult["timestamp"] = DateTime.now().millisecondsSinceEpoch;

      
      print('Submitting final result: $finalResult');
      
      // 模拟API请求
      final apiResult = await _submitTrainingResult(finalResult);
      
      if (mounted) {
        setState(() {
          // 更新当前结果的rank和ID
          final currentIdx = history.indexWhere((e) => e["note"] == "current");
          if (currentIdx >= 0) {
            history[currentIdx]["rank"] = apiResult["rank"];
            history[currentIdx]["id"] = apiResult["id"]; // 更新为真实的ID
          }
          
          _isSubmittingResult = false;
        });
      }
    } catch (e) {
      print('Error submitting result: $e');
      if (mounted) {
        setState(() {
          _isSubmittingResult = false;
        });
      }
    }
  }

  // 模拟API请求
  Future<Map<String, dynamic>> _submitTrainingResult(Map<String, dynamic> result) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 1500));
    
    // 模拟API返回结果
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = "${months[now.month - 1]} ${now.day}, ${now.year}";
    
    // 模拟返回的排名数据
    return {
      "id": "662553355",
      "rank": 1, // 这里应该是从后端返回的实际排名
      "totalRounds": result["totalRounds"],
      "roundDuration": result["roundDuration"],
    };
  }

  void _insertFinalResult( {bool isFinal = false}) {
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
    final totalSeconds = totalRounds * roundDuration; // 直接使用秒
    final result = {
      "date": dateStr,
      "daySeconds": totalSeconds,
      "seconds": totalSeconds,
      "note": "current",
    };
    history.insert(0, result);
    // 排序并赋rank
    history.sort((a, b) => b["seconds"].compareTo(a["seconds"]));
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
      _onCountPressed(); // 每秒自动触发弹跳动画
      _tick();
    } else {
      if (!mounted) return;
      
      if (currentRound < totalRounds) {
        setState(() {
          currentRound++;
        });
        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        Future.delayed(const Duration(milliseconds: 600), _startPreCountdown);
      } else {
        // 所有round结束，立即显示结果，然后异步提交
        _showImmediateResult();
        _submitFinalResult();
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
    final bool isSelfieType = type == LayoutBgType.selfie;
    final bool isLoading = isSelfieType && _isInitializingCamera;
    
    return GestureDetector(
      onTap: () async {
        if (isSelfieType) {
          // 对于自拍模式，先请求相机权限
          final success = await _requestCameraPermissionAndInitialize();
          if (!success) {
            return; // 权限被拒绝或初始化失败，不切换模式
          }
        }
        
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
            child: isLoading
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        selected ? Colors.white : Colors.black54,
                      ),
                    ),
                  )
                : Icon(icon, size: 32, color: selected ? Colors.white : Colors.black54),
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
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
          )
        : Container(color: Colors.black);

    final Widget selfieWidget = (_cameraController != null && _cameraController!.value.isInitialized && _cameraPermissionGranted)
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
        : Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isInitializingCamera) ...[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Initializing camera...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.camera_front_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Camera not available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please grant camera permission',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );

    final Widget mainContent = isPortrait
        ? CountdownPortraitLayout(
            totalRounds: totalRounds,
            currentRound: currentRound,
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
            diameter: diameter,
            formatTime: _formatTime,
            roundDuration: roundDuration,
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
            videoWidget: videoWidget,
            selfieWidget: selfieWidget,
            bgType: bgType,
            onBgSwitchPressed: _onBgSwitchPressed,
            dynamicBgColor: _dynamicBgColor,
            isSubmittingResult: _isSubmittingResult, // 新增
          )
        : CountdownLandscapeLayout(
            totalRounds: totalRounds,
            currentRound: currentRound,
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
            diameter: diameter,
            formatTime: _formatTime,
            roundDuration: roundDuration,
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
            videoWidget: videoWidget,
            selfieWidget: selfieWidget,
            bgType: bgType,
            dynamicBgColor: _dynamicBgColor,
            isSubmittingResult: _isSubmittingResult, // 新增
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
                          child: Text('TIME', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
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
                final isTopThree = e["rank"] != null && e["rank"] <= 3;
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
                              gradient: isTopThree && !isCurrent && e["rank"] != null
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
                              e["rank"] != null ? '${e["rank"]}' : '...',
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
                          // seconds展示 - 转换为MM:SS格式
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(e["seconds"]),
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.timer,
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
}
