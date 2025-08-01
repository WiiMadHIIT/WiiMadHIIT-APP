import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

/// Real Audio Detector for Voice Strike Detection
/// Uses flutter_sound with stream processing for real-time amplitude detection
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
  StreamSubscription? _audioDataSubscription;
  double _currentDb = 0.0; // 当前分贝值
  
  // Strike detection parameters
  static const double _dbThreshold = 50.0; // 降低分贝阈值，适应iOS环境
  static const int _minStrikeInterval = 200; // 最小击打间隔（毫秒）
  DateTime? _lastStrikeTime;
  
  // Hit counter
  int _hitCount = 0;
  
  // Audio processing configuration
  static const int _sampleRate = 48000; // 采样率
  static const int _numChannels = 1; // 单声道
  static const int _bufferSize = 1024; // 缓冲区大小
  static const Duration _subscriptionDuration = Duration(milliseconds: 100); // 订阅间隔
  
  // Audio data buffers for processing
  List<Float32List> _audioBuffer = [];
  final List<double> _amplitudeHistory = [];
  static const int _historySize = 10; // 历史数据大小
  
  // Stream controllers for audio data
  StreamController<List<Float32List>>? _audioDataController;
  StreamController<double>? _amplitudeController;
  
  /// Initialize detector with microphone permission
  Future<bool> initialize() async {
    try {
      // Check if already initialized
      if (_isInitialized) {
        _updateStatus('Real audio detector already initialized');
        print('🎯 Real audio detector already initialized');
        return true;
      }
      
      // Initialize flutter_sound recorder
      print('🎯 Opening flutter_sound recorder...');
      await _recorder.openRecorder();
      print('🎯 Flutter_sound recorder opened successfully');
      
      // Set subscription duration for real-time processing
      await _recorder.setSubscriptionDuration(_subscriptionDuration);
      print('🎯 Subscription duration set to ${_subscriptionDuration.inMilliseconds}ms');
      
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
      // Check if recorder is already recording
      if (_recorder.isRecording) {
        print('🎯 Recorder already recording, stopping first');
        await _recorder.stopRecorder();
      }
      
      // Clear previous data
      _audioBuffer.clear();
      _amplitudeHistory.clear();
      _hitCount = 0;
      _lastStrikeTime = null;
      
      // Get temporary directory for recording file
      final tempDir = await getTemporaryDirectory();
      final recordingPath = '${tempDir.path}/audio_detection_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      print('🎯 Recording to file: $recordingPath');
      
      // Create stream controllers for audio data processing
      _audioDataController = StreamController<List<Float32List>>();
      _amplitudeController = StreamController<double>();
      
      // Start recording with flutter_sound using stream processing
      try {
        // Use PCM Float32 for better audio processing
        await _recorder.startRecorder(
          toFile: recordingPath,
          codec: Codec.pcmFloat32, // 使用 Float32 格式获得更好的精度
          sampleRate: _sampleRate,
          numChannels: _numChannels,
          audioSource: AudioSource.defaultSource,
          toStreamFloat32: _audioDataController!.sink, // 直接处理音频数据流
          bufferSize: _bufferSize,
        );
        print('🎯 Recording started successfully with PCM Float32 stream');
      } catch (e) {
        print('❌ Failed to start recording with PCM Float32: $e');
        try {
          // Fallback to AAC with amplitude monitoring
          await _recorder.startRecorder(
            toFile: recordingPath,
            codec: Codec.aacADTS,
            sampleRate: 22050,
            numChannels: _numChannels,
            bufferSize: _bufferSize,
          );
          print('🎯 Recording started with AAC fallback');
        } catch (e2) {
          print('❌ Failed to start recording with fallback: $e2');
          rethrow;
        }
      }
      
      _isListening = true;
      _updateStatus('Started listening to microphone');
      
      // 🎯 订阅实时振幅数据
      _amplitudeSubscription = _recorder.onProgress!.listen((e) {
        _processAmplitudeData(e);
      });
      
      // 🎯 订阅音频数据流（如果使用 PCM Float32）
      if (_audioDataController != null) {
        _audioDataSubscription = _audioDataController!.stream.listen((audioData) {
          _processAudioData(audioData);
        });
      }
      
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
      // 取消所有订阅
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      
      await _audioDataSubscription?.cancel();
      _audioDataSubscription = null;
      
      // 关闭流控制器
      await _audioDataController?.close();
      _audioDataController = null;
      
      await _amplitudeController?.close();
      _amplitudeController = null;
      
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
      
      // 添加到历史记录
      _amplitudeHistory.add(_currentDb);
      if (_amplitudeHistory.length > _historySize) {
        _amplitudeHistory.removeAt(0);
      }
      
      // 检测击打声音（高振幅脉冲）
      _checkStrikeFromAmplitude(_currentDb);
      
      // 调试：更频繁地记录分贝值，帮助调试
      if (_hitCount % 3 == 0 || _currentDb > _dbThreshold * 0.8) {
        print('🎤 Current dB: ${_currentDb.toStringAsFixed(1)} dB (threshold: $_dbThreshold)');
      }
      
    } catch (e) {
      print('⚠️ Amplitude processing error: $e');
    }
  }
  
  /// 🎯 处理音频数据流（PCM Float32）
  void _processAudioData(List<Float32List> audioData) {
    try {
      // 计算音频数据的RMS能量
      double rmsEnergy = _calculateRMSEnergy(audioData);
      
      // 转换为分贝值
      double dbFromAudio = _rmsToDecibels(rmsEnergy);
      
      // 使用音频数据计算的分贝值作为补充检测
      if (dbFromAudio > _dbThreshold * 1.2) { // 稍微提高阈值避免误检
        print('🎵 Audio data detected high energy: ${dbFromAudio.toStringAsFixed(1)} dB');
        _checkStrikeFromAudioData(dbFromAudio);
      }
      
    } catch (e) {
      print('⚠️ Audio data processing error: $e');
    }
  }
  
  /// 🎯 计算RMS能量
  double _calculateRMSEnergy(List<Float32List> audioData) {
    if (audioData.isEmpty) return 0.0;
    
    double sum = 0.0;
    int count = 0;
    
    for (var channel in audioData) {
      for (var sample in channel) {
        sum += sample * sample;
        count++;
      }
    }
    
    if (count == 0) return 0.0;
    return sqrt(sum / count);
  }
  
  /// 🎯 将RMS能量转换为分贝值
  double _rmsToDecibels(double rms) {
    if (rms <= 0.0) return -60.0; // 最小分贝值
    return 20.0 * log(rms) / ln10;
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
  
  /// 🎯 基于音频数据检测击打声音
  void _checkStrikeFromAudioData(double db) {
    final now = DateTime.now();
    
    // 使用更严格的阈值和时间间隔
    if (db > _dbThreshold * 1.2) {
      if (_lastStrikeTime == null || 
          now.difference(_lastStrikeTime!).inMilliseconds > _minStrikeInterval * 1.5) {
        
        _lastStrikeTime = now;
        _hitCount++;
        
        print('🎵 AUDIO STRIKE DETECTED! dB: ${db.toStringAsFixed(1)}, Count: $_hitCount');
        
        // 触发击打检测回调
        onStrikeDetected?.call();
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
  
  /// Get amplitude history
  List<double> get amplitudeHistory => List.from(_amplitudeHistory);
  
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
      _audioDataSubscription?.cancel();
      _audioDataController?.close();
      _amplitudeController?.close();
      _recorder.closeRecorder();
      print('🎯 Real audio detector disposed');
    } catch (e) {
      _handleError('Error disposing real audio detector: $e');
    }
  }
}