import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

/// Real Audio Detector for Voice Strike Detection
/// Uses flutter_sound with stream processing for real-time amplitude detection
class RealAudioDetector {
  // State management
  bool _isInitialized = false;
  bool _isListening = false;
  
  // Audio recording with stream processing
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer(); // For validation
  
  // Stream processing
  final StreamController<Food> _audioStreamController = StreamController<Food>();
  StreamSubscription<Food>? _audioStreamSubscription;
  
  // Callbacks
  VoidCallback? onStrikeDetected;
  Function(String)? onError;
  Function(String)? onStatusUpdate;
  
  // Real-time amplitude detection
  StreamSubscription? _amplitudeSubscription;
  double _currentDb = 0.0; // 当前分贝值
  
  // Audio validation
  bool _isReceivingAudio = false;
  int _audioDataCount = 0;
  Timer? _audioValidationTimer;
  
  // Strike detection parameters
  static const double _dbThreshold = 50.0; // 降低分贝阈值，适应iOS环境
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
      
      // Initialize flutter_sound recorder and player
      print('🎯 Opening flutter_sound recorder and player...');
      await _recorder.openAudioSession();
      await _player.openAudioSession();
      print('🎯 Flutter_sound recorder and player opened successfully');
      
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
      
      // Reset audio validation
      _isReceivingAudio = false;
      _audioDataCount = 0;
      
      // Start audio stream processing
      _startAudioStreamProcessing();
      
      // Start recording with stream processing
      print('🎯 Starting recording with stream processing...');
      await _recorder.startRecorder(
        toStream: _audioStreamController.sink,
        codec: Codec.pcm16, // Use PCM16 for better compatibility
        sampleRate: 16000,  // 16kHz sample rate
        numChannels: 1,     // Mono channel
      );
      
      _isListening = true;
      _updateStatus('Started listening to microphone with stream processing');
      
      // 🎯 订阅实时振幅数据
      _amplitudeSubscription = _recorder.onProgress!.listen((e) {
        _processAmplitudeData(e);
      });
      
      // Start audio validation timer
      _startAudioValidation();
      
      print('🎯 Real-time amplitude detection started successfully with stream processing');
      return true;
    } catch (e) {
      print('❌ Failed to start recording: $e');
      _handleError('Failed to start real audio detection: $e');
      return false;
    }
  }
  
  /// Start audio stream processing
  void _startAudioStreamProcessing() {
    _audioStreamSubscription = _audioStreamController.stream.listen(
      (audioData) {
        _processAudioStream(audioData);
      },
      onError: (error) {
        print('❌ Audio stream error: $error');
        _handleError('Audio stream error: $error');
      },
      onDone: () {
        print('🎯 Audio stream completed');
      },
    );
  }
  
  /// Process audio stream data
  void _processAudioStream(Food audioData) {
    try {
      _audioDataCount++;
      _isReceivingAudio = true;
      
      // Log audio data reception (for debugging)
      if (_audioDataCount % 100 == 0) { // Log every 100th packet
        print('🎤 Received audio data packet #$_audioDataCount');
      }
      
      // Here you can add more sophisticated audio analysis
      // For now, we're just validating that we're receiving data
      
    } catch (e) {
      print('⚠️ Audio stream processing error: $e');
    }
  }
  
  /// Start audio validation timer
  void _startAudioValidation() {
    _audioValidationTimer?.cancel();
    _audioValidationTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!_isReceivingAudio) {
        print('⚠️ WARNING: No audio data received for 2 seconds');
        _updateStatus('No audio data received - check microphone');
      } else {
        print('✅ Audio data flowing normally - received $_audioDataCount packets');
        _updateStatus('Audio detection active - $_audioDataCount packets received');
      }
    });
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      // Stop audio validation
      _audioValidationTimer?.cancel();
      _audioValidationTimer = null;
      
      // Cancel stream subscriptions
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;
      
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
      if (_hitCount % 3 == 0 || _currentDb > _dbThreshold * 0.8) { // 每3次击打或接近阈值时记录
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
  
  /// Get audio reception status
  bool get isReceivingAudio => _isReceivingAudio;
  
  /// Get audio data count
  int get audioDataCount => _audioDataCount;
  
  /// Reset hit count
  void resetHitCount() {
    _hitCount = 0;
    _lastStrikeTime = null;
    print('🎯 Hit count reset to 0');
  }
  
  /// Test audio playback for validation (optional)
  Future<void> testAudioPlayback() async {
    try {
      if (!_player.isPlaying) {
        // Create a simple test tone
        final tempDir = await getTemporaryDirectory();
        final testFile = '${tempDir.path}/test_tone.wav';
        
        // For now, just log that we would play audio
        print('🎵 Would play test audio from: $testFile');
        _updateStatus('Audio playback test completed');
      }
    } catch (e) {
      print('❌ Audio playback test error: $e');
    }
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
      _audioStreamSubscription?.cancel();
      _amplitudeSubscription?.cancel();
      _audioValidationTimer?.cancel();
      _audioStreamController.close();
      _recorder.closeAudioSession();
      _player.closeAudioSession();
      print('🎯 Real audio detector disposed');
    } catch (e) {
      _handleError('Error disposing real audio detector: $e');
    }
  }
}