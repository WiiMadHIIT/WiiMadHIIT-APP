import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../widgets/floating_logo.dart';
import '../../widgets/elegant_error_display.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/auth_guard_mixin.dart';
import '../../widgets/circle_progress_painter.dart';
import '../../widgets/layout_bg_type.dart';
import '../../widgets/countdown_portrait_layout.dart';
import '../../widgets/countdown_landscape_layout.dart';
import '../../widgets/tiktok_wheel_picker.dart';
import '../../widgets/training_history_ranking_widget.dart';
import '../../widgets/training_setup_dialog.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:io' show Platform;

// 导入倒计时训练领域实体
import '../../domain/entities/checkin_countdown/training_countdown_history_item.dart';
import '../../domain/entities/checkin_countdown/training_countdown_result.dart';
import '../../domain/entities/checkin_countdown/training_countdown_session_config.dart';

// 导入倒计时训练 ViewModel
import 'checkin_countdown_viewmodel.dart';

class CheckinCountdownPage extends StatefulWidget {
  final String trainingId;
  final String? productId;
  const CheckinCountdownPage({Key? key, required this.trainingId, this.productId}) : super(key: key);

  @override
  State<CheckinCountdownPage> createState() => _CheckinCountdownPageState();
}

class _CheckinCountdownPageState extends State<CheckinCountdownPage> with TickerProviderStateMixin, WidgetsBindingObserver, AuthGuardMixin {
  // 移除本地状态管理，改为从 ViewModel 获取
  int currentRound = 1;
  int countdown = 0; // 秒
  int totalSeconds = 0; // 🎯 倒计时训练特有：总训练秒数
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
  LayoutBgType bgType = LayoutBgType.video;
  late AnimationController _videoFadeController;
  
  // 新增：动画状态管理
  bool _isAnimating = false;
  Timer? _animationDebounceTimer;
  
  // 🎯 双默认视频控制器：横屏和竖屏各一个
  VideoPlayerController? _portraitDefaultVideoController;
  VideoPlayerController? _landscapeDefaultVideoController;
  
  // 🎯 当前使用的视频控制器（可能是默认的或远程的）
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  
  CameraController? _cameraController;
  bool _cameraPermissionGranted = false; // 新增：相机权限状态
  bool _isInitializingCamera = false; // 新增：相机初始化状态

  // 🎯 新增：提交结果状态管理
  bool _isSubmittingResult = false;

  // 🎯 临时结果已移至ViewModel中管理

