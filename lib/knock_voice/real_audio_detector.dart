import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_session_config.dart';

/// Real Audio Detector for Voice Strike Detection
/// Uses flutter_sound onProgress for real-time amplitude detection
class RealAudioDetector {
  // State management
  bool _isInitialized = false;
  bool _isListening = false;
  
  // Audio recording
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  
  // Callbacks
  VoidCallback? onStrikeDetected;
  Function(String)? onError;
  Function(String)? onStatusUpdate;
  
  // Real-time amplitude detection
  StreamSubscription? _amplitudeSubscription;
  double _currentDb = 0.0; // 当前分贝值
  
  // Strike detection parameters
  static const double _dbThreshold = 30.0; // 降低分贝阈值，适应iOS环境
  static const int _minStrikeInterval = 200; // 最小击打间隔（毫秒）
  DateTime? _lastStrikeTime;
  
  // Hit counter
  int _hitCount = 0;
  
  /// Initialize detector with microphone permission
  Future<bool> initialize() async {
    try {
      // Check if already initialized
      if (_isInitialized) {
        _updateStatus('Real audio detector already initialized');
        print('🎯 Real audio detector already initialized');
        return true;
      }
      
      // iOS 音频会话配置
      if (Platform.isIOS) {
        print('🎯 iOS: 配置音频会话...');
        final sessionConfigured = await AudioSessionConfig.configureAudioSession();
        if (!sessionConfigured) {
          print('⚠️ iOS: 音频会话配置失败，但继续尝试初始化');
        }
      }
      
      // Initialize flutter_sound recorder
      print('🎯 Opening flutter_sound recorder...');
      await _recorder.openRecorder();
      print('🎯 Flutter_sound recorder opened successfully');
      
      _isInitialized = true;
      _updateStatus('Real audio detector initialized');
      print('🎯 Real audio detector initialized successfully');
      return true;
    } catch (e) {
      print('❌ Failed to initialize real audio detector: $e');
      _handleError('Failed to initialize real audio detector: $e');
      return false;
    }
  }
  
  /// Start listening to microphone input with real-time amplitude detection
  Future<bool> startListening() async {
    if (!_isInitialized) {
      _handleError('Real audio detector not initialized');
      return false;
    }
    
    if (_isListening) {
      print('🎯 Audio detection already listening');
      return true;
    }
    
    try {
      // iOS 重新激活音频会话
      if (Platform.isIOS) {
        print('🎯 iOS: 重新激活音频会话...');
        await AudioSessionConfig.reactivate();
      }
      
      // Check if recorder is already recording
      if (_recorder.isRecording) {
        print('🎯 Recorder already recording, stopping first');
        await _recorder.stopRecorder();
      }
      
      // Get temporary directory for recording file
      final tempDir = await getTemporaryDirectory();
      final recordingPath = '${tempDir.path}/audio_detection_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      print('🎯 Recording to file: $recordingPath');
      
      // iOS 优化的编解码器降级策略
      bool recordingStarted = false;
      
      // 尝试多种编解码器，按优先级排序
      final codecOptions = [
        {'codec': Codec.pcm16WAV, 'name': 'PCM16 WAV'},
        {'codec': Codec.pcm16, 'name': 'PCM16'},
        {'codec': Codec.aacADTS, 'name': 'AAC ADTS'},
        {'codec': Codec.aacMP4, 'name': 'AAC MP4'},
        {'codec': Codec.opusOGG, 'name': 'Opus OGG'},
        {'codec': Codec.opusCAF, 'name': 'Opus CAF'},
        {'codec': Codec.flac, 'name': 'FLAC'},
        {'codec': Codec.opusWebM, 'name': 'Opus WebM'},
        {'codec': Codec.vorbisOGG, 'name': 'Vorbis OGG'},
      ];
      
      for (final option in codecOptions) {
        try {
          print('🎯 Trying codec: ${option['name']}');
          
          await _recorder.startRecorder(
            toFile: recordingPath,
            codec: option['codec'] as Codec,
            sampleRate: 22050,    // iOS 兼容的采样率
            numChannels: 1,       // 单声道，减少处理负担
            bitRate: 128000,      // 适中的比特率
            bufferSize: 512,      // 较小的缓冲区，降低延迟
          );
          
          print('✅ Recording started successfully with ${option['name']} codec');
          recordingStarted = true;
          break;
          
        } catch (e) {
          print('❌ Failed with ${option['name']}: $e');
          // 继续尝试下一个编解码器
          continue;
        }
      }
      
      // 如果所有编解码器都失败，使用默认设置
      if (!recordingStarted) {
        print('⚠️ All codecs failed, trying default settings');
        try {
          await _recorder.startRecorder(
            toFile: recordingPath,
          );
          print('✅ Recording started with default settings');
          recordingStarted = true;
        } catch (e) {
          print('❌ Failed to start recording with default settings: $e');
          throw Exception('All recording methods failed: $e');
        }
      }
      
      _isListening = true;
      _updateStatus('Started listening to microphone');
      
      // 🎯 订阅实时振幅数据
      _amplitudeSubscription = _recorder.onProgress!.listen((e) {
        _processAmplitudeData(e);
      });
      
      print('🎯 Real-time amplitude detection started successfully');
      return true;
    } catch (e) {
      print('❌ Failed to start recording: $e');
      _handleError('Failed to start real audio detection: $e');
      return false;
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      // 取消振幅订阅
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      
      // Only stop if actually recording
      if (_recorder.isRecording) {
        final recordingPath = await _recorder.stopRecorder();
        print('🎯 Recording stopped, file: $recordingPath');
        
        // Clean up the temporary file
        if (recordingPath != null) {
          try {
            final file = File(recordingPath);
            if (await file.exists()) {
              await file.delete();
              print('🎯 Temporary recording file cleaned up');
            }
          } catch (e) {
            print('⚠️ Failed to clean up recording file: $e');
          }
        }
      }
      
      _isListening = false;
      _updateStatus('Stopped listening to microphone');
      
      print('🎯 Real-time amplitude detection stopped');
    } catch (e) {
      _handleError('Failed to stop real audio detection: $e');
    }
  }
  
