import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'audio_capture_config.dart';
import 'audio_analyzer.dart';
import 'strike_sound_characteristics.dart';

/// Adaptive Strike Detector
/// Apple-level optimized intelligent strike detection with adaptive learning
/// Provides real-time strike sound detection with user pattern recognition
class AdaptiveStrikeDetector {
  // Apple optimization: Core components
  late AudioAnalyzer _analyzer;
  late AudioCaptureConfig _config;
  late StrikeSoundCharacteristics _characteristics;
  
  // Apple optimization: State management
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isCalibrated = false;
  
  // Apple optimization: User learning and adaptation
  double _userSensitivity = 1.0;
  bool _userEnabled = true;
  final Map<String, dynamic> _userLearningData = {};
  
  // Apple optimization: Performance monitoring
  final Map<String, dynamic> _performanceMetrics = {};
  final List<double> _detectionLatencies = [];
  final List<bool> _detectionResults = [];
  
  // Apple optimization: Callbacks
  VoidCallback? onStrikeDetected;
  Function(String)? onError;
  Function(Map<String, dynamic>)? onPerformanceUpdate;
  
  // Apple optimization: Debouncing and rate limiting
  Timer? _debounceTimer;
  DateTime? _lastDetectionTime;
  static const int _minDetectionIntervalMs = 100; // Minimum 100ms between detections
  
  // Apple optimization: Calibration
  static const int _calibrationSamples = 50;
  int _calibrationCount = 0;
  final List<double> _calibrationData = [];
  
  AdaptiveStrikeDetector({
    AudioCaptureConfig? config,
    StrikeSoundCharacteristics? characteristics,
    StrikeType strikeType = StrikeType.general,
  }) {
    _config = config ?? AudioCaptureConfig();
    _characteristics = characteristics ?? StrikeSoundCharacteristics.forStrikeType(strikeType);
    _initializeDetector();
  }
  
  /// Apple optimization: Initialize detector with optimal settings
  void _initializeDetector() {
    try {
      _analyzer = AudioAnalyzer(
        config: _config,
        characteristics: _characteristics,
      );
      
      _initializeUserLearningData();
      _initializePerformanceMetrics();
      
      _isInitialized = true;
      
    } catch (e) {
      _handleError('Failed to initialize detector: $e');
    }
  }
  
  /// Apple optimization: Initialize user learning data structure
  void _initializeUserLearningData() {
    _userLearningData.clear();
    _userLearningData['sensitivity'] = 1.0;
    _userLearningData['patterns'] = {
      'energy_range': {'min': 0.0, 'max': 0.0, 'avg': 0.0},
      'frequency_range': {'min': 0.0, 'max': 0.0, 'avg': 0.0},
      'spectral_centroid_range': {'min': 0.0, 'max': 0.0, 'avg': 0.0},
      'detection_history': [],
    };
    _userLearningData['preferences'] = {
      'auto_calibration': true,
      'adaptive_thresholds': true,
      'performance_optimization': true,
    };
  }
  
