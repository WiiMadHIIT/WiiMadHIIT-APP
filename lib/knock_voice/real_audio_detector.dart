import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

/// Real Audio Detector for Voice Strike Detection
/// Uses flutter_sound onProgress for real-time amplitude detection
/// Enhanced with stream processing for better accuracy
/// 
/// Note: This class assumes microphone permission is already granted by the calling page.
/// Permission management is handled by the UI layer (e.g., checkin_training_page.dart).
/// This class focuses purely on audio processing and strike detection.
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
  StreamSubscription? _recordingDataSubscription;
  double _currentDb = 0.0; // 当前分贝值
  
  // Enhanced strike detection parameters
  static const double _dbThreshold = 45.0; // 降低分贝阈值，适应iOS环境
  static const int _minStrikeInterval = 150; // 最小击打间隔（毫秒）
  static const int _maxStrikeInterval = 2000; // 最大击打间隔（毫秒）
  DateTime? _lastStrikeTime;
  
  // Advanced detection parameters
  final List<double> _dbHistory = []; // 分贝值历史记录
  final int _historySize = 10; // 历史记录大小
  double _ambientNoiseLevel = 0.0; // 环境噪声水平
  bool _isCalibrated = false; // 是否已校准
  
  // Hit counter
  int _hitCount = 0;
  
  // Audio processing parameters
  static const int _sampleRate = 22050;
  static const int _numChannels = 1;
  static const int _bufferSize = 1024;
  
  // Stream processing
  StreamController<Uint8List>? _recordingDataController;
  IOSink? _fileSink;
  
  /// Initialize detector (assumes permission is already granted by the calling page)
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
      
      // Set up amplitude subscription with proper duration
      _amplitudeSubscription = _recorder.onProgress!.listen((e) {
        _processAmplitudeData(e);
      });
      
      // Set subscription duration for real-time updates
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));
      
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
      
      // Get temporary directory for recording file
      final tempDir = await getTemporaryDirectory();
      final recordingPath = '${tempDir.path}/audio_detection_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      print('🎯 Recording to file: $recordingPath');
      
      // Create file sink for recording
      final outputFile = File(recordingPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
      _fileSink = outputFile.openWrite();
      
      // Create stream controller for recording data
      _recordingDataController = StreamController<Uint8List>();
      _recordingDataSubscription = _recordingDataController!.stream.listen((buffer) {
        _fileSink?.add(buffer);
      });
      
      // Start recording with optimized settings
      try {
        await _recorder.startRecorder(
          toStream: _recordingDataController!.sink,
          toFile: recordingPath,
          codec: Codec.pcm16, // Use PCM16 for better compatibility
          sampleRate: _sampleRate,
          numChannels: _numChannels,
          bufferSize: _bufferSize,
          audioSource: AudioSource.defaultSource,
        );
        print('🎯 Recording started successfully with PCM16 codec');
      } catch (e) {
        print('❌ Failed to start recording with PCM16: $e');
        try {
          // Fallback to AAC codec
          await _recorder.startRecorder(
            toFile: recordingPath,
            codec: Codec.aacADTS,
            sampleRate: _sampleRate,
            numChannels: _numChannels,
            bufferSize: _bufferSize,
          );
          print('🎯 Recording started with AAC codec fallback');
        } catch (e2) {
          print('❌ Failed to start recording with fallback: $e2');
          rethrow;
        }
      }
      
      _isListening = true;
      _updateStatus('Started listening to microphone');
      
      // Start calibration
      _startCalibration();
      
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
      // Cancel subscriptions
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      
      await _recordingDataSubscription?.cancel();
      _recordingDataSubscription = null;
      
      // Close stream controller
      await _recordingDataController?.close();
      _recordingDataController = null;
      
      // Close file sink
      await _fileSink?.flush();
      await _fileSink?.close();
      _fileSink = null;
      
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
      
      // 更新分贝值历史
      _updateDbHistory(_currentDb);
      
      // 检测击打声音（高振幅脉冲）
      _checkStrikeFromAmplitude(_currentDb);
      
      // 调试：更频繁地记录分贝值，帮助调试
      if (_hitCount % 3 == 0 || _currentDb > _dbThreshold * 0.8) {
        print('🎤 Current dB: ${_currentDb.toStringAsFixed(1)} dB (threshold: ${_getAdaptiveThreshold().toStringAsFixed(1)})');
      }
      
    } catch (e) {
      print('⚠️ Amplitude processing error: $e');
    }
  }
  
  /// 更新分贝值历史记录
  void _updateDbHistory(double db) {
    _dbHistory.add(db);
    if (_dbHistory.length > _historySize) {
      _dbHistory.removeAt(0);
    }
  }
  
  /// 开始校准环境噪声水平
  void _startCalibration() {
    _isCalibrated = false;
    _ambientNoiseLevel = 0.0;
    _dbHistory.clear();
    
    // 3秒后完成校准
    Timer(const Duration(seconds: 3), () {
      if (_dbHistory.isNotEmpty) {
        _ambientNoiseLevel = _dbHistory.reduce((a, b) => a + b) / _dbHistory.length;
        _isCalibrated = true;
        print('🎯 Calibration completed. Ambient noise level: ${_ambientNoiseLevel.toStringAsFixed(1)} dB');
      }
    });
  }
  
  /// 获取自适应阈值
  double _getAdaptiveThreshold() {
    if (!_isCalibrated) {
      return _dbThreshold;
    }
    
    // 基于环境噪声水平调整阈值
    final adaptiveThreshold = _ambientNoiseLevel + 15.0; // 环境噪声 + 15dB
    return max(adaptiveThreshold, _dbThreshold);
  }
  
  /// 🎯 基于分贝值检测击打声音（增强版）
  void _checkStrikeFromAmplitude(double db) {
    final now = DateTime.now();
    final threshold = _getAdaptiveThreshold();
    
    // 检查分贝值是否超过阈值
    if (db > threshold) {
      // 检查时间间隔
      if (_lastStrikeTime == null || 
          now.difference(_lastStrikeTime!).inMilliseconds > _minStrikeInterval) {
        
        // 额外的验证：检查是否是真正的击打声音
        if (_isValidStrikeSound(db)) {
          _lastStrikeTime = now;
          _hitCount++;
          
          print('🎯 STRIKE DETECTED! dB: ${db.toStringAsFixed(1)} (threshold: ${threshold.toStringAsFixed(1)}), Count: $_hitCount');
          
          // 触发击打检测回调
          onStrikeDetected?.call();
        } else {
          print('⚠️ Invalid strike sound detected: dB ${db.toStringAsFixed(1)} (filtered out)');
        }
      } else {
        // 记录被忽略的检测（时间间隔太短）
        final timeSinceLast = now.difference(_lastStrikeTime!).inMilliseconds;
        print('⚠️ Strike ignored (too soon): dB ${db.toStringAsFixed(1)}, Time since last: ${timeSinceLast}ms (min: $_minStrikeInterval)');
      }
    }
  }
  
  /// 验证是否为有效的击打声音
  bool _isValidStrikeSound(double db) {
    if (!_isCalibrated || _dbHistory.length < 3) {
      return true; // 未校准时接受所有超过阈值的声音
    }
    
    // 检查分贝值突增
    final recentAvg = _dbHistory.take(_dbHistory.length - 1).reduce((a, b) => a + b) / (_dbHistory.length - 1);
    final dbIncrease = db - recentAvg;
    
    // 分贝值突增必须超过8dB
    if (dbIncrease < 8.0) {
      return false;
    }
    
    // 检查分贝值变化趋势
    if (_dbHistory.length >= 5) {
      final recentValues = _dbHistory.skip(_dbHistory.length - 5).toList();
      final isRising = recentValues[recentValues.length - 1] > recentValues[0];
      
      if (!isRising) {
        return false; // 分贝值没有上升趋势
      }
    }
    
    return true;
  }
  
  /// Get listening status
  bool get isListening => _isListening;
  
  /// Get initialization status
  bool get isInitialized => _isInitialized;
  
  /// Get current decibel level
  double get currentDb => _currentDb;
  
  /// Get hit count
  int get hitCount => _hitCount;
  
  /// Get ambient noise level
  double get ambientNoiseLevel => _ambientNoiseLevel;
  
  /// Get calibration status
  bool get isCalibrated => _isCalibrated;
  
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
      _recordingDataSubscription?.cancel();
      _recordingDataController?.close();
      _fileSink?.close();
      _recorder.closeRecorder();
      print('🎯 Real audio detector disposed');
    } catch (e) {
      _handleError('Error disposing real audio detector: $e');
    }
  }
}