  /// 🎯 处理实时振幅数据
  void _processAmplitudeData(RecordingDisposition e) {
    try {
      // 获取当前分贝值
      _currentDb = e.decibels ?? 0.0;
      
      // 检测击打声音（高振幅脉冲）
      _checkStrikeFromAmplitude(_currentDb);
      
      // 调试：更频繁地记录分贝值，帮助调试
      if (_hitCount % 3 == 0 || _currentDb > _dbThreshold * 0.8 || _currentDb > 10.0) { // 每3次击打、接近阈值或超过10dB时记录
        print('🎤 Current dB: ${_currentDb.toStringAsFixed(1)} dB (threshold: $_dbThreshold)');
      }
      
    } catch (e) {
      print('⚠️ Amplitude processing error: $e');
    }
  }
  
  /// 🎯 基于分贝值检测击打声音
  void _checkStrikeFromAmplitude(double db) {
    final now = DateTime.now();
    
    // 检查分贝值是否超过阈值
    if (db > _dbThreshold) {
      // 检查时间间隔
      if (_lastStrikeTime == null || 
          now.difference(_lastStrikeTime!).inMilliseconds > _minStrikeInterval) {
        
        _lastStrikeTime = now;
        _hitCount++;
        
        print('🎯 STRIKE DETECTED! dB: ${db.toStringAsFixed(1)} (threshold: $_dbThreshold), Count: $_hitCount');
        
        // 触发击打检测回调
        onStrikeDetected?.call();
      } else {
        // 记录被忽略的检测（时间间隔太短）
        final timeSinceLast = now.difference(_lastStrikeTime!).inMilliseconds;
        print('⚠️ Strike ignored (too soon): dB ${db.toStringAsFixed(1)}, Time since last: ${timeSinceLast}ms (min: $_minStrikeInterval)');
      }
    }
  }
  
  /// Get listening status
  bool get isListening => _isListening;
  
  /// Get initialization status
  bool get isInitialized => _isInitialized;
  
  /// Get current decibel level
  double get currentDb => _currentDb;
  
  /// Get hit count
  int get hitCount => _hitCount;
  
  /// Reset hit count
  void resetHitCount() {
    _hitCount = 0;
    _lastStrikeTime = null;
    print('🎯 Hit count reset to 0');
  }
  
  /// Update status
  void _updateStatus(String status) {
    onStatusUpdate?.call(status);
  }
  
  /// Handle errors
  void _handleError(String error) {
    onError?.call(error);
  }
  
  /// Dispose resources
  void dispose() {
    try {
      stopListening();
      _amplitudeSubscription?.cancel();
      _recorder.closeRecorder();
      
      // iOS 停用音频会话
      if (Platform.isIOS) {
        AudioSessionConfig.deactivate();
      }
      
      print('🎯 Real audio detector disposed');
    } catch (e) {
      _handleError('Error disposing real audio detector: $e');
    }
  }
}