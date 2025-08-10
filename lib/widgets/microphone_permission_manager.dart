import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../knock_voice/stream_audio_detector.dart';
import 'dart:async';

/// 麦克风权限管理Widget
/// 负责处理麦克风权限请求、状态监听、音频检测初始化等
class MicrophonePermissionManager {
  // 权限状态
  bool _cameraPermissionGranted = false;
  bool _isInitializingCamera = false;
  
  // 音频检测相关
  StreamAudioDetector? _audioDetector;
  bool _audioDetectionEnabled = true;
  bool _isInitializingAudioDetection = false;
  bool _isAudioDetectionActive = false;
  
  // 权限监听相关
  Timer? _permissionCheckTimer;

  // 回调函数
  VoidCallback? onPermissionGranted;
  VoidCallback? onPermissionDenied;
  VoidCallback? onAudioDetectionReady;
  Function(String)? onError;
  VoidCallback? onStrikeDetected; // 新增：音频检测到打击时的回调

  /// 获取音频检测状态摘要
  Map<String, dynamic> get audioDetectionStatus {
    return {
      'enabled': _audioDetectionEnabled,
      'active': _isAudioDetectionActive,
      'detectorAvailable': _audioDetector != null,
      'isListening': _audioDetector?.isListening ?? false,
    };
  }

