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
import '../../widgets/history_ranking_widget.dart';
import '../../widgets/microphone_permission_manager.dart';
import '../../widgets/training_setup_dialog.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io' show Platform;

// 新增：导入音频会话相关包（如果可用）
// import 'package:audio_session/audio_session.dart';

class CheckinTrainingPage extends StatefulWidget {
  final String trainingId;
  final String? productId;
  const CheckinTrainingPage({Key? key, required this.trainingId, this.productId}) : super(key: key);

  @override
  State<CheckinTrainingPage> createState() => _CheckinTrainingPageState();
}

class _CheckinTrainingPageState extends State<CheckinTrainingPage> with TickerProviderStateMixin, WidgetsBindingObserver {
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

  // 视频配置相关
  String? _portraitVideoUrl; // 竖屏视频URL
  String? _landscapeVideoUrl; // 横屏视频URL
  bool _isLoadingVideoConfig = false; // 视频配置加载状态
  String? _videoConfigError; // 视频配置错误

  // 历史排名数据 - 从API获取
  List<Map<String, dynamic>> history = [];
  
  // 历史数据加载状态
  bool _isLoadingHistory = false;
  String? _historyError;

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
  
  // 声音检测相关 - 使用权限管理器
  MicrophonePermissionManager? _permissionManager;

