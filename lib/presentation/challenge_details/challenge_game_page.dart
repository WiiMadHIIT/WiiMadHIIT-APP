import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../widgets/floating_logo.dart';
import '../../widgets/elegant_error_display.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/auth_guard_mixin.dart';
import '../../widgets/challenge_portrait_layout.dart';
import '../../widgets/challenge_landscape_layout.dart';
import '../../widgets/circle_progress_painter.dart';
import '../../widgets/layout_bg_type.dart';
import '../../widgets/tiktok_wheel_picker.dart';
import '../../widgets/challenge_history_ranking_widget.dart';
import '../../widgets/microphone_permission_manager.dart';
import '../../widgets/training_setup_dialog.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io' show Platform;

// 🎯 导入challenge_game领域实体
import '../../domain/entities/challenge_game/challenge_game_history_item.dart';
import '../../domain/entities/challenge_game/challenge_game_result.dart';
import '../../domain/entities/challenge_game/challenge_game_session_config.dart';

// 🎯 导入challenge_game ViewModel
import 'challenge_game_viewmodel.dart';

// 🎯 导入challenge_game用例
import '../../domain/usecases/get_challenge_game_data_and_video_config_usecase.dart';
import '../../domain/services/challenge_game_service.dart';
import '../../data/repository/challenge_game_repository.dart';
import '../../data/api/challenge_game_api.dart';

class ChallengeGamePage extends StatelessWidget {
  final String challengeId; // 🎯 修改：使用challengeId
  final int? totalRounds; // 🎯 新增：接收总轮次数
  final int? roundDuration; // 🎯 新增：接收每轮时长
  final int? allowedTimes; // 🎯 新增：接收剩余挑战次数
  
  const ChallengeGamePage({
    Key? key, 
    required this.challengeId,
    this.totalRounds,
    this.roundDuration,
    this.allowedTimes, // 🎯 新增：接收剩余挑战次数
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChallengeGameViewModel(
        getChallengeGameDataAndVideoConfigUseCase: GetChallengeGameDataAndVideoConfigUseCase(
          ChallengeGameRepositoryImpl(ChallengeGameApi()),
        ),
        submitChallengeGameResultUseCase: SubmitChallengeGameResultUseCase(
          ChallengeGameRepositoryImpl(ChallengeGameApi()),
        ),
        challengeGameService: ChallengeGameService(),
      ),
      child: _ChallengeGamePageContent(
        challengeId: challengeId,
        totalRounds: totalRounds,
        roundDuration: roundDuration,
        allowedTimes: allowedTimes, // 🎯 新增：传递剩余挑战次数
      ),
    );
  }
}

class _ChallengeGamePageContent extends StatefulWidget {
  final String challengeId;
  final int? totalRounds;
  final int? roundDuration;
  final int? allowedTimes; // 🎯 新增：接收剩余挑战次数
  
  const _ChallengeGamePageContent({
    required this.challengeId,
    this.totalRounds,
    this.roundDuration,
    this.allowedTimes, // 🎯 新增：接收剩余挑战次数
  });

  @override
  State<_ChallengeGamePageContent> createState() => _ChallengeGamePageState();
}

class _ChallengeGamePageState extends State<_ChallengeGamePageContent> with TickerProviderStateMixin, WidgetsBindingObserver, AuthGuardMixin {
  // 🎯 移除本地状态管理，改为从 ViewModel 获取
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
  
  // 声音检测相关 - 使用权限管理器
  MicrophonePermissionManager? _permissionManager;