  /// 🍎 Apple-level Direct Microphone Permission Request
  Future<bool> requestMicrophonePermissionDirectly() async {
    try {
      // 1. 检查当前权限状态
      PermissionStatus status = await Permission.microphone.status;
      print('🎯 Current microphone permission status: $status');
      
      if (status.isGranted) {
        // 2. 权限已授予，直接初始化音频检测
        print('✅ Microphone permission already granted');
        await _initializeAudioDetection();
        onPermissionGranted?.call();
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        // 3. 权限被永久拒绝
        print('❌ Microphone permission permanently denied');
        onPermissionDenied?.call();
        return false;
      }
      
      // 4. 权限未授予，直接请求权限（会显示系统弹窗）
      print('🎯 Requesting microphone permission...');
      status = await Permission.microphone.request();
      print('🎯 Permission request result: $status');
      
      // 5. 等待用户响应系统权限弹窗
      await Future.delayed(Duration(milliseconds: 1000));
      
      // 6. 再次检查权限状态
      status = await Permission.microphone.status;
      print('🎯 Final permission status after user response: $status');
      
      if (status.isGranted) {
        // 7. 权限授予成功，初始化音频检测
        print('✅ Microphone permission granted');
        await _initializeAudioDetection();
        onPermissionGranted?.call();
        return true;
      } else if (status.isDenied || status.isPermanentlyDenied) {
        // 8. 用户拒绝了权限
        print('❌ User denied microphone permission');
        onPermissionDenied?.call();
        return false;
      } else {
        // 9. 其他状态，可能是用户还没有响应
        print('⚠️ Permission status unclear, user may still be deciding');
        return false;
      }
      
    } catch (e) {
      print('❌ Error requesting microphone permission: $e');
      onError?.call('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// 🍎 Apple-level Direct Settings Dialog
  void showMicrophonePermissionRequiredDialog(BuildContext context) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.mic_off, color: Colors.orange, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Training Requires Microphone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
                'Voice detection requires microphone access. Please enable it in Settings to continue training.',
                style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Audio processed locally only',
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
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
                Navigator.of(context).pop(); // 返回上一页
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AppSettings.openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.blue.withOpacity(0.3),
              ),
              child: Text(
                'Open Settings',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 20),
        ),
      ),
    );
  }

  /// 🎯 Apple-level Stream Audio Detection Initialization
  Future<void> _initializeAudioDetection() async {
    try {
      _isInitializingAudioDetection = true;

      // 1. 创建流音频检测器实例（如果还没有创建）
      _audioDetector ??= StreamAudioDetector();

      // 2. 设置检测回调
      _audioDetector!.onStrikeDetected = () {
        print('🎯 Real strike detected! Triggering count...');
        onStrikeDetected?.call(); // 通知主页面
      };

      // 3. 设置错误回调
      _audioDetector!.onError = (error) {
        print('Stream audio detection error: $error');
        onError?.call('Audio detection error: $error');
      };

      // 4. 设置状态回调
      _audioDetector!.onStatusUpdate = (status) {
        print('Stream audio detection status: $status');
      };

      // 5. 初始化流音频检测器
      final initSuccess = await _audioDetector!.initialize();
      if (!initSuccess) {
        print('⚠️ Stream audio detector initialization failed, but continuing...');
      }

      _audioDetectionEnabled = true;
      _isInitializingAudioDetection = false;
      _isAudioDetectionActive = false;



      print('🎯 Stream audio detection initialization completed');
      onAudioDetectionReady?.call();
      
    } catch (e) {
      print('❌ Error during stream audio detection initialization: $e');
      _isInitializingAudioDetection = false;
      _audioDetectionEnabled = true;
      _isAudioDetectionActive = false;
      onError?.call('Audio detection initialization error: $e');
      rethrow;
    }
  }

  /// 🎯 增强的权限状态监听
  void startEnhancedPermissionListener() {
    // 防止重复启动监听器
    if (_permissionCheckTimer != null) {
      print('⚠️ Permission listener already active, skipping start');
      return;
    }
    
    // 每3秒检查一次权限状态
    _permissionCheckTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        final micStatus = await Permission.microphone.status;
        print('🎯 Enhanced permission listener check: $micStatus');
        

        
        if (micStatus.isGranted && _audioDetector == null) {
          // 麦克风权限授予，初始化音频检测
          print('✅ Microphone permission granted via listener, initializing audio detection');
          await _initializeAudioDetection();
          onPermissionGranted?.call();
          // 停止监听
          timer.cancel();
          _permissionCheckTimer = null;
        } else if (micStatus.isPermanentlyDenied || micStatus.isDenied) {
          // 权限被拒绝
          print('❌ Microphone permission denied via listener');
          onPermissionDenied?.call();
          // 停止监听
          timer.cancel();
          _permissionCheckTimer = null;
        }
      } catch (e) {
        print('❌ Error in enhanced permission listener: $e');
        timer.cancel();
        _permissionCheckTimer = null;
      }
    });
  }

  /// 🎯 为当前round启动声音检测
  Future<void> startAudioDetectionForRound() async {
    try {
      // 防止重复启动
      if (_isAudioDetectionActive) {
        print('⚠️ Audio detection already active, skipping start');
        return;
      }

      if (_audioDetector == null) {
        print('⚠️ Audio detector not available, skipping audio detection');
        return;
      }
      
      // 检查麦克风权限
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        print('❌ Microphone permission not granted, cannot start audio detection');
        return;
      }
      
      final success = await _audioDetector!.startListening();
      if (success) {
        print('🎯 Stream audio detection started');
        _isAudioDetectionActive = true;
      } else {
        print('⚠️ Failed to start stream audio detection, but continuing...');
      }
    } catch (e) {
      print('⚠️ Error starting stream audio detection: $e, but continuing...');
    }
  }

  /// 🎯 停止当前round的声音检测
  Future<void> stopAudioDetectionForRound() async {
    try {
      // 防止重复停止
      if (!_isAudioDetectionActive) {
        print('🎯 Audio detection already stopped');
        return;
      }
      
      // 添加状态检查，避免重复停止
      if (_audioDetector != null && _audioDetector!.isListening) {
        await _audioDetector!.stopListening();
        print('🎯 Stream audio detection stopped');
      } else {
        print('🎯 Stream audio detection already stopped');
      }
      
      _isAudioDetectionActive = false;
      print('🎯 Audio detection state: inactive');
      
    } catch (e) {
      print('❌ Error stopping stream audio detection: $e');
      // 即使出错也要重置状态
      _isAudioDetectionActive = false;
    }
  }

  /// 🎯 应用生命周期状态变化处理（简化版 - 仅记录状态，不自动恢复）
  void handleAppLifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('🎯 App resumed - audio detection state: $_isAudioDetectionActive');
        break;
      case AppLifecycleState.paused:
        print('🎯 App paused - audio detection may be affected');
        break;
      case AppLifecycleState.inactive:
        print('🎯 App inactive - audio detection may be interrupted');
        break;
      case AppLifecycleState.detached:
        print('🎯 App detached - cleaning up audio detection');
        break;
      default:
        break;
    }
  }

  /// 🎯 打印音频检测状态（用于调试）
  void printAudioDetectionStatus() {
    final status = audioDetectionStatus;
    print('🎯 Audio Detection Status:');
    print('  - Enabled: ${status['enabled']}');
    print('  - Active: ${status['active']}');
    print('  - Detector Available: ${status['detectorAvailable']}');
    print('  - Is Listening: ${status['isListening']}');
  }

  /// 清理资源
  void dispose() {
    // 停止权限监听定时器
    _permissionCheckTimer?.cancel();
    _permissionCheckTimer = null;
    
    // 停止音频检测
    if (_isAudioDetectionActive && _audioDetector != null) {
      _audioDetector!.stopListening().catchError((e) {
        print('🎯 Audio detection stop error during disposal: $e');
      });
      _isAudioDetectionActive = false;
    }
    
    // 释放音频检测器
    _audioDetector?.dispose();
    _audioDetector = null;
    
    print('🎯 MicrophonePermissionManager disposed successfully');
  }
} 