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
import '../../widgets/tiktok_wheel_picker.dart';
import '../../knock_voice/real_audio_detector.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckinTrainingPage extends StatefulWidget {
  final String trainingId;
  final String? productId;
  const CheckinTrainingPage({Key? key, required this.trainingId, this.productId}) : super(key: key);

  @override
  State<CheckinTrainingPage> createState() => _CheckinTrainingPageState();
}

class _CheckinTrainingPageState extends State<CheckinTrainingPage> with TickerProviderStateMixin {
  Map<String, dynamic>? currentResult;
  int totalRounds = 1;
  int roundDuration = 60; // 单位：秒（修改为秒）
  int currentRound = 1;
  int countdown = 0; // 秒
  int counter = 0;
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
  // 1. 在State中添加controller
  DraggableScrollableController? _portraitController;
  DraggableScrollableController? _landscapeController;

  // 新增：Timer管理
  Timer? _preCountdownTimer;

  // 背景切换相关
  LayoutBgType bgType = LayoutBgType.color;
  late AnimationController _videoFadeController;
  late VideoPlayerController _videoController;
  bool _videoReady = false;
  CameraController? _cameraController;
  Future<void>? _cameraInitFuture;
  bool _cameraPermissionGranted = false; // 新增：相机权限状态
  bool _isInitializingCamera = false; // 新增：相机初始化状态

  // 假数据历史排名
  final List<Map<String, dynamic>> history = [
    {"rank": 1, "date": "May 19, 2025", "counts": 19, "note": ""},
    {"rank": 2, "date": "May 13, 2025", "counts": 18, "note": ""},
    {"rank": 3, "date": "May 13, 2025", "counts": 15, "note": ""},
  ];

  // 临时结果 - 存储每个round的数据
  // tmpResult = [
  //   {"roundNumber": 1, "counts": 19, "date": "May 19, 2025",timestamp: 1716393600000,roundDuration: 60},
  //   {"roundNumber": 2, "counts": 18, "date": "May 13, 2025",timestamp: 1716393600000,roundDuration: 60},
  //   {"roundNumber": 3, "counts": 15, "date": "May 13, 2025",timestamp: 1716393600000,roundDuration: 60},
  // ];
  List<Map<String, dynamic>> tmpResult = [];
  
  // 最终结果 - 用于API请求
  // finalResult= {
  //   "productId": widget.productId,
  //   "trainingId": widget.trainingId,
  //   "totalRounds": totalRounds,
  //   "roundDuration": roundDuration,
  //   "date": DateTime.now().toIso8601String(),
  //   "maxCounts": 0
  // };
  Map<String, dynamic> finalResult = {};
  
  // API请求状态
  bool _isSubmittingResult = false;
  