  @override
  void initState() {
    super.initState();
    
    // 🎯 新增：注册应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    try {
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
    
      // 安全初始化视频控制器 - 使用默认视频，后续会根据配置更新
      _videoController = VideoPlayerController.asset('assets/video/video1.mp4')
        ..setLooping(true)
        ..setVolume(0.0)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _videoReady = true;
            });
            _videoController.play();
          }
        }).catchError((e) {
          print('❌ Video initialization error: $e');
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
        "maxCounts": 0
      };
      
      // 🎯 初始化权限管理器
      _initializePermissionManager();
      
      // 🎯 加载历史训练数据和视频配置（不依赖权限，优先加载）
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await _loadTrainingDataAndVideoConfig();
        }
      });
      
    } catch (e) {
      print('❌ Error in initState: $e');
      // 初始化失败时，显示权限要求对话框
      if (mounted) {
        _permissionManager?.showMicrophonePermissionRequiredDialog(context);
      }
    }
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
    
    // 监听屏幕方向变化，重新初始化视频
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _videoReady && !_isLoadingVideoConfig) {
        _onOrientationChanged();
      }
    });
  }

  @override
  void dispose() {
    // 🎯 Apple-level Resource Cleanup
    // 立即停止所有动画和定时器
    _stopAllAnimationsAndTimers();
    
    // 🎯 移除应用生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    
    // 🎯 清理权限管理器
    _permissionManager?.dispose();
    _permissionManager = null;
    
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

  /// 🎯 初始化权限管理器
  void _initializePermissionManager() {
    _permissionManager = MicrophonePermissionManager();
    
    // 设置回调函数
    _permissionManager!.onPermissionGranted = () {
      if (mounted) {
        _showSetupDialog();
      }
    };
    
    _permissionManager!.onPermissionDenied = () {
      if (mounted) {
        _permissionManager!.showMicrophonePermissionRequiredDialog(context);
      }
    };
    
    _permissionManager!.onAudioDetectionReady = () {
      print('🎯 Audio detection ready');
    };
    
    _permissionManager!.onStrikeDetected = () {
      // 音频检测到打击时，自动触发计数
      if (isCounting && mounted) {
        _onCountPressed();
      }
    };
    
    _permissionManager!.onError = (error) {
      print('❌ Permission manager error: $error');
    };
    
    // 延迟执行权限检查
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(Duration(milliseconds: 500), () async {
        if (!mounted) return;
        
        try {
          print('🎯 Starting permission check...');
          bool permissionGranted = await _permissionManager!.requestMicrophonePermissionDirectly();
          
          // 只有在权限未授予时才启动权限状态监听
          if (!permissionGranted && mounted) {
            _permissionManager!.startEnhancedPermissionListener();
          }
        } catch (e) {
          print('❌ Error during permission initialization: $e');
          if (mounted) {
            _permissionManager!.showMicrophonePermissionRequiredDialog(context);
          }
        }
      });
    });
  }

  /// 🎯 新增：应用生命周期状态变化处理
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _permissionManager?.handleAppLifecycleStateChange(state);
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
    
    // 停止音频检测
    _permissionManager?.stopAudioDetectionForRound();
    
    print('All animations and timers stopped, memory cleaned up');
  }

  /// 🎯 Apple-level Training Reset with Audio Detection Management
  void _resetTraining() async {
    // 🎯 Stop audio detection before reset 
    await _permissionManager?.stopAudioDetectionForRound();
    
    setState(() {
      showResultOverlay = false;
      currentRound = 1;
      counter = 0;
      isStarted = false;
      isCounting = false;
      showPreCountdown = false;
    });
    
    print('🎯 Training reset completed with stream audio detection cleanup');
    _startPreCountdown();
  }

  // 新增：请求相机权限并初始化相机
  Future<bool> _requestCameraPermissionAndInitialize() async {
    if (Platform.isIOS) {
      // iOS: 通过实际调用相机API触发权限弹窗
      return await _requestCameraPermissionForIOS();
    } else {
      // Android: 使用原有逻辑
      return await _requestCameraPermissionForAndroid();
    }
  }

  /// 🍎 Apple-level iOS-Specific Camera Permission Request
  Future<bool> _requestCameraPermissionForIOS() async {
    if (_cameraPermissionGranted && _cameraController != null) {
      return true;
    }

    if (_isInitializingCamera) {
        return false;
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
        orElse: () => cameras[0],
      );

      // 创建相机控制器
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // 初始化相机（这会触发iOS权限弹窗）
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
      print('iOS Camera initialization error: $e');
      setState(() {
        _isInitializingCamera = false;
      });
      
      if (e.toString().contains('permission')) {
        _showCameraPermissionDeniedDialog();
      } else {
        _showCameraErrorDialog('Failed to initialize camera. Please try again.');
      }
      
          return false;
        }
      }

  /// 🍎 Apple-level Android Camera Permission Request
  Future<bool> _requestCameraPermissionForAndroid() async {
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
    
    final config = TrainingSetupConfig(
      initialRounds: totalRounds,
      initialRoundDuration: roundDuration,
      maxRounds: 10,
      maxMinutes: 60,
      maxSeconds: 59,
      title: 'Set Rounds & Time',
      roundsColor: Colors.orange,
      timeColor: Colors.deepPurple,
    );
    
    final result = await TrainingSetupDialog.showPortrait(
      context,
      config: config,
      onClose: () {
                setState(() {
                  _isSetupDialogOpen = false;
                });
      },
    );
    
    if (result != null) {
                            setState(() {
        totalRounds = result.rounds;
        roundDuration = result.roundDuration;
                              currentRound = 1;
        countdown = roundDuration;
                              _isSetupDialogOpen = false;
                            });
    } else {
    setState(() {
      _isSetupDialogOpen = false;
    });
    }
  }

  void _showSetupDialogLandscape() async {
    setState(() {
      _isSetupDialogOpen = true;
    });
    
    final config = TrainingSetupConfig(
      initialRounds: totalRounds,
      initialRoundDuration: roundDuration,
      maxRounds: 10,
      maxMinutes: 60,
      maxSeconds: 59,
      title: 'Set Rounds & Time',
      roundsColor: Colors.orange,
      timeColor: Colors.deepPurple,
    );
    
    final result = await TrainingSetupDialog.showLandscape(
      context,
      config: config,
      onClose: () {
                setState(() {
                  _isSetupDialogOpen = false;
                });
      },
      showResultOverlay: showResultOverlay,
    );
    
    if (result != null) {
                                      setState(() {
        totalRounds = result.rounds;
        roundDuration = result.roundDuration;
                                        currentRound = 1;
        countdown = roundDuration;
                                        _isSetupDialogOpen = false;
                                      });
    } else {
    setState(() {
      _isSetupDialogOpen = false;
    });
    }
  }



  void _startPreCountdown() {
    // 取消之前的Timer（如果存在）
    _preCountdownTimer?.cancel();
    
    countdown = roundDuration;
    setState(() {
      showPreCountdown = true;
      preCountdown = 3;
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
    // 直接启动音频检测，内部已有状态检查
    print('🎯 Starting round $currentRound');
    _permissionManager?.startAudioDetectionForRound();
    
    // 🎯 新增：打印音频检测状态
    _permissionManager?.printAudioDetectionStatus();
    
    _tick();
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
      "id": "temp_${DateTime.now().millisecondsSinceEpoch}", // 临时ID
      "trainingId": widget.trainingId,
      "productId": widget.productId,
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
    
    final roundResult = {
      "roundNumber": currentRound,
      "counts": counts,
      "timestamp": now.millisecondsSinceEpoch,
      "roundDuration": roundDuration,
    };
    
    tmpResult.add(roundResult);
    print('Added round $currentRound result: $counts counts to tmpResult');
  }

  // 清理临时结果数据
  void _clearTmpResult() {
    tmpResult.clear();
    print('Cleared tmpResult after final submission');
  }

  // 获取历史训练数据和视频配置
  Future<void> _loadTrainingDataAndVideoConfig() async {
    if (_isLoadingHistory || _isLoadingVideoConfig) return; // 防止重复请求
    
    setState(() {
      _isLoadingHistory = true;
      _isLoadingVideoConfig = true;
      _historyError = null;
      _videoConfigError = null;
    });

    try {
      print('🔄 Loading training data and video config for trainingId: ${widget.trainingId}, productId: ${widget.productId}');
      
      // 模拟API请求延迟
      await Future.delayed(Duration(milliseconds: 800));
      
      // 模拟API返回的历史数据和视频配置
      final apiResponse = await _getTrainingDataAndVideoConfigApi();
      
      if (mounted) {
        setState(() {
          history = apiResponse['history'];
          _portraitVideoUrl = apiResponse['videoConfig']['portraitUrl'];
          _landscapeVideoUrl = apiResponse['videoConfig']['landscapeUrl'];
          _isLoadingHistory = false;
          _isLoadingVideoConfig = false;
        });
        
        // 根据当前屏幕方向初始化视频
        await _initializeVideoBasedOnOrientation();
        
        print('✅ Training data and video config loaded successfully: ${history.length} records');
      }
    } catch (e) {
      print('❌ Error loading training data and video config: $e');
      if (mounted) {
        setState(() {
          _historyError = e.toString();
          _videoConfigError = e.toString();
          _isLoadingHistory = false;
          _isLoadingVideoConfig = false;
        });
        
        // 使用默认视频配置
        await _initializeDefaultVideo();
      }
    }
  }



  // 模拟获取历史数据和视频配置的API请求
  Future<Map<String, dynamic>> _getTrainingDataAndVideoConfigApi() async {
    // 模拟网络请求
    await Future.delayed(Duration(milliseconds: 500));
    
    // 根据trainingId和productId返回不同的模拟数据
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    // 模拟历史数据
    final mockHistoryData = [
      {
        "id": "662553355",
        "rank": 1,
        "timestamp": now.subtract(Duration(days: 2)).millisecondsSinceEpoch,
        "counts": 25,
        "note": "",
      },
      {
        "id": "662553356",
        "rank": 2,
        "timestamp": now.subtract(Duration(days: 5)).millisecondsSinceEpoch,
        "counts": 22,
        "note": "",
      },
      {
        "id": "662553357",
        "rank": 3,
        "timestamp": now.subtract(Duration(days: 8)).millisecondsSinceEpoch,
        "counts": 19,
        "note": "",
      },
      {
        "id": "662553358",
        "rank": 4,
        "timestamp": now.subtract(Duration(days: 12)).millisecondsSinceEpoch,
        "counts": 18,
        "note": "",
      },
      {
        "id": "662553359",
        "rank": 5,
        "timestamp": now.subtract(Duration(days: 15)).millisecondsSinceEpoch,
        "counts": 16,
        "note": "",
      },
    ];
    
    // 模拟视频配置数据
    final mockVideoConfig = {
      "portraitUrl": "https://example.com/videos/training_portrait.mp4", // 远程竖屏视频URL
      "landscapeUrl": "https://example.com/videos/training_landscape.mp4", // 远程横屏视频URL
    };
    
    // 转换为UI显示格式
    final historyData = mockHistoryData.map((item) {
      final date = DateTime.fromMillisecondsSinceEpoch(item["timestamp"] as int);
      final dateStr = "${months[date.month - 1]} ${date.day}, ${date.year}";
      
      return {
        "rank": item["rank"],
        "date": dateStr,
        "counts": item["counts"],
        "note": item["note"],
        "id": item["id"],
      };
    }).toList();
    
    // 返回历史数据和视频配置
    return {
      "history": historyData,
      "videoConfig": mockVideoConfig,
    };
  }



  // 刷新历史数据
  Future<void> _refreshHistory() async {
    if (_isLoadingHistory) return;
    await _loadTrainingDataAndVideoConfig();
  }

  // 根据屏幕方向初始化视频
  Future<void> _initializeVideoBasedOnOrientation() async {
    try {
      final orientation = MediaQuery.of(context).orientation;
      String? videoUrl;
      
      if (orientation == Orientation.portrait) {
        videoUrl = _portraitVideoUrl;
        print('📱 Using portrait video URL: $videoUrl');
      } else {
        videoUrl = _landscapeVideoUrl;
        print('🖥️ Using landscape video URL: $videoUrl');
      }
      
      // 如果远程URL可用，尝试使用远程视频
      if (videoUrl != null && videoUrl.isNotEmpty && videoUrl != 'null') {
        await _initializeRemoteVideo(videoUrl);
      } else {
        // 使用默认本地视频
        await _initializeDefaultVideo();
      }
    } catch (e) {
      print('❌ Error initializing video based on orientation: $e');
      await _initializeDefaultVideo();
    }
  }

  // 初始化远程视频
  Future<void> _initializeRemoteVideo(String videoUrl) async {
    try {
      print('🌐 Initializing remote video: $videoUrl');
      
      // 停止当前视频
      if (_videoController.value.isPlaying) {
        await _videoController.pause();
      }
      
      // 释放当前控制器
      await _videoController.dispose();
      
      // 创建新的远程视频控制器
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..setLooping(true)
        ..setVolume(0.0);
      
      // 初始化远程视频
      await _videoController.initialize();
      
      if (mounted) {
    setState(() {
          _videoReady = true;
        });
        _videoController.play();
        print('✅ Remote video initialized successfully');
      }
    } catch (e) {
      print('❌ Error initializing remote video: $e');
      // 远程视频失败，回退到默认视频
      await _initializeDefaultVideo();
    }
  }

  // 初始化默认本地视频
  Future<void> _initializeDefaultVideo() async {
    try {
      print('📁 Initializing default local video');
      
      final orientation = MediaQuery.of(context).orientation;
      String defaultVideoPath;
      
      if (orientation == Orientation.portrait) {
        defaultVideoPath = 'assets/video/video1.mp4'; // 竖屏默认视频
        print('📱 Using default portrait video: $defaultVideoPath');
      } else {
        defaultVideoPath = 'assets/video/video2.mp4'; // 横屏默认视频
        print('🖥️ Using default landscape video: $defaultVideoPath');
      }
      
      // 停止当前视频
      if (_videoController.value.isPlaying) {
        await _videoController.pause();
      }
      
      // 释放当前控制器
      await _videoController.dispose();
      
      // 创建新的本地视频控制器
      _videoController = VideoPlayerController.asset(defaultVideoPath)
        ..setLooping(true)
        ..setVolume(0.0);
      
      // 初始化本地视频
      await _videoController.initialize();
      
      if (mounted) {
        setState(() {
          _videoReady = true;
        });
        _videoController.play();
        print('✅ Default local video initialized successfully');
      }
    } catch (e) {
      print('❌ Error initializing default video: $e');
      // 如果连默认视频都失败，尝试使用video1.mp4作为最后的回退
      try {
        await _videoController.dispose();
        _videoController = VideoPlayerController.asset('assets/video/video1.mp4')
          ..setLooping(true)
          ..setVolume(0.0);
        await _videoController.initialize();
        if (mounted) {
          setState(() {
            _videoReady = true;
          });
          _videoController.play();
          print('✅ Fallback video initialized successfully');
        }
      } catch (fallbackError) {
        print('❌ Error initializing fallback video: $fallbackError');
      }
    }
  }

  // 屏幕方向改变时重新初始化视频
  void _onOrientationChanged() {
    if (_videoReady) {
      _initializeVideoBasedOnOrientation();
    }
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
      
      for (var round in tmpResult) {
        if (round["counts"] > maxCounts) {
          maxCounts = round["counts"];
        }
      }
      
      // 更新finalResult
      finalResult["productId"] = widget.productId;
      finalResult["trainingId"] = widget.trainingId;
      finalResult["totalRounds"] = totalRounds;
      finalResult["roundDuration"] = roundDuration;
      finalResult["maxCounts"] = maxCounts;
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
        
        // 清理临时结果数据
        _clearTmpResult();
        
        // 可选：重新加载历史数据以确保数据一致性
        // await _loadTrainingDataAndVideoConfig();
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

    // 模拟进行API请求，返回结果
    final apiRespondData =  {
      "id": "662553355",
      "rank": 1, // 这里应该是从后端返回的实际排名
      "totalRounds": result["totalRounds"],
      "roundDuration": result["roundDuration"],
    };
    
    // 模拟返回的排名数据
    return apiRespondData;
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
      await _permissionManager?.stopAudioDetectionForRound();
      
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
    // 将原始数据转换为通用组件的数据格式
    final rankingItems = history.map((e) => HistoryRankingItem(
      rank: e["rank"],
      date: e["date"] ?? "",
      counts: e["counts"] ?? 0,
      note: e["note"],
      additionalData: e,
    )).toList();

    return HistoryRankingWidget(
      history: rankingItems,
      scrollController: scrollController,
      config: const HistoryRankingConfig(
        title: 'TOP SCORES',
        currentItemColor: Colors.redAccent,
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
                Text('Background', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 16),
                // 背景选择
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