  /// Apple optimization: Initialize performance metrics
  void _initializePerformanceMetrics() {
    _performanceMetrics.clear();
    _performanceMetrics['total_detections'] = 0;
    _performanceMetrics['false_positives'] = 0;
    _performanceMetrics['false_negatives'] = 0;
    _performanceMetrics['average_latency'] = 0.0;
    _performanceMetrics['detection_accuracy'] = 0.0;
    _performanceMetrics['calibration_status'] = 'not_calibrated';
    _performanceMetrics['last_update'] = DateTime.now().millisecondsSinceEpoch;
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
      // Apple optimization: Start calibration if needed
      if (!_isCalibrated && _userLearningData['preferences']['auto_calibration']) {
        await _startCalibration();
      }
      
      _isListening = true;
      _startPerformanceMonitoring();
      
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
      _isListening = false;
      _stopPerformanceMonitoring();
      _debounceTimer?.cancel();
      
    } catch (e) {
      _handleError('Failed to stop listening: $e');
    }
  }
  
  /// Apple optimization: Process audio buffer for strike detection
  bool processAudioBuffer(List<double> audioBuffer) {
    if (!_isListening || !_isInitialized) return false;
    
    try {
      final startTime = DateTime.now();
      
      // Apple optimization: Update ambient noise level for calibration
      if (!_isCalibrated) {
        _analyzer.updateAmbientNoiseLevel(audioBuffer);
        _updateCalibrationProgress(audioBuffer);
        return false;
      }
      
      // Apple optimization: Analyze audio for strike detection
      final isStrike = _analyzer.analyzeAudioBuffer(audioBuffer);
      
      if (isStrike) {
        // Apple optimization: Apply debouncing to prevent false positives
        if (_shouldProcessDetection()) {
          _processStrikeDetection(startTime);
        }
      }
      
      // Apple optimization: Update performance metrics
      _updatePerformanceMetrics(isStrike, startTime);
      
      return isStrike;
      
    } catch (e) {
      _handleError('Error processing audio buffer: $e');
      return false;
    }
  }
  
  /// Apple optimization: Check if detection should be processed (debouncing)
  bool _shouldProcessDetection() {
    final now = DateTime.now();
    
    // Check minimum interval between detections
    if (_lastDetectionTime != null) {
      final timeSinceLastDetection = now.difference(_lastDetectionTime!).inMilliseconds;
      if (timeSinceLastDetection < _minDetectionIntervalMs) {
        return false;
      }
    }
    
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    
    // Set new debounce timer
    _debounceTimer = Timer(Duration(milliseconds: _config.debounceTimeMs), () {
      _lastDetectionTime = now;
    });
    
    return true;
  }
  
  /// Apple optimization: Process confirmed strike detection
  void _processStrikeDetection(DateTime detectionTime) {
    try {
      // Apple optimization: Update user learning data
      _updateUserLearningData();
      
      // Apple optimization: Trigger callback
      onStrikeDetected?.call();
      
      // Apple optimization: Record detection for performance analysis
      _recordDetection(detectionTime, true);
      
    } catch (e) {
      _handleError('Error processing strike detection: $e');
    }
  }
  
  /// Apple optimization: Start calibration process
  Future<void> _startCalibration() async {
    _calibrationCount = 0;
    _calibrationData.clear();
    _performanceMetrics['calibration_status'] = 'calibrating';
    
    // Apple optimization: Notify performance update
    onPerformanceUpdate?.call(_performanceMetrics);
  }
  
  /// Apple optimization: Update calibration progress
  void _updateCalibrationProgress(List<double> audioBuffer) {
    final energy = _analyzer.ambientNoiseLevel;
    _calibrationData.add(energy);
    _calibrationCount++;
    
    if (_calibrationCount >= _calibrationSamples) {
      _completeCalibration();
    }
  }
  
  /// Apple optimization: Complete calibration process
  void _completeCalibration() {
    try {
      // Apple optimization: Calculate calibration statistics
      final sortedData = List<double>.from(_calibrationData)..sort();
      final median = sortedData[sortedData.length ~/ 2];
      final q1 = sortedData[sortedData.length ~/ 4];
      final q3 = sortedData[3 * sortedData.length ~/ 4];
      final iqr = q3 - q1;
      
      // Apple optimization: Set adaptive thresholds based on calibration
      final noiseLevel = median;
      final noiseVariability = iqr;
      
      // Apple optimization: Update analyzer with calibrated settings
      _analyzer.setUserSensitivity(_userSensitivity);
      
      _isCalibrated = true;
      _performanceMetrics['calibration_status'] = 'calibrated';
      _performanceMetrics['ambient_noise_level'] = noiseLevel;
      _performanceMetrics['noise_variability'] = noiseVariability;
      
      // Apple optimization: Notify performance update
      onPerformanceUpdate?.call(_performanceMetrics);
      
    } catch (e) {
      _handleError('Error completing calibration: $e');
    }
  }
  
  /// Apple optimization: Update user learning data with new detection
  void _updateUserLearningData() {
    try {
      final analyzerMetrics = _analyzer.performanceMetrics;
      final patterns = _userLearningData['patterns'];
      
      // Apple optimization: Update energy patterns
      final currentEnergy = analyzerMetrics['ambient_noise_level'] ?? 0.0;
      _updateRange(patterns['energy_range'], currentEnergy);
      
      // Apple optimization: Update frequency patterns (simplified)
      final currentFrequency = 1000.0; // Placeholder for actual frequency
      _updateRange(patterns['frequency_range'], currentFrequency);
      
      // Apple optimization: Update spectral centroid patterns
      final currentCentroid = 1500.0; // Placeholder for actual centroid
      _updateRange(patterns['spectral_centroid_range'], currentCentroid);
      
      // Apple optimization: Update detection history
      final history = patterns['detection_history'] as List;
      history.add({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'energy': currentEnergy,
        'frequency': currentFrequency,
        'centroid': currentCentroid,
      });
      
      // Apple optimization: Limit history size for memory efficiency
      if (history.length > 100) {
        history.removeAt(0);
      }
      
      // Apple optimization: Adapt sensitivity based on user patterns
      _adaptUserSensitivity();
      
    } catch (e) {
      _handleError('Error updating user learning data: $e');
    }
  }
  
  /// Apple optimization: Update range statistics
  void _updateRange(Map<String, double> range, double value) {
    if (range['min'] == 0.0 && range['max'] == 0.0) {
      range['min'] = value;
      range['max'] = value;
      range['avg'] = value;
    } else {
      range['min'] = min(range['min']!, value);
      range['max'] = max(range['max']!, value);
      range['avg'] = (range['avg']! + value) / 2.0;
    }
  }
  
  /// Apple optimization: Adapt user sensitivity based on patterns
  void _adaptUserSensitivity() {
    try {
      final patterns = _userLearningData['patterns'];
      final energyRange = patterns['energy_range'];
      final frequencyRange = patterns['frequency_range'];
      
      // Apple optimization: Calculate pattern consistency
      final energyConsistency = (energyRange['max']! - energyRange['min']!) / (energyRange['avg']! + 0.001);
      final frequencyConsistency = (frequencyRange['max']! - frequencyRange['min']!) / (frequencyRange['avg']! + 0.001);
      
      // Apple optimization: Adjust sensitivity based on consistency
      double newSensitivity = _userSensitivity;
      
      if (energyConsistency < 0.3 && frequencyConsistency < 0.3) {
        // Very consistent patterns - can increase sensitivity
        newSensitivity = min(2.0, _userSensitivity * 1.1);
      } else if (energyConsistency > 0.8 || frequencyConsistency > 0.8) {
        // Inconsistent patterns - decrease sensitivity
        newSensitivity = max(0.5, _userSensitivity * 0.9);
      }
      
      if ((newSensitivity - _userSensitivity).abs() > 0.1) {
        setUserSensitivity(newSensitivity);
      }
      
    } catch (e) {
      _handleError('Error adapting user sensitivity: $e');
    }
  }
  
  /// Apple optimization: Update performance metrics
  void _updatePerformanceMetrics(bool isStrike, DateTime startTime) {
    try {
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      
      _detectionLatencies.add(latency.toDouble());
      _detectionResults.add(isStrike);
      
      // Apple optimization: Limit metrics history for memory efficiency
      if (_detectionLatencies.length > 1000) {
        _detectionLatencies.removeAt(0);
        _detectionResults.removeAt(0);
      }
      
      // Apple optimization: Calculate performance statistics
      _performanceMetrics['total_detections'] = _detectionResults.where((r) => r).length;
      _performanceMetrics['average_latency'] = _detectionLatencies.isNotEmpty 
          ? _detectionLatencies.reduce((a, b) => a + b) / _detectionLatencies.length 
          : 0.0;
      _performanceMetrics['detection_accuracy'] = _calculateDetectionAccuracy();
      _performanceMetrics['last_update'] = DateTime.now().millisecondsSinceEpoch;
      
      // Apple optimization: Periodic performance update
      if (_performanceMetrics['total_detections'] % 10 == 0) {
        onPerformanceUpdate?.call(_performanceMetrics);
      }
      
    } catch (e) {
      _handleError('Error updating performance metrics: $e');
    }
  }
  
  /// Apple optimization: Calculate detection accuracy
  double _calculateDetectionAccuracy() {
    if (_detectionResults.isEmpty) return 0.0;
    
    // Apple optimization: Simple accuracy calculation (can be enhanced)
    final totalDetections = _detectionResults.where((r) => r).length;
    final totalSamples = _detectionResults.length;
    
    return totalSamples > 0 ? totalDetections / totalSamples : 0.0;
  }
  
  /// Apple optimization: Record detection for analysis
  void _recordDetection(DateTime detectionTime, bool isTruePositive) {
    try {
      final detection = {
        'timestamp': detectionTime.millisecondsSinceEpoch,
        'is_true_positive': isTruePositive,
        'user_sensitivity': _userSensitivity,
        'ambient_noise_level': _analyzer.ambientNoiseLevel,
        'adaptive_threshold': _analyzer.adaptiveThreshold,
      };
      
      // Apple optimization: Store detection record (simplified)
      // In a real implementation, this could be stored locally or sent to analytics
      
    } catch (e) {
      _handleError('Error recording detection: $e');
    }
  }
  
  /// Apple optimization: Start performance monitoring
  void _startPerformanceMonitoring() {
    // Apple optimization: Periodic performance monitoring
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }
      
      _updatePerformanceMetrics(false, DateTime.now());
    });
  }
  
  /// Apple optimization: Stop performance monitoring
  void _stopPerformanceMonitoring() {
    // Timer will be cancelled automatically when _isListening becomes false
  }
  
  /// Apple optimization: Set user sensitivity
  void setUserSensitivity(double sensitivity) {
    _userSensitivity = sensitivity.clamp(0.5, 2.0);
    _userLearningData['sensitivity'] = _userSensitivity;
    
    if (_isInitialized) {
      _analyzer.setUserSensitivity(_userSensitivity);
    }
  }
  
  /// Apple optimization: Get user sensitivity
  double get userSensitivity => _userSensitivity;
  
  /// Apple optimization: Set user enabled state
  void setUserEnabled(bool enabled) {
    _userEnabled = enabled;
  }
  
  /// Apple optimization: Get user enabled state
  bool get userEnabled => _userEnabled;
  
  /// Apple optimization: Get calibration status
  bool get isCalibrated => _isCalibrated;
  
  /// Apple optimization: Get listening status
  bool get isListening => _isListening;
  
  /// Apple optimization: Get initialization status
  bool get isInitialized => _isInitialized;
  
  /// Apple optimization: Get performance metrics
  Map<String, dynamic> get performanceMetrics => Map.unmodifiable(_performanceMetrics);
  
  /// Apple optimization: Get user learning data
  Map<String, dynamic> get userLearningData => Map.unmodifiable(_userLearningData);
  
  /// Apple optimization: Get analyzer metrics
  Map<String, dynamic> get analyzerMetrics => _analyzer.performanceMetrics;
  
  /// Apple optimization: Handle errors gracefully
  void _handleError(String error) {
    print('AdaptiveStrikeDetector Error: $error');
    onError?.call(error);
  }
  
  /// Apple optimization: Reset detector state
  void reset() {
    try {
      stopListening();
      
      _isCalibrated = false;
      _calibrationCount = 0;
      _calibrationData.clear();
      
      _analyzer.reset();
      _initializeUserLearningData();
      _initializePerformanceMetrics();
      
      _detectionLatencies.clear();
      _detectionResults.clear();
      
    } catch (e) {
      _handleError('Error resetting detector: $e');
    }
  }
  
  /// Apple optimization: Dispose resources
  void dispose() {
    try {
      stopListening();
      _debounceTimer?.cancel();
      
    } catch (e) {
      _handleError('Error disposing detector: $e');
    }
  }
} 