  // 声音检测相关
  RealAudioDetector? _audioDetector;
  bool _audioDetectionEnabled = true; // 默认开启
  bool _isInitializingAudioDetection = false;
  

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
      "date": DateTime.now().toIso8601String(),
      "maxCounts": 0
    };
    
    // 🎯 Apple-level Permission Management
    // 在页面初始化时检查麦克风权限
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkMicrophonePermissionOnInit();
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
    // 🎯 Apple-level Resource Cleanup
    // 立即停止所有动画和定时器
    _stopAllAnimationsAndTimers();
    
    // 🎯 Stop audio detection before disposal
    if (_audioDetectionEnabled && _audioDetector != null) {
      _audioDetector!.stopListening().catchError((e) {
        print('🎯 Audio detection stop error during disposal: $e');
      });
    }
    
    // 停止声音检测
    _audioDetector?.dispose();
    
    // 释放所有控制器资源
    bounceController.dispose();
    pageController.dispose();
    _portraitController?.dispose();
    _landscapeController?.dispose();
    _videoController.dispose();
    _videoFadeController.dispose();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    
    print('🎯 All resources cleaned up successfully');
    super.dispose();
  }

  /// 停止所有动画和定时器，释放内存
  void _stopAllAnimationsAndTimers() {
    // 取消所有定时器
    _preCountdownTimer?.cancel();
    _preCountdownTimer = null;
    
    _animationDebounceTimer?.cancel();
    _animationDebounceTimer = null;
    
    // 立即停止动画控制器
    if (bounceController.isAnimating) {
      bounceController.stop();
    }
    
    // 重置动画状态
    _isAnimating = false;
    
    // 停止视频播放
    if (_videoController.value.isPlaying) {
      _videoController.pause();
    }
    
    // 停止相机流
    try {
      _cameraController?.stopImageStream();
    } catch (e) {
      // 忽略相机停止错误
    }
    
    print('All animations and timers stopped, memory cleaned up');
  }

  /// 🍎 Apple-level Direct Permission Flow
  Future<void> _checkMicrophonePermissionOnInit() async {
    // 1. 直接检查并请求麦克风权限
    await _requestMicrophonePermissionDirectly();
  }

  /// 🍎 Apple-level Direct Microphone Permission Request
  Future<void> _requestMicrophonePermissionDirectly() async {
    try {
      // 1. 检查当前权限状态
      PermissionStatus status = await Permission.microphone.status;
      
      if (status.isGranted) {
        // 2. 权限已授予，直接初始化音频检测
        print('🎯 Microphone permission already granted');
        await _initializeAudioDetection();
        if (mounted) {
          _showSetupDialog();
        }
        return;
      }
      
      if (status.isPermanentlyDenied) {
        // 3. 权限被永久拒绝，显示设置指导
        print('❌ Microphone permission permanently denied');
        if (mounted) {
          _showMicrophonePermissionRequiredDialog();
        }
        return;
      }
      
      // 4. 权限未授予，直接请求权限（会显示系统弹窗）
      print('🎯 Requesting microphone permission...');
      status = await Permission.microphone.request();
      
      if (status.isGranted) {
        // 5. 权限授予成功，初始化音频检测
        print('✅ Microphone permission granted');
        await _initializeAudioDetection();
        if (mounted) {
          _showSetupDialog();
        }
      } else {
        // 6. 权限被拒绝，显示友好提示
        print('❌ Microphone permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Voice detection unavailable, but you can still train manually'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
          _showSetupDialog();
        }
      }
      
    } catch (e) {
      print('❌ Error requesting microphone permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice detection unavailable, but you can still train manually'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
        _showSetupDialog();
      }
    }
  }









    /// 🍎 Apple-level Elegant Permission Dialog
  void _showMicrophonePermissionRequiredDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true, // 允许用户关闭对话框
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.mic, color: Colors.blue, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Voice Detection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enable voice detection for hands-free training?',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Text(
              'Voice detection automatically counts your strikes by listening for sound patterns, making your training more convenient.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your privacy is protected. Audio is processed locally and never shared.',
                      style: TextStyle(fontSize: 13, color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 用户选择跳过，直接显示设置对话框
              _showSetupDialog();
            },
            child: Text(
              'Skip for Now',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // 重新尝试权限请求
              await _requestMicrophonePermissionDirectly();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// 🎯 Apple-level Audio Detection Initialization
  Future<void> _initializeAudioDetection() async {
    try {
      setState(() {
        _isInitializingAudioDetection = true;
      });

      // 创建真实声音检测器实例（如果还没有创建）
      _audioDetector ??= RealAudioDetector();

      // 设置检测回调
      _audioDetector!.onStrikeDetected = () {
        print('🎯 Strike detected! Triggering count...');
        if (isCounting && mounted) {
          _onCountPressed(); // 自动触发计数
        }
      };

      // 设置错误回调
      _audioDetector!.onError = (error) {
        print('Audio detection error: $error');
        // 不在这里显示错误对话框，让用户有机会尝试
      };

      // 设置状态回调
      _audioDetector!.onStatusUpdate = (status) {
        print('Audio detection status: $status');
      };

      // 初始化真实音频检测器
      final initSuccess = await _audioDetector!.initialize();
      if (!initSuccess) {
        print('⚠️ Audio detector initialization failed, but continuing...');
        // 不抛出异常，让用户有机会尝试
      }

      setState(() {
        _audioDetectionEnabled = true; // 默认开启
        _isInitializingAudioDetection = false;
      });

      print('🎯 Audio detection initialization completed');
    } catch (e) {
      print('❌ Error during audio detection initialization: $e');
      setState(() {
        _isInitializingAudioDetection = false;
        _audioDetectionEnabled = true; // 默认开启
      });
      // 重新抛出异常让上层处理
      rethrow;
    }
  }

  /// 🎯 Apple-level Audio Detection Toggle with Enhanced UX
  // 移除整个 _toggleAudioDetection() 方法
  // 移除所有 await _toggleAudioDetection()、onChanged: (value) async { ... } 相关代码

  /// 🎯 Apple-level Error Dialog for Audio Detection
  void _showAudioDetectionErrorDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mic_off, color: Colors.red, size: 20),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Audio Detection Error',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to start audio detection. This could be due to:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Text(
              '• Microphone permission not granted\n'
              '• Microphone being used by another app\n'
              '• Device microphone hardware issue',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                'Try closing other apps that might be using the microphone, or check your device settings.',
                style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// 🎯 Apple-level Training Reset with Audio Detection Management
  void _resetTraining() async {
    // 🎯 Stop audio detection before reset
    if (_audioDetectionEnabled) {
      await _stopAudioDetectionForRound();
    }
    
    setState(() {
      showResultOverlay = false;
      currentRound = 1;
      counter = 0;
      isStarted = false;
      isCounting = false;
      showPreCountdown = false;
    });
    
    print('🎯 Training reset completed with audio detection cleanup');
    _startPreCountdown();
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
      counter = 0;
    });
    
    // 如果是第一个round，初始化tmpResult
    if (currentRound == 1) {
      tmpResult.clear();
    }
    
    // 🎯 Apple-level Audio Detection Integration
    // 如果用户启用了声音检测，在训练开始时自动启动
    print('🎯 Starting round $currentRound, audio detection enabled: $_audioDetectionEnabled');
    if (_audioDetectionEnabled) {
      print('🎯 Audio detection is enabled, starting detection...');
      _startAudioDetectionForRound();
    } else {
      print('🎯 Audio detection is disabled, skipping...');
    }
    
    _tick();
  }

  /// 🎯 Apple-level Audio Detection Management
  /// 为当前round启动声音检测
  Future<void> _startAudioDetectionForRound() async {
    try {
      if (_audioDetector == null) {
        print('⚠️ Audio detector not available, skipping audio detection');
        return;
      }
      
      final success = await _audioDetector!.startListening();
      if (success) {
        print('🎯 Audio detection started for round $currentRound');
        
        // 提供用户反馈（可选）
        if (mounted) {
          // 可以在这里添加轻微的视觉反馈，比如按钮闪烁
          setState(() {
            // 可以添加一个状态来显示音频检测已启动
          });
        }
      } else {
        print('⚠️ Failed to start audio detection for round $currentRound, but continuing...');
        // 不显示错误对话框，让训练继续进行
      }
    } catch (e) {
      print('⚠️ Error starting audio detection: $e, but continuing...');
      // 不显示错误对话框，让训练继续进行
    }
  }

  /// 🎯 Apple-level Audio Detection Stop
  /// 停止当前round的声音检测
  Future<void> _stopAudioDetectionForRound() async {
    try {
      // 添加状态检查，避免重复停止
      if (_audioDetector != null && _audioDetector!.isListening) {
        await _audioDetector!.stopListening();
        print('🎯 Audio detection stopped for round $currentRound');
      } else {
        print('🎯 Audio detection already stopped for round $currentRound');
      }
    } catch (e) {
      print('❌ Error stopping audio detection: $e');
    }
  }

  // 立即显示训练结果（排名为null，等待API返回）
  Future<void> _showImmediateResult() async {
    // 找出最大counts的round
    int maxCounts = 0;
    for (var round in tmpResult) {
      if (round["counts"] > maxCounts) {
        maxCounts = round["counts"];
      }
    }
    
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
    
    // 立即添加结果到history，rank为null表示正在加载
    final result = {
      "rank": null, // 暂时为null，等待API返回
      "date": dateStr,
      "counts": maxCounts,
      "note": "current",
      "totalRounds": totalRounds,
      "roundDuration": roundDuration,
    };
    
    history.insert(0, result);
    
    // 排序并赋rank（除了当前结果）
    history.sort((a, b) => b["counts"].compareTo(a["counts"]));
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

  // 添加round结果到临时结果列表
  void _addRoundToTmpResult(int counts) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = "${months[now.month - 1]} ${now.day}, ${now.year}";
    
    final roundResult = {
      "roundNumber": currentRound,
      "counts": counts,
      "date": dateStr,
      "timestamp": now.millisecondsSinceEpoch,
      "roundDuration": roundDuration,
    };
    
    tmpResult.add(roundResult);
    print('Added round $currentRound result: $counts counts to tmpResult');
  }

  // 提交最终结果到后端
  Future<void> _submitFinalResult() async {
    if (_isSubmittingResult) return; // 防止重复提交
    
    setState(() {
      _isSubmittingResult = true;
    });

    try {
      // 找出最大counts的round
      int maxCounts = 0;
      Map<String, dynamic>? bestRound;
      
      for (var round in tmpResult) {
        if (round["counts"] > maxCounts) {
          maxCounts = round["counts"];
          bestRound = round;
        }
      }
      
      // 更新finalResult
      finalResult["productId"] = widget.productId;
      finalResult["trainingId"] = widget.trainingId;
      finalResult["totalRounds"] = totalRounds;
      finalResult["roundDuration"] = roundDuration;
      finalResult["maxCounts"] = maxCounts;
      finalResult["date"] = DateTime.now().toIso8601String();
      finalResult["bestRound"] = bestRound;
      
      print('Submitting final result: $finalResult');
      
      // 模拟API请求
      final apiResult = await _submitTrainingResult(finalResult);
      
      if (mounted) {
        setState(() {
          // 只更新当前结果的rank
          final currentIdx = history.indexWhere((e) => e["note"] == "current");
          if (currentIdx >= 0) {
            history[currentIdx]["rank"] = apiResult["rank"];
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
      "rank": 1, // 这里应该是从后端返回的实际排名
      "date": dateStr,
      "counts": result["maxCounts"],
      "note": "current",
      "totalRounds": result["totalRounds"],
      "roundDuration": result["roundDuration"],
    };
  }

  // 🎯 Apple-level Enhanced Countdown with Audio Detection
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
      
      // 🎯 Stop audio detection when round ends
      if (_audioDetectionEnabled) {
        await _stopAudioDetectionForRound();
      }
      
      // 当前round结束，记录结果到tmpResult
      _addRoundToTmpResult(counter);
      
      if (currentRound < totalRounds) {
        setState(() {
          currentRound++;
        });
        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        Future.delayed(const Duration(milliseconds: 600), _startPreCountdown);
      } else {
        // 所有round结束，立即显示结果，然后异步提交
        await _showImmediateResult();
        _submitFinalResult();
      }
    }
  }

  void _onStartPressed() {
    _startPreCountdown();
  }

  // 新增：动画状态管理
  bool _isAnimating = false;
  Timer? _animationDebounceTimer;

  void _onCountPressed() {
    if (!isCounting || !mounted) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final interval = now - _lastBounceTime;
    _lastBounceTime = now;

    // 立即更新计数器，避免延迟感
    setState(() {
      counter++;
    });

    // 如果正在动画中，取消防抖定时器并重新开始
    _animationDebounceTimer?.cancel();
    
    // 使用防抖机制，避免频繁动画
    _animationDebounceTimer = Timer(const Duration(milliseconds: 50), () {
      // 再次检查组件是否还存在
      if (mounted) {
        _performBounceAnimation(interval);
      }
    });
  }

  void _performBounceAnimation(int interval) {
    // 如果组件已销毁，不执行动画
    if (!mounted) return;
    
    // 停止当前动画
    bounceController.stop();
    
    // 重置动画状态
    _isAnimating = true;

    if (interval > 400) {
      // 非常慢的点击，柔和弹跳
      bounceController.value = 1.0;
      bounceController.animateTo(1.18, duration: const Duration(milliseconds: 200), curve: Curves.easeInOutCubic)
          .then((_) {
        // 每次回调都检查组件是否还存在
        if (!mounted) return Future.value();
        return bounceController.animateTo(1.0, duration: const Duration(milliseconds: 300), curve: Curves.elasticOut);
      }).then((_) {
        if (mounted) {
          _isAnimating = false;
        }
      }).catchError((error) {
        // 忽略动画错误，避免崩溃
        if (mounted) {
          _isAnimating = false;
        }
      });
    } else if (interval > 200) {
      // 中速点击，正常弹跳
      bounceController.value = 1.0;
      bounceController.animateTo(1.18, duration: const Duration(milliseconds: 120), curve: Curves.easeOut)
          .then((_) {
        if (!mounted) return Future.value();
        return bounceController.animateTo(1.0, duration: const Duration(milliseconds: 180), curve: Curves.elasticOut);
      }).then((_) {
        if (mounted) {
          _isAnimating = false;
        }
      }).catchError((error) {
        if (mounted) {
          _isAnimating = false;
        }
      });
    } else {
      // 快速点击，快速回弹
      bounceController.value = 1.18;
      bounceController.animateTo(1.0, duration: const Duration(milliseconds: 100), curve: Curves.easeOut)
          .then((_) {
        if (mounted) {
          _isAnimating = false;
        }
      }).catchError((error) {
        if (mounted) {
          _isAnimating = false;
        }
      });
    }
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
            roundDuration: roundDuration, // 新增
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
            onResultReset: _resetTraining,
            onResultBack: () {
              Navigator.pop(context);
            },
            onResultSetup: _showSetupDialog,
            isSubmittingResult: _isSubmittingResult, // 新增
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
            roundDuration: roundDuration, // 新增
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
            onResultReset: _resetTraining,
            onResultBack: () {
              Navigator.pop(context);
            },
            onResultSetup: _showSetupDialog,
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
                Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 16),
                // 背景选择
                Text('Background', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                SizedBox(height: 8),
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
}
