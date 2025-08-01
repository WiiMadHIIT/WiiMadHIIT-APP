import 'dart:async';
import 'package:flutter/foundation.dart';

/// Simple Audio Detector - Mock Implementation
/// 暂时只打印信息，不进行实际的音频处理
/// 用于开发和测试阶段
class SimpleAudioDetector {
  // State management
  bool _isInitialized = false;
  bool _isListening = false;
  
  // Callbacks
  VoidCallback? onStrikeDetected;
  Function(String)? onError;
  Function(String)? onStatusUpdate;
  
  // Mock data
  double _currentDb = 0.0;
  int _hitCount = 0;
  DateTime? _lastStrikeTime;
  
  // Mock timer for simulating audio detection
  Timer? _mockTimer;
  
  /// Initialize detector (mock)
  Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        _updateStatus('Simple audio detector already initialized');
        print('🎯 Simple audio detector already initialized');
        return true;
      }
      
      // Simulate initialization delay
      await Future.delayed(Duration(milliseconds: 500));
      
      _isInitialized = true;
      _updateStatus('Simple audio detector initialized (mock)');
      print('🎯 Simple audio detector initialized successfully (mock mode)');
      return true;
    } catch (e) {
      print('❌ Failed to initialize simple audio detector: $e');
      _handleError('Failed to initialize simple audio detector: $e');
      return false;
    }
  }
  
  /// Start listening (mock)
  Future<bool> startListening() async {
    if (!_isInitialized) {
      _handleError('Simple audio detector not initialized');
      return false;
    }
    
    if (_isListening) {
      print('🎯 Simple audio detection already listening');
      return true;
    }
    
    try {
      print('🎯 Starting simple audio detection (mock mode)...');
      
      // Clear previous data
      _hitCount = 0;
      _lastStrikeTime = null;
      _currentDb = 0.0;
      
      _isListening = true;
      _updateStatus('Started listening to microphone (mock)');
      
      // Start mock timer to simulate audio detection
      _startMockDetection();
      
      print('🎯 Simple audio detection started successfully (mock mode)');
      return true;
    } catch (e) {
      print('❌ Failed to start simple audio detection: $e');
      _handleError('Failed to start simple audio detection: $e');
      return false;
    }
  }
  
  /// Stop listening (mock)
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      print('🎯 Stopping simple audio detection...');
      
      // Stop mock timer
      _mockTimer?.cancel();
      _mockTimer = null;
      
      _isListening = false;
      _updateStatus('Stopped listening to microphone (mock)');
      
      print('🎯 Simple audio detection stopped (mock mode)');
    } catch (e) {
      _handleError('Failed to stop simple audio detection: $e');
    }
  }
  
  /// Start mock detection timer
  void _startMockDetection() {
    // Simulate audio detection every 2-5 seconds
    _mockTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }
      
      // Simulate random audio levels
      _currentDb = 30.0 + (DateTime.now().millisecondsSinceEpoch % 50);
      
      print('🎤 Mock Current dB: ${_currentDb.toStringAsFixed(1)} dB');
      
      // Simulate strike detection (randomly)
      if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
        _simulateStrikeDetection();
      }
    });
  }
  
  /// Simulate strike detection
  void _simulateStrikeDetection() {
    final now = DateTime.now();
    
    // Check time interval (minimum 1 second between detections)
    if (_lastStrikeTime == null || 
        now.difference(_lastStrikeTime!).inMilliseconds > 1000) {
      
      _lastStrikeTime = now;
      _hitCount++;
      
      print('🎯 MOCK STRIKE DETECTED! dB: ${_currentDb.toStringAsFixed(1)}, Count: $_hitCount');
      
      // Trigger strike detection callback
      onStrikeDetected?.call();
    } else {
      final timeSinceLast = now.difference(_lastStrikeTime!).inMilliseconds;
      print('⚠️ Mock strike ignored (too soon): Time since last: ${timeSinceLast}ms');
    }
  }
  
  /// Get listening status
  bool get isListening => _isListening;
  
  /// Get initialization status
  bool get isInitialized => _isInitialized;
  
  /// Get current decibel level (mock)
  double get currentDb => _currentDb;
  
  /// Get hit count
  int get hitCount => _hitCount;
  
  /// Reset hit count
  void resetHitCount() {
    _hitCount = 0;
    _lastStrikeTime = null;
    print('🎯 Mock hit count reset to 0');
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
      _mockTimer?.cancel();
      print('🎯 Simple audio detector disposed (mock mode)');
    } catch (e) {
      _handleError('Error disposing simple audio detector: $e');
    }
  }
} 