  @override
  void initState() {
    super.initState();
    
    // 🎯 新增：注册应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    try {
      _initializeControllers();
      _initializeVideoController();
      _initializePermissionManager();
      
                // 🎯 苹果级优化：智能加载历史挑战游戏数据和视频配置
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (mounted) {
              // 通过 ViewModel 加载数据
              final viewModel = context.read<ChallengeGameViewModel>();
              
              // 🎯 如果从路由参数接收到了配置参数，直接设置到ViewModel
              if (widget.totalRounds != null && widget.roundDuration != null) {
                viewModel.updateChallengeGameConfig(
                  totalRounds: widget.totalRounds!,
                  roundDuration: widget.roundDuration!,
                  allowedTimes: widget.allowedTimes, // 🎯 新增：设置初始剩余挑战次数
                );
                print('🎯 Set challenge config from route params: ${widget.totalRounds} rounds, ${widget.roundDuration}s, ${widget.allowedTimes} attempts');
              }
              
              // 🎯 使用智能加载策略：避免不必要的重复请求
              await viewModel.smartLoadChallengeGameData(
                widget.challengeId, // 🎯 修改：使用challengeId
                limit: 20,
              );
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
      if (mounted && _videoReady) {
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
    
    // 🎯 新增：清理ViewModel中的内存数据
    _cleanupViewModelData();
    
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
  
  /// 🎯 苹果级优化：清理ViewModel中的内存数据
  void _cleanupViewModelData() {
    try {
      if (mounted) {
        final viewModel = context.read<ChallengeGameViewModel>();
        
        // 🎯 使用智能清理策略：保留核心数据，避免重新请求API
        viewModel.smartCleanup();
        
        print('🎯 ChallengeGameViewModel smart cleanup completed');
      }
    } catch (e) {
      print('⚠️ Warning: Error cleaning up ViewModel data: $e');
    }
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
    
    // 停止音频检测
    _permissionManager?.stopAudioDetectionForRound();
    
    print('All animations and timers stopped, memory cleaned up');
  }

  /// 🎯 Apple-level Challenge Game Reset with Audio Detection Management
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
    
    print('🎯 Challenge game reset completed with stream audio detection cleanup');
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
    final viewModel = context.read<ChallengeGameViewModel>();
    
    if (mounted) {
      setState(() {
        _isSetupDialogOpen = true;
      });
    }
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => OrientationBuilder(
        builder: (context, orientation) {
          // 🎯 实时响应屏幕方向变化
          if (orientation == Orientation.landscape) {
            // 横屏时显示横屏布局
            return _buildLandscapeDialogContent(viewModel);
          } else {
            // 竖屏时显示竖屏布局
            return _buildPortraitDialogContent(viewModel);
          }
        },
      ),
    );
    
    if (mounted) {
      setState(() {
        _isSetupDialogOpen = false;
      });
    }
  }
  
  // 辅助方法：构建简洁的配置行
  Widget _buildSimpleConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 🎯 构建竖屏对话框内容
  Widget _buildPortraitDialogContent(ChallengeGameViewModel viewModel) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 300,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 简洁的头部
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.sports_esports,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Challenge Setup',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // 简洁的内容区域
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 配置信息 - 更简洁的布局
                  _buildSimpleConfigRow('Rounds', '${viewModel.totalRounds}'),
                  _buildSimpleConfigRow('Duration', '${viewModel.roundDuration}s'),
                  _buildSimpleConfigRow('Attempts', viewModel.allowedTimes > 0 ? '${viewModel.allowedTimes}' : 'None'),
                  
                  const SizedBox(height: 10),
                  
                  // 简洁的规则说明
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Best round performance determines your final score',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey[700],
                              height: 1.2,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Got it',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 🎯 构建横屏对话框内容
  Widget _buildLandscapeDialogContent(ChallengeGameViewModel viewModel) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左侧简洁信息
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_esports,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Challenge\nSetup',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // 右侧简洁内容
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 配置信息 - 横屏简洁布局
                    _buildSimpleConfigRow('Rounds', '${viewModel.totalRounds}'),
                    _buildSimpleConfigRow('Duration', '${viewModel.roundDuration}s'),
                    _buildSimpleConfigRow('Attempts', viewModel.allowedTimes > 0 ? '${viewModel.allowedTimes}' : 'None'),
                    
                    const SizedBox(height: 16),
                    
                    // 简洁规则说明
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Best round performance determines your final score',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[700],
                                height: 1.2,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Got it',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _startPreCountdown() {
    final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
    
    // 取消之前的Timer（如果存在）
    _preCountdownTimer?.cancel();
    
    countdown = viewModel.roundDuration; // 🎯 修改：使用viewModel.roundDuration
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
    final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
    
    setState(() {
      isStarted = true;
      isCounting = true;
      countdown = viewModel.roundDuration; // 🎯 修改：使用viewModel.roundDuration
      counter = 0;
    });
    
    // 🎯 如果是第一个round，初始化tmpResult
    if (currentRound == 1) {
      viewModel.clearTmpResult(); // 🎯 修改：使用viewModel.clearTmpResult
    }
    
    // 🎯 Apple-level Audio Detection Integration
    // 直接启动音频检测，内部已有状态检查
    print('🎯 Starting round $currentRound');
    _permissionManager?.startAudioDetectionForRound();
    
    // 🎯 新增：打印音频检测状态
    _permissionManager?.printAudioDetectionStatus();
    
    _tick();
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
      
      // 🎤 Stop voice detection when round ends (simplified - no need to check isAudioDetectionRunning)
      await _permissionManager?.stopAudioDetectionForRound();
      
      // 当前round结束，记录结果到tmpResult
      _addRoundToTmpResult(counter);
      
      final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
      if (currentRound < viewModel.totalRounds) { // 🎯 修改：使用viewModel.totalRounds
        setState(() {
          currentRound++;
        });
        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        Future.delayed(Duration(milliseconds: 600), _startPreCountdown);
      } else {
        // 所有round结束，立即显示结果，然后异步提交
        await _showImmediateResult();
        _submitFinalResult();
      }
    }
  }

  // 立即显示挑战游戏结果（排名为null，等待API返回）
  Future<void> _showImmediateResult() async {
    final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
    
    // 🎯 使用ViewModel中的方法获取最大counts
    final maxCounts = viewModel.getMaxCountsFromTmpResult(); // 🎯 修改：使用viewModel.getMaxCountsFromTmpResult
    
    // 🎯 关键修改：不提交到后端，而是创建临时记录插入到历史数据的第一位
    viewModel.createTemporaryCurrentChallengeGameRecord(
      challengeId: widget.challengeId, // 🎯 修改：使用challengeId
      maxCounts: maxCounts,
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

  // 添加round结果到临时结果列表
  void _addRoundToTmpResult(int counts) {
    final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
    
    // 🎯 使用ViewModel中的方法添加round结果
    viewModel.addRoundToTmpResult(currentRound, counts); // 🎯 修改：使用viewModel.addRoundToTmpResult
  }

  // 清理临时结果数据
  void _clearTmpResult() {
    final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
    
    // 🎯 使用ViewModel中的方法清理临时结果
    viewModel.clearTmpResult(); // 🎯 修改：使用viewModel.clearTmpResult
  }

  // 🎯 苹果级优化：智能刷新历史数据
  Future<void> _refreshHistory() async {
    final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
    
    // 🎯 使用智能加载策略，避免不必要的重复请求
    await viewModel.smartLoadChallengeGameData(
      widget.challengeId, // 🎯 修改：使用challengeId
      limit: 20,
      forceReload: true, // 🎯 强制刷新时使用完整加载
    );
  }

  // 根据屏幕方向初始化视频
  Future<void> _initializeVideoBasedOnOrientation() async {
    try {
      final orientation = MediaQuery.of(context).orientation;
      final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
      String? videoUrl;
      
      if (orientation == Orientation.portrait) {
        videoUrl = viewModel.portraitVideoUrl; // 🎯 修改：使用viewModel.portraitVideoUrl
        print('📱 Using portrait video URL: $videoUrl');
      } else {
        videoUrl = viewModel.landscapeVideoUrl; // 🎯 修改：使用viewModel.landscapeVideoUrl
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

  // 🎯 异步初始化远程视频 - 不阻塞默认视频播放
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

  // 🎯 屏幕方向改变时重新初始化视频
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

  // 提交最终结果到后端
  Future<void> _submitFinalResult() async {
    if (_isSubmittingResult) return; // 防止重复提交
    
    setState(() {
      _isSubmittingResult = true;
    });

    try {
      final viewModel = context.read<ChallengeGameViewModel>(); // 🎯 修改：使用ChallengeGameViewModel
      
      // 🎯 使用ViewModel中的方法获取最大counts
      final maxCounts = viewModel.getMaxCountsFromTmpResult(); // 🎯 修改：使用viewModel.getMaxCountsFromTmpResult
      
      // 创建挑战游戏结果实体
      final challengeGameResult = ChallengeGameResult.create( // 🎯 修改：使用ChallengeGameResult.create
        challengeId: widget.challengeId, // 🎯 修改：使用challengeId
        maxCounts: maxCounts,
      );
      
      print('Submitting challenge game result: $challengeGameResult');
      
      // 🎯 关键修改：使用返回的提交结果，而不是重新请求历史数据
      final response = await viewModel.submitChallengeGameResult(challengeGameResult); // 🎯 修改：使用viewModel.submitChallengeGameResult
      
      if (mounted && response != null) {
        // ✅ 提交成功，数据已经在ViewModel中更新，无需重新请求
        print('✅ Challenge game result submitted successfully with rank: ${response.rank}');
        
        // 清理临时结果数据
        _clearTmpResult();
        
        // 🎯 不再需要调用refreshHistory，因为数据已经在ViewModel中更新
        // await viewModel.refreshHistory(widget.challengeId);
      }
    } catch (e) {
      print('Error submitting result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit result: $e')),
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

  void _onStartPressed() {
    final viewModel = context.read<ChallengeGameViewModel>();
    
    // 🎯 检查剩余挑战次数
    if (viewModel.allowedTimes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No attempts left! Check results in Profile > Challenges.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    _startPreCountdown();
  }

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
    final viewModel = context.watch<ChallengeGameViewModel>();

    // 🎯 优先检查加载状态和错误状态，避免不必要的资源创建
    if (viewModel.isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Warming up your challenge game… One more breath.'),
                ],
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
                    color: Colors.white,
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
            // 错误显示组件
            Center(
              child: ElegantErrorDisplay(
                error: viewModel.error ?? 'An unknown error occurred',
                onRetry: () {
                  viewModel.clearError();
                  _refreshHistory();
                },
              ),
            ),
            // 返回按钮
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
                    color: Colors.white,
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

    // 🎯 只有在没有错误和加载状态时才创建主内容
    final double diameter = MediaQuery.of(context).size.width * 3 / 4;
    final orientation = MediaQuery.of(context).orientation;
    final bool isPortrait = orientation == Orientation.portrait;
    final DraggableScrollableController controller =
        isPortrait ? _portraitController! : _landscapeController!;

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
        ? ChallengePortraitLayout(
            totalRounds: viewModel.totalRounds,
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
            isSubmittingResult: viewModel.isSubmitting,
            allowedTimes: viewModel.allowedTimes, // 🎯 新增：传递剩余尝试次数
          )
        : ChallengeLandscapeLayout(
            totalRounds: viewModel.totalRounds,
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
            isSubmittingResult: viewModel.isSubmitting,
            allowedTimes: viewModel.allowedTimes, // 🎯 新增：传递剩余尝试次数
          );

    return Scaffold(
      body: mainContent,
    );
  }

  /// 将领域实体转换为布局组件期望的Map格式
  List<Map<String, dynamic>> _convertHistoryToMapList(List<ChallengeGameHistoryItem> history) {
    return history.map((item) => {
      'rank': item.rank,
      'date': item.displayDate,
      'counts': item.counts,
      'note': item.note ?? '',
      'additionalData': item,
    }).toList();
  }

  Widget _buildHistoryRanking(ScrollController scrollController) {
    final viewModel = context.read<ChallengeGameViewModel>();
    
    // 将领域实体转换为挑战游戏专用组件的数据格式
    final rankingItems = viewModel.history.map((e) => ChallengeHistoryRankingItem(
      rank: e.rank,
      date: e.displayDate,
      counts: e.counts,
      note: e.note ?? "",
      name: e.name, // 添加名字字段
      additionalData: e.toMap(), // 转换为Map格式
    )).toList();

    return ChallengeHistoryRankingWidget(
      history: rankingItems,
      scrollController: scrollController,
      config: const ChallengeHistoryRankingConfig(
        title: 'CHALLENGE RANKINGS',
        currentItemColor: Colors.redAccent,
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
