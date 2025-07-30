import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'audio_capture_config.dart';
import 'adaptive_strike_detector.dart';
import 'strike_sound_characteristics.dart';
import 'real_audio_capture.dart';

/// Strike Audio Detector
/// Apple-level optimized main orchestrator for strike sound detection
/// Provides high-level interface for real-time audio capture and strike detection
class StrikeAudioDetector {
  // Apple optimization: Core components
  late AdaptiveStrikeDetector _detector;
  late AudioCaptureConfig _config;
  
  // Apple optimization: State management
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isCapturing = false;
  
  // Apple optimization: Real audio capture
  RealAudioCapture? _realAudioCapture;
  final List<double> _audioBuffer = [];
  int _bufferIndex = 0;
  
  // Apple optimization: Performance and monitoring
  final Map<String, dynamic> _systemMetrics = {};
  final List<String> _errorLog = [];
  int _maxErrorLogSize = 50;
  
  // Apple optimization: Callbacks
  VoidCallback? onStrikeDetected;
  Function(String)? onError;
  Function(Map<String, dynamic>)? onPerformanceUpdate;
  Function(String)? onStatusUpdate;
  
  // Apple optimization: Device compatibility
  bool _isDeviceCompatible = false;
  String _deviceCompatibilityReason = '';
  
  // Apple optimization: Power management
  bool _isPowerOptimized = false;
  Timer? _powerOptimizationTimer;
  
  StrikeAudioDetector({
    AudioCaptureConfig? config,
    StrikeType strikeType = StrikeType.general,
  }) {
    _config = config ?? AudioCaptureConfig();
    _initializeDetector(strikeType);
  }
  
  /// Apple optimization: Initialize detector with device compatibility check
  void _initializeDetector(StrikeType strikeType) {
    try {
      // Apple optimization: Check device compatibility
      _checkDeviceCompatibility();
      
      if (!_isDeviceCompatible) {
        _handleError('Device not compatible: $_deviceCompatibilityReason');
        return;
      }
      
      // Apple optimization: Create adaptive detector
      _detector = AdaptiveStrikeDetector(
        config: _config,
        strikeType: strikeType,
      );
      
      // Apple optimization: Initialize real audio capture
      _realAudioCapture = RealAudioCapture();
      await _realAudioCapture!.initialize();
      
      // Apple optimization: Set up callbacks
      _setupCallbacks();
      
      // Apple optimization: Initialize system metrics
      _initializeSystemMetrics();
      
      _isInitialized = true;
      _updateStatus('Initialized successfully');
      
    } catch (e) {
      _handleError('Failed to initialize detector: $e');
    }
  }
  
  /// Apple optimization: Check device compatibility
  void _checkDeviceCompatibility() {
    try {
      // Apple optimization: Check platform support
      if (!Platform.isAndroid && !Platform.isIOS) {
        _isDeviceCompatible = false;
        _deviceCompatibilityReason = 'Platform not supported';
        return;
      }
      
      // Apple optimization: Check audio permissions (simplified)
      // In real implementation, check actual audio permissions
      _isDeviceCompatible = true;
      _deviceCompatibilityReason = 'Device compatible';
      
    } catch (e) {
      _isDeviceCompatible = false;
      _deviceCompatibilityReason = 'Compatibility check failed: $e';
    }
  }
  
  /// Apple optimization: Set up detector callbacks
  void _setupCallbacks() {
    _detector.onStrikeDetected = () {
      // Apple optimization: Trigger strike detection callback
      onStrikeDetected?.call();
      
      // Apple optimization: Update metrics
      _updateStrikeDetectionMetrics();
    };
    
    _detector.onError = (error) {
      _handleError('Detector error: $error');
    };
    
    _detector.onPerformanceUpdate = (metrics) {
      _updatePerformanceMetrics(metrics);
    };
    
    // Apple optimization: Set up real audio capture callbacks
    _realAudioCapture?.onAudioData = (audioData) {
      _processRealAudioData(audioData);
    };
    
    _realAudioCapture?.onError = (error) {
      _handleError('Audio capture error: $error');
    };
    
    _realAudioCapture?.onStatusUpdate = (status) {
      _updateStatus('Audio: $status');
    };
  }
  
  /// Apple optimization: Initialize system metrics
  void _initializeSystemMetrics() {
    _systemMetrics.clear();
    _systemMetrics['initialization_time'] = DateTime.now().millisecondsSinceEpoch;
    _systemMetrics['total_strikes_detected'] = 0;
    _systemMetrics['total_errors'] = 0;
    _systemMetrics['uptime_seconds'] = 0;
    _systemMetrics['memory_usage_mb'] = 0;
    _systemMetrics['cpu_usage_percent'] = 0;
    _systemMetrics['battery_impact'] = 'low';
    _systemMetrics['status'] = 'initialized';
  }
  
  /// Apple optimization: Start listening for strike sounds
  Future<bool> startListening() async {
    if (!_isInitialized) {
      _handleError('Detector not initialized');
      return false;
    }
    
    if (_isListening) {
      return true; // Already listening
    }
    
    try {
      // Apple optimization: Start adaptive detector
      final success = await _detector.startListening();
      if (!success) {
        _handleError('Failed to start adaptive detector');
        return false;
      }
      
      // Apple optimization: Start audio capture
      await _startAudioCapture();
      
      _isListening = true;
      _updateStatus('Listening for strike sounds');
      
      // Apple optimization: Start power optimization
      _startPowerOptimization();
      
      return true;
      
    } catch (e) {
      _handleError('Failed to start listening: $e');
      return false;
    }
  }
  
  /// Apple optimization: Stop listening for strike sounds
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      // Apple optimization: Stop audio capture
      await _stopAudioCapture();
      
      // Apple optimization: Stop adaptive detector
      await _detector.stopListening();
      
      // Apple optimization: Stop power optimization
      _stopPowerOptimization();
      
