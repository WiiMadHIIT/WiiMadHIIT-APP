import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:flutter/foundation.dart';

/// Real Audio Capture Implementation
/// Apple-level optimized real-time audio capture using record library
/// Provides actual microphone input for strike detection
class RealAudioCapture {
  // Core components
  final AudioRecorder _recorder = AudioRecorder();
  
  // State management
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _hasPermission = false;
  
  // Audio processing
  StreamSubscription? _audioStreamSubscription;
  final List<double> _audioBuffer = [];
  int _bufferIndex = 0;
  final int _bufferSize = 1024;
  
  // Callbacks
  Function(List<double>)? onAudioData;
  Function(String)? onError;
  Function(String)? onStatusUpdate;
  
  /// Initialize audio capture
  Future<bool> initialize() async {
    try {
      // Check and request microphone permission
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _handleError('Microphone permission not granted');
        return false;
      }
      
      _hasPermission = true;
      _isInitialized = true;
      _updateStatus('Initialized successfully');
      
      return true;
    } catch (e) {
      _handleError('Failed to initialize audio capture: $e');
      return false;
    }
  }
  
  /// Start audio capture
  Future<bool> startCapture() async {
    if (!_isInitialized || !_hasPermission) {
      _handleError('Audio capture not initialized or no permission');
      return false;
    }
    
    if (_isCapturing) {
      return true; // Already capturing
    }
    
    try {
      // Initialize audio buffer
      _audioBuffer.clear();
      _audioBuffer.addAll(List.filled(_bufferSize, 0.0));
      _bufferIndex = 0;
      
      // Start recording with optimal settings for strike detection
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
          bitRate: 128000,
        ),
      );
      
      // Listen to audio stream
      _audioStreamSubscription = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 10))
          .listen(_processAudioAmplitude);
      
      _isCapturing = true;
      _updateStatus('Audio capture started');
      
      return true;
    } catch (e) {
      _handleError('Failed to start audio capture: $e');
      return false;
    }
  }
  
  /// Stop audio capture
  Future<void> stopCapture() async {
    if (!_isCapturing) return;
    
    try {
      _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;
      
      await _recorder.stop();
      
      _isCapturing = false;
      _updateStatus('Audio capture stopped');
    } catch (e) {
      _handleError('Failed to stop audio capture: $e');
    }
  }
  
  /// Process audio amplitude data
  void _processAudioAmplitude(Amplitude amplitude) {
    try {
      // Convert amplitude to normalized audio data
      final normalizedAmplitude = amplitude.current / 32768.0; // Normalize to [-1, 1]
      
      // Add to buffer
      _audioBuffer[_bufferIndex] = normalizedAmplitude;
      _bufferIndex = (_bufferIndex + 1) % _bufferSize;
      
      // When buffer is full, process it
      if (_bufferIndex == 0) {
        final bufferCopy = List<double>.from(_audioBuffer);
        onAudioData?.call(bufferCopy);
      }
    } catch (e) {
      _handleError('Error processing audio amplitude: $e');
    }
  }
  
  /// Get current amplitude for real-time monitoring
  Future<Amplitude?> getCurrentAmplitude() async {
    try {
      if (_isCapturing) {
        return await _recorder.getAmplitude();
      }
      return null;
    } catch (e) {
      _handleError('Error getting amplitude: $e');
      return null;
    }
  }
  
  /// Check if currently capturing
  bool get isCapturing => _isCapturing;
  
  /// Check if initialized
  bool get isInitialized => _isInitialized;
  
  /// Check if has permission
  bool get hasPermission => _hasPermission;
  
  /// Update status
  void _updateStatus(String status) {
    onStatusUpdate?.call(status);
  }
  
  /// Handle errors
  void _handleError(String error) {
    onError?.call(error);
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    try {
      await stopCapture();
      await _recorder.dispose();
    } catch (e) {
      _handleError('Error disposing audio capture: $e');
    }
  }
} 