  @override
  void initState() {
    super.initState();
    
    // 🎯 新增：注册应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    try {
      _initializeControllers();
      _initializeVideoController();

      // 🎯 延迟显示设置弹窗，等待认证检查完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 延迟执行，确保认证检查完成
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _showSetupDialog();
          }
        });
      });
      
      // 加载历史训练数据和视频配置
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          // 通过 ViewModel 加载数据
          final viewModel = context.read<CheckinCountdownViewModel>();
          
          // 检查是否有缓存数据，如果有则取消清理定时器
          if (viewModel.hasCachedData) {
            viewModel.cancelCleanup();
          } else {
            // 加载训练数据
            await viewModel.loadTrainingCountdownDataAndVideoConfig(
              widget.trainingId,
              productId: widget.productId,
              limit: 20,
            );
          }
        }
      });
      
    } catch (e) {
      print('❌ Error in initState: $e');
    }
  }

  /// 初始化所有控制器
  void _initializeControllers() {
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
    
    _videoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
  }

  /// 🎯 初始化双默认视频控制器
  void _initializeVideoController() {
    // 🎯 初始化竖屏默认视频控制器
    _portraitDefaultVideoController = VideoPlayerController.asset('assets/video/video1.mp4')
      ..setLooping(true)
      ..setVolume(0.0);
    
    _portraitDefaultVideoController!.initialize().then((_) {
      if (mounted) {
        print('✅ Portrait default video controller initialized');
        _setDefaultVideoController();
      }
    }).catchError((e) {
      print('❌ Portrait default video initialization error: $e');
    });
    
    // 🎯 初始化横屏默认视频控制器
    _landscapeDefaultVideoController = VideoPlayerController.asset('assets/video/video2.mp4')
      ..setLooping(true)
      ..setVolume(0.0);
    
    _landscapeDefaultVideoController!.initialize().then((_) {
      if (mounted) {
        print('✅ Landscape default video controller initialized');
        _setDefaultVideoController();
      }
    }).catchError((e) {
      print('❌ Landscape default video initialization error: $e');
    });
  }
  
  /// 🎯 根据当前屏幕方向设置默认视频控制器
  void _setDefaultVideoController() {
    if (!mounted) return;
    
    final orientation = MediaQuery.of(context).orientation;
    // 🎯 直接获取目标控制器引用，不创建额外变量
    final targetController = orientation == Orientation.portrait 
        ? _portraitDefaultVideoController 
        : _landscapeDefaultVideoController;
    
    // 只有当目标控制器已初始化且与当前控制器不同时才切换
    if (targetController != null && 
        targetController.value.isInitialized && 
        _videoController != targetController) {
      
      // 停止当前视频
      if (_videoController?.value.isPlaying == true) {
        _videoController!.pause();
      }
      
      // 切换到默认视频控制器
      _videoController = targetController;
      _videoReady = true;
      
      // 开始播放
      _videoController!.play();
      
      print('🎯 Switched to ${orientation == Orientation.portrait ? 'portrait' : 'landscape'} default video');
      setState(() {});
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
    
    // 🎯 优化：只在真正需要时重新初始化视频
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _videoReady) {
        _checkAndUpdateVideoIfNeeded();
      }
    });
  }
  
  /// 🎯 检查并更新视频（只在必要时）
  void _checkAndUpdateVideoIfNeeded() {
    if (!mounted) return;
    
    final currentOrientation = MediaQuery.of(context).orientation;
    
    // 🎯 检查当前视频控制器是否与方向匹配
    final shouldUpdate = _shouldUpdateVideoForOrientation(currentOrientation);
    
    if (shouldUpdate) {
      print('🎯 Orientation changed, updating video from ${_getCurrentVideoType()}');
      _onOrientationChanged();
    } else {
      print('🎯 No video update needed for current orientation');
    }
  }
  
  /// 🎯 判断是否需要为当前方向更新视频
  bool _shouldUpdateVideoForOrientation(Orientation orientation) {
    // 🎯 如果当前没有视频控制器，需要更新
    if (_videoController == null) return true;
    
    // 🎯 如果当前是远程视频，不强制更新（保持播放）
    if (_videoController != _portraitDefaultVideoController && 
        _videoController != _landscapeDefaultVideoController) {
      print('🎯 Currently playing remote video, not forcing update');
      return false;
    }
    
    // 🎯 检查默认视频控制器是否与方向匹配
    if (orientation == Orientation.portrait) {
      return _videoController != _portraitDefaultVideoController;
    } else {
      return _videoController != _landscapeDefaultVideoController;
    }
  }
  
  /// 🎯 获取当前视频类型描述
  String _getCurrentVideoType() {
    if (_videoController == _portraitDefaultVideoController) return 'portrait default';
    if (_videoController == _landscapeDefaultVideoController) return 'landscape default';
    return 'remote';
  }

  @override
  void dispose() {
    // 🎯 Apple-level Resource Cleanup
    // 立即停止所有动画和定时器
    _stopAllAnimationsAndTimers();
    
    // 🎯 移除应用生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    
    // 🎯 释放所有控制器资源
    bounceController.dispose();
    pageController.dispose();
    _portraitController?.dispose();
    _landscapeController?.dispose();
    _videoFadeController.dispose();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    
        // 🎯 释放视频控制器资源
    _disposeVideoControllers();
    
    // 智能延迟清理：延迟清理数据以提升用户体验
    try {
      if (mounted) {
        final viewModel = context.read<CheckinCountdownViewModel>();
        viewModel.scheduleCleanup();
      }
    } catch (e) {
      print('Warning: Error scheduling ViewModel cleanup: $e');
    }
    
    print('🎯 All resources cleaned up successfully');
    super.dispose();
  }
  

  
  /// 🎯 释放所有视频控制器资源
  void _disposeVideoControllers() {
    try {
      // 停止当前视频控制器
      if (_videoController?.value.isPlaying == true) {
        _videoController!.pause();
      }
      
      // 释放当前视频控制器（如果不是默认控制器）
      if (_videoController != null && 
          _videoController != _portraitDefaultVideoController && 
          _videoController != _landscapeDefaultVideoController) {
        _videoController!.dispose();
        _videoController = null;
      }
      
      // 🎯 释放竖屏默认视频控制器
      if (_portraitDefaultVideoController != null) {
        if (_portraitDefaultVideoController!.value.isPlaying) {
          _portraitDefaultVideoController!.pause();
        }
        _portraitDefaultVideoController!.dispose();
        _portraitDefaultVideoController = null;
        print('🎯 Portrait default video controller disposed');
      }
      
      // 🎯 释放横屏默认视频控制器
      if (_landscapeDefaultVideoController != null) {
        if (_landscapeDefaultVideoController!.value.isPlaying) {
          _landscapeDefaultVideoController!.pause();
        }
        _landscapeDefaultVideoController!.dispose();
        _landscapeDefaultVideoController = null;
        print('🎯 Landscape default video controller disposed');
      }
      
      // 🎯 重置视频状态
      _videoReady = false;
      
      print('🎯 All video controllers disposed successfully');
    } catch (e) {
      print('❌ Error disposing video controllers: $e');
    }
  }

  /// 🎯 新增：应用生命周期状态变化处理
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 倒计时训练不需要音频检测，所以这里不需要特殊处理
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
    if (_videoController?.value.isPlaying == true) {
      _videoController!.pause();
    }
    
    // 🎯 停止相机流并释放资源
    if (_cameraController != null) {
      try {
        if (_cameraController!.value.isInitialized) {
          _cameraController!.stopImageStream();
        }
        _cameraController!.dispose();
        _cameraController = null;
        _cameraPermissionGranted = false;
        _isInitializingCamera = false;
      } catch (e) {
        print('Warning: Error disposing camera controller: $e');
      }
    }
    
    print('All animations and timers stopped, memory cleaned up');
  }

  /// 🎯 Apple-level Training Reset
  void _resetTraining() async {
    setState(() {
      showResultOverlay = false;
      currentRound = 1;
      isStarted = false;
      isCounting = false;
      showPreCountdown = false;
    });
    
    // 🎯 关键修复：重置PageController回到第一页，确保ROUND显示正确
    if (pageController.hasClients) {
      pageController.animateToPage(
        0, // 回到第一页
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    print('🎯 Countdown training reset completed');
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

    if (mounted) {
      setState(() {
        _isInitializingCamera = true;
      });
    }

    try {
      // 🎯 先释放旧的相机控制器，防止内存泄漏
      if (_cameraController != null) {
        try {
          await _cameraController!.stopImageStream();
          _cameraController!.dispose();
        } catch (e) {
          print('Warning: Error disposing old camera controller: $e');
        }
        _cameraController = null;
        _cameraPermissionGranted = false;
      }

      // 检查可用相机
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showCameraErrorDialog();
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
      
      // 🎯 启动图像流以保持相机活跃
      await _cameraController!.startImageStream((image) {
        // 保持摄像头活跃，但不处理图像数据
      });

      if (mounted) {
        setState(() {
          _cameraPermissionGranted = true;
          _isInitializingCamera = false;
        });
      }

      return true;
    } catch (e) {
      print('iOS Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitializingCamera = false;
        });
      }
      
      // 🎯 出错时清理相机控制器
      if (_cameraController != null) {
        try {
          await _cameraController!.stopImageStream();
          _cameraController!.dispose();
        } catch (e) {
          print('Warning: Error disposing camera controller after error: $e');
        }
        _cameraController = null;
        _cameraPermissionGranted = false;
      }
      
      if (e.toString().contains('permission')) {
        _showCameraPermissionDeniedDialog();
      } else {
        _showCameraErrorDialog();
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

    if (mounted) {
      setState(() {
        _isInitializingCamera = true;
      });
    }

    try {
      // 🎯 先释放旧的相机控制器，防止内存泄漏
      if (_cameraController != null) {
        try {
          await _cameraController!.stopImageStream();
          _cameraController!.dispose();
        } catch (e) {
          print('Warning: Error disposing old camera controller: $e');
        }
        _cameraController = null;
        _cameraPermissionGranted = false;
      }

      // 检查可用相机
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showCameraErrorDialog();
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
      
      // 🎯 启动图像流以保持相机活跃
      await _cameraController!.startImageStream((image) {
        // 保持摄像头活跃，但不处理图像数据
      });

      if (mounted) {
        setState(() {
          _cameraPermissionGranted = true;
          _isInitializingCamera = false;
        });
      }

      return true;
    } catch (e) {
      print('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitializingCamera = false;
        });
      }
      
      // 🎯 出错时清理相机控制器
      if (_cameraController != null) {
        try {
          await _cameraController!.stopImageStream();
          _cameraController!.dispose();
        } catch (e) {
          print('Warning: Error disposing camera controller after error: $e');
        }
        _cameraController = null;
        _cameraPermissionGranted = false;
      }
      
      // 根据错误类型显示不同的提示
      if (e.toString().contains('permission')) {
        _showCameraPermissionDeniedDialog();
      } else {
        _showCameraErrorDialog();
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
  void _showCameraErrorDialog() {
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

  void _showSetupDialog() async {
    final viewModel = context.read<CheckinCountdownViewModel>();
    
    if (mounted) {
      setState(() {
        _isSetupDialogOpen = true;
      });
    }
    
    final config = TrainingSetupConfig(
      initialRounds: viewModel.totalRounds,
      initialRoundDuration: viewModel.roundDuration,
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
        if (mounted) {
          setState(() {
            _isSetupDialogOpen = false;
          });
        }
      },
    );
    
    if (mounted && result != null) {
      // 通过 ViewModel 更新训练配置
      viewModel.updateTrainingCountdownConfig(
        totalRounds: result.rounds,
        roundDuration: result.roundDuration,
        preCountdown: preCountdown, // 🎯 倒计时训练特有：保持预倒计时设置
      );
      
      setState(() {
        currentRound = 1;
        countdown = result.roundDuration;
        _isSetupDialogOpen = false;
      });
    } else if (mounted) {
      setState(() {
        _isSetupDialogOpen = false;
      });
    }
  }

  void _showSetupDialogLandscape() async {
    final viewModel = context.read<CheckinCountdownViewModel>();
    
    if (mounted) {
      setState(() {
        _isSetupDialogOpen = true;
      });
    }
    
    final config = TrainingSetupConfig(
      initialRounds: viewModel.totalRounds,
      initialRoundDuration: viewModel.roundDuration,
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
        if (mounted) {
          setState(() {
            _isSetupDialogOpen = false;
          });
        }
      },
      showResultOverlay: showResultOverlay,
    );
    
    if (mounted && result != null) {
      // 通过 ViewModel 更新训练配置
      viewModel.updateTrainingCountdownConfig(
        totalRounds: result.rounds,
        roundDuration: result.roundDuration,
        preCountdown: preCountdown, // 🎯 倒计时训练特有：保持预倒计时设置
      );
      
      setState(() {
        currentRound = 1;
        countdown = result.roundDuration;
        _isSetupDialogOpen = false;
      });
    } else if (mounted) {
      setState(() {
        _isSetupDialogOpen = false;
      });
    }
  }

  void _startPreCountdown() {
    final viewModel = context.read<CheckinCountdownViewModel>();
    
    // 取消之前的Timer（如果存在）
    _preCountdownTimer?.cancel();
    
    countdown = viewModel.roundDuration;
    setState(() {
      showPreCountdown = true;
      preCountdown = 3;
    });
    _preCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        _preCountdownTimer = null;
        return;
      }
      
      if (preCountdown > 1) {
        setState(() => preCountdown--);
      } else {
        timer.cancel();
        _preCountdownTimer = null; // 清空引用
        if (mounted) {
          setState(() {
            showPreCountdown = false;
          });
          _startRound();
        }
      }
    });
  }

  void _startRound() {
    final viewModel = context.read<CheckinCountdownViewModel>();
    
    setState(() {
      isStarted = true;
      isCounting = true;
      countdown = viewModel.roundDuration;
    });
    
    print('🎯 Starting countdown training round $currentRound');
    
    _tick();
  }

  // 立即显示训练结果（排名为null，等待API返回）
  Future<void> _showImmediateResult() async {
    final viewModel = context.read<CheckinCountdownViewModel>();
    
    // 使用 rounds x roundDuration 计算总秒数（不记录中间值）
    final totalSeconds = viewModel.totalRounds * viewModel.roundDuration;
    
    // 创建临时记录插入到历史数据的第一位
    viewModel.createTemporaryCurrentTrainingCountdownRecord(
      trainingId: widget.trainingId,
      productId: widget.productId,
      seconds: totalSeconds,
    );
    
    setState(() {
      showResultOverlay = true;
      isCounting = false;
    });
    
    // 自动收起榜单
    Future.delayed(Duration(milliseconds: 50), () {
      if (mounted) {
        final orientation = MediaQuery.of(context).orientation;
        final targetSize = orientation == Orientation.landscape ? 1.0 : 0.12;
        final controller = orientation == Orientation.portrait ? _portraitController : _landscapeController;
        controller?.animateTo(targetSize, duration: Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      }
    });
  }

  // 刷新历史数据
  Future<void> _refreshHistory() async {
    final viewModel = context.read<CheckinCountdownViewModel>();
    
    // 重新加载训练数据
    await viewModel.loadTrainingCountdownDataAndVideoConfig(
      widget.trainingId,
      productId: widget.productId,
      limit: 20,
    );
  }

  /// 🎯 根据屏幕方向初始化视频 - 先播放默认视频，异步加载远程视频
  Future<void> _initializeVideoBasedOnOrientation() async {
    try {
      final orientation = MediaQuery.of(context).orientation;
      final viewModel = context.read<CheckinCountdownViewModel>();
      String? videoUrl;
      
      if (orientation == Orientation.portrait) {
        videoUrl = viewModel.portraitVideoUrl;
        print('📱 Using portrait video URL: $videoUrl');
      } else {
        videoUrl = viewModel.landscapeVideoUrl;
        print('🖥️ Using landscape video URL: $videoUrl');
      }
      
      // 🎯 先确保默认视频正在播放
      _setDefaultVideoController();
      
      // 🎯 如果远程URL可用，异步尝试加载远程视频
      if (videoUrl != null && videoUrl.isNotEmpty && videoUrl != 'null') {
        print('🌐 Starting async remote video loading: $videoUrl');
        _initializeRemoteVideoAsync(videoUrl);
      } else {
        print('📁 No remote video URL, keeping default video');
      }
    } catch (e) {
      print('❌ Error initializing video based on orientation: $e');
      // 出错时确保默认视频播放
      _setDefaultVideoController();
    }
  }

  /// 🎯 异步初始化远程视频 - 不阻塞默认视频播放
  void _initializeRemoteVideoAsync(String videoUrl) async {
    VideoPlayerController? remoteController;
    
    try {
      print('🌐 Starting async remote video initialization: $videoUrl');
      
      // 创建新的远程视频控制器
      remoteController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..setLooping(true)
        ..setVolume(0.0);
      
      // 异步初始化远程视频
      await remoteController.initialize();
      
      if (mounted) {
        print('✅ Remote video initialized successfully, switching from default video');
        
        // 停止默认视频
        if (_videoController?.value.isPlaying == true) {
          _videoController!.pause();
        }
        
        // 切换到远程视频
        _videoController = remoteController;
        _videoReady = true;
        
        // 开始播放远程视频
        _videoController!.play();
        
        setState(() {});
        print('🎯 Successfully switched to remote video');
        
        // 🎯 重要：将 remoteController 设为 null，避免重复释放
        remoteController = null;
      } else {
        // 组件已销毁，释放远程视频控制器
        _disposeController(remoteController);
      }
    } catch (e) {
      print('❌ Error initializing remote video: $e');
      // 远程视频失败，保持默认视频播放
      print('🔄 Keeping default video due to remote video failure');
      
      // 🎯 确保释放失败的远程视频控制器
      if (remoteController != null) {
        _disposeController(remoteController);
      }
    }
  }
  
  /// 🎯 安全释放视频控制器
  void _disposeController(VideoPlayerController? controller) {
    if (controller == null) return;
    
    try {
      if (controller.value.isPlaying) {
        controller.pause();
      }
      controller.dispose();
      print('🎯 Video controller disposed successfully');
    } catch (e) {
      print('❌ Error disposing failed video controller: $e');
    }
  }

  /// 🎯 初始化默认本地视频 - 使用预加载的默认视频控制器
  Future<void> _initializeDefaultVideo() async {
    try {
      print('📁 Switching to default video');
      
      // 🎯 直接使用预加载的默认视频控制器
      _setDefaultVideoController();
      
      if (mounted) {
        setState(() {});
        print('✅ Default video activated successfully');
      }
    } catch (e) {
      print('❌ Error activating default video: $e');
      // 出错时尝试重新设置默认视频
      if (mounted) {
        _setDefaultVideoController();
      }
    }
  }

  /// 🎯 屏幕方向改变时重新初始化视频
  void _onOrientationChanged() {
    // 🎯 检查当前是否在播放远程视频
    final isPlayingRemoteVideo = _videoController != _portraitDefaultVideoController && 
                                 _videoController != _landscapeDefaultVideoController;
    
    if (isPlayingRemoteVideo) {
      print('🎯 Currently playing remote video, not switching to default video');
      // 🎯 如果正在播放远程视频，只尝试加载对应方向的远程视频
      if (mounted) {
        _initializeVideoBasedOnOrientation();
      }
    } else {
      // 🎯 如果播放的是默认视频，先切换到对应方向的默认视频
      _setDefaultVideoController();
      
      // 🎯 然后异步加载远程视频（如果可用）
      if (mounted) {
        _initializeVideoBasedOnOrientation();
      }
    }
  }

  /// 提交最终结果到后端
  Future<void> _submitFinalResult() async {
    if (_isSubmittingResult) return;
    
    try {
    setState(() {
      _isSubmittingResult = true;
    });

      final viewModel = context.read<CheckinCountdownViewModel>();
      
      // 🎯 直接计算总秒数：轮次 × 轮次时长
      final totalSeconds = viewModel.totalRounds * viewModel.roundDuration;
      
      // 创建倒计时训练结果实体
      final trainingCountdownResult = TrainingCountdownResult.create(
        trainingId: widget.trainingId,
        productId: widget.productId,
        totalRounds: viewModel.totalRounds,
        roundDuration: viewModel.roundDuration,
        seconds: totalSeconds,
      );
      
      print('Submitting countdown training result: $trainingCountdownResult');
      
      // 🎯 关键修改：使用返回的提交结果，而不是重新请求历史数据
      final response = await viewModel.submitTrainingCountdownResult(trainingCountdownResult);
      
      if (mounted && response != null) {
        // ✅ 提交成功，数据已经在ViewModel中更新，无需重新请求
        print('✅ Countdown training result submitted successfully with rank: ${response.rank}');
        
      }
    } catch (e) {
      print('Error submitting countdown training result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit countdown training result: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingResult = false;
        });
      }
    }
  }

  // 🎯 Apple-level Enhanced Countdown for Countdown Training
  void _tick() async {
    if (!isCounting || !mounted) return;
    if (countdown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        countdown--;
      });
      _onCountPressed(); // 每秒自动触发弹跳动画
      if (mounted) {
        _tick();
      }
    } else {
      if (!mounted) return;
      
      final viewModel = context.read<CheckinCountdownViewModel>();
      if (currentRound < viewModel.totalRounds) {
        setState(() {
          currentRound++;
        });
        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            _startPreCountdown();
          }
        });
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

  void _onCountPressed() {
    // 🎯 倒计时训练不需要手动计数，但保留动画效果用于视觉反馈
    if (!mounted) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final interval = now - _lastBounceTime;
    _lastBounceTime = now;

    // 使用防抖机制，避免频繁动画
    _animationDebounceTimer?.cancel();
    
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
    // 从 ViewModel 获取数据
    final viewModel = context.watch<CheckinCountdownViewModel>();
    final double diameter = MediaQuery.of(context).size.width * 3 / 4;
    final orientation = MediaQuery.of(context).orientation;
    final bool isPortrait = orientation == Orientation.portrait;
    final DraggableScrollableController controller =
        isPortrait ? _portraitController! : _landscapeController!;

    // 检查加载状态和错误状态
    if (viewModel.isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 22,
                  tooltip: 'Back',
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: ElegantErrorDisplay(
                error: viewModel.error ?? 'An unknown error occurred',
                onRetry: () {
                  viewModel.clearError();
                  _refreshHistory();
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 22,
                  tooltip: 'Back',
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 🎯 视频组件：优先显示默认视频，避免黑屏
    final Widget videoWidget = _videoReady && _videoController != null
        ? FadeTransition(
            opacity: _videoFadeController,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          )
        : Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );

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
            totalRounds: viewModel.totalRounds,
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
            roundDuration: viewModel.roundDuration,
            showResultOverlay: showResultOverlay,
            history: _convertHistoryToMapList(viewModel.history),
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
            videoWidget: videoWidget,
            selfieWidget: selfieWidget,
            bgType: bgType,
            onBgSwitchPressed: _onBgSwitchPressed,
            dynamicBgColor: _dynamicBgColor,
            isSubmittingResult: viewModel.isSubmitting,
          )
        : CountdownLandscapeLayout(
            totalRounds: viewModel.totalRounds,
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
            roundDuration: viewModel.roundDuration,
            showResultOverlay: showResultOverlay,
            history: _convertHistoryToMapList(viewModel.history),
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
            videoWidget: videoWidget,
            selfieWidget: selfieWidget,
            bgType: bgType,
            dynamicBgColor: _dynamicBgColor,
            isSubmittingResult: viewModel.isSubmitting,
          );

    return Scaffold(
      body: mainContent,
    );
  }

  /// 将倒计时训练领域实体转换为布局组件期望的Map格式
  List<Map<String, dynamic>> _convertHistoryToMapList(List<TrainingCountdownHistoryItem> history) {
    return history.map((item) => {
      'rank': item.rank,
      'date': item.displayDate,
      'seconds': item.seconds, // 🎯 倒计时训练特有：使用seconds字段
      'daySeconds': item.daySeconds, // ✅ 新增：包含daySeconds字段
      'note': item.note ?? '',
      'additionalData': item,
    }).toList();
  }

  Widget _buildHistoryRanking(ScrollController scrollController) {
    final viewModel = context.read<CheckinCountdownViewModel>();
    
    // 将倒计时训练领域实体转换为Map格式，与tmp文件保持一致
    final historyData = _convertHistoryToMapList(viewModel.history);

    return TrainingHistoryRankingWidget(
      history: historyData,
      scrollController: scrollController,
      title: 'TOP SCORES',
      showCount: true,
      currentNote: 'current',
      rankField: 'rank',
      dateField: 'date',
      secondsField: 'seconds',
      noteField: 'note',
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
        if (mounted) {
          setState(() {
            bgType = type;
          });
          if (type == LayoutBgType.video && _videoReady && _videoController != null) {
            _videoController!.play();
            _videoFadeController.forward();
          }
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