      _isListening = false;
      _updateStatus('Stopped listening');
      
    } catch (e) {
      _handleError('Failed to stop listening: $e');
    }
  }
  
  /// Apple optimization: Start real audio capture
  Future<void> _startAudioCapture() async {
    try {
      // Apple optimization: Initialize audio buffer
      _audioBuffer.clear();
      _audioBuffer.addAll(List.filled(_config.optimizedBufferSize, 0.0));
      _bufferIndex = 0;
      
      // Apple optimization: Start real audio capture
      final success = await _realAudioCapture?.startCapture();
      if (success == true) {
        _isCapturing = true;
        _updateStatus('Real audio capture started');
      } else {
        _handleError('Failed to start real audio capture');
      }
      
    } catch (e) {
      _handleError('Failed to start audio capture: $e');
    }
  }
  
  /// Apple optimization: Stop real audio capture
  Future<void> _stopAudioCapture() async {
    try {
      _isCapturing = false;
      await _realAudioCapture?.stopCapture();
      
    } catch (e) {
      _handleError('Failed to stop audio capture: $e');
    }
  }
  

  
  /// Apple optimization: Process real audio data
  void _processRealAudioData(List<double> audioData) {
    try {
      // Apple optimization: Process audio data directly
      final bufferCopy = List<double>.from(audioData);
      _detector.processAudioBuffer(bufferCopy);
      
    } catch (e) {
      _handleError('Error processing real audio data: $e');
    }
  }
  
  /// Apple optimization: Start power optimization
  void _startPowerOptimization() {
    if (!_config.enablePowerOptimization) return;
    
    _powerOptimizationTimer = Timer.periodic(
      Duration(milliseconds: _config.powerSavingIntervalMs),
      (timer) {
        if (!_isListening) {
          timer.cancel();
          return;
        }
        
        _optimizePowerUsage();
      },
    );
  }
  
  /// Apple optimization: Stop power optimization
  void _stopPowerOptimization() {
    _powerOptimizationTimer?.cancel();
    _powerOptimizationTimer = null;
  }
  
  /// Apple optimization: Optimize power usage
  void _optimizePowerUsage() {
    try {
      // Apple optimization: Adjust processing based on battery level
      // In real implementation, check actual battery level
      final batteryLevel = 0.8; // Simulated battery level
      
      if (batteryLevel < 0.2) {
        // Low battery - reduce processing
        _config = _config.copyWith(
          fftSize: 1024,
          smoothingWindow: 3,
          powerSavingIntervalMs: 10000,
        );
        _isPowerOptimized = true;
      } else if (batteryLevel > 0.5 && _isPowerOptimized) {
        // Good battery - restore full processing
        _config = _config.copyWith(
          fftSize: 2048,
          smoothingWindow: 5,
          powerSavingIntervalMs: 5000,
        );
        _isPowerOptimized = false;
      }
      
    } catch (e) {
      _handleError('Error optimizing power usage: $e');
    }
  }
  
  /// Apple optimization: Update strike detection metrics
  void _updateStrikeDetectionMetrics() {
    try {
      _systemMetrics['total_strikes_detected'] = 
          (_systemMetrics['total_strikes_detected'] ?? 0) + 1;
      
      // Apple optimization: Update uptime
      final initializationTime = _systemMetrics['initialization_time'] ?? 0;
      final uptime = (DateTime.now().millisecondsSinceEpoch - initializationTime) / 1000;
      _systemMetrics['uptime_seconds'] = uptime;
      
    } catch (e) {
      _handleError('Error updating strike detection metrics: $e');
    }
  }
  
  /// Apple optimization: Update performance metrics
  void _updatePerformanceMetrics(Map<String, dynamic> detectorMetrics) {
    try {
      _systemMetrics.addAll(detectorMetrics);
      _systemMetrics['last_update'] = DateTime.now().millisecondsSinceEpoch;
      
      // Apple optimization: Trigger performance update callback
      onPerformanceUpdate?.call(_systemMetrics);
      
    } catch (e) {
      _handleError('Error updating performance metrics: $e');
    }
  }
  
  /// Apple optimization: Update status
  void _updateStatus(String status) {
    _systemMetrics['status'] = status;
    onStatusUpdate?.call(status);
  }
  
  /// Apple optimization: Handle errors gracefully
  void _handleError(String error) {
    try {
      _errorLog.add('${DateTime.now()}: $error');
      
      // Apple optimization: Limit error log size
      if (_errorLog.length > _maxErrorLogSize) {
        _errorLog.removeAt(0);
      }
      
      _systemMetrics['total_errors'] = _errorLog.length;
      
      // Apple optimization: Trigger error callback
      onError?.call(error);
      
    } catch (e) {
      print('Error handling error: $e');
    }
  }
  
  /// Apple optimization: Set user sensitivity
  void setUserSensitivity(double sensitivity) {
    if (_isInitialized) {
      _detector.setUserSensitivity(sensitivity);
    }
  }
  
  /// Apple optimization: Get user sensitivity
  double get userSensitivity => _detector.userSensitivity;
  
  /// Apple optimization: Set user enabled state
  void setUserEnabled(bool enabled) {
    if (_isInitialized) {
      _detector.setUserEnabled(enabled);
    }
  }
  
  /// Apple optimization: Get user enabled state
  bool get userEnabled => _detector.userEnabled;
  
  /// Apple optimization: Get initialization status
  bool get isInitialized => _isInitialized;
  
  /// Apple optimization: Get listening status
  bool get isListening => _isListening;
  
  /// Apple optimization: Get device compatibility status
  bool get isDeviceCompatible => _isDeviceCompatible;
  
  /// Apple optimization: Get device compatibility reason
  String get deviceCompatibilityReason => _deviceCompatibilityReason;
  
  /// Apple optimization: Get calibration status
  bool get isCalibrated => _detector.isCalibrated;
  
  /// Apple optimization: Get system metrics
  Map<String, dynamic> get systemMetrics => Map.unmodifiable(_systemMetrics);
  
  /// Apple optimization: Get detector metrics
  Map<String, dynamic> get detectorMetrics => _detector.performanceMetrics;
  
  /// Apple optimization: Get error log
  List<String> get errorLog => List.unmodifiable(_errorLog);
  
  /// Apple optimization: Get configuration
  AudioCaptureConfig get configuration => _config;
  
  /// Apple optimization: Reset detector state
  void reset() {
    try {
      stopListening();
      _detector.reset();
      _initializeSystemMetrics();
      _errorLog.clear();
      _updateStatus('Reset');
      
    } catch (e) {
      _handleError('Error resetting detector: $e');
    }
  }
  
  /// Apple optimization: Dispose resources
  void dispose() {
    try {
      stopListening();
      _detector.dispose();
      _realAudioCapture?.dispose();
      _powerOptimizationTimer?.cancel();
      
    } catch (e) {
      _handleError('Error disposing detector: $e');
    }
  }
} 