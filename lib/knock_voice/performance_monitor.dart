import 'dart:async';
import 'dart:io';
import 'dart:math';

/// Performance Monitor
/// Apple-level optimized performance monitoring and optimization
/// Provides real-time performance tracking and intelligent resource management
class PerformanceMonitor {
  // Apple optimization: Performance metrics
  final Map<String, dynamic> _metrics = {};
  final List<double> _latencyHistory = [];
  final List<double> _memoryHistory = [];
  final List<double> _cpuHistory = [];
  final List<int> _detectionHistory = [];
  
  // Apple optimization: Performance thresholds
  static const double _maxLatencyMs = 50.0;
  static const double _maxMemoryMB = 100.0;
  static const double _maxCpuPercent = 30.0;
  static const int _maxDetectionsPerSecond = 10;
  
  // Apple optimization: Monitoring state
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  DateTime? _sessionStartTime;
  
  // Apple optimization: Performance alerts
  final List<String> _performanceAlerts = [];
  static const int _maxAlerts = 20;
  
  // Apple optimization: Callbacks
  Function(String)? onPerformanceAlert;
  Function(Map<String, dynamic>)? onMetricsUpdate;
  
  // Apple optimization: Performance optimization
  bool _isOptimized = false;
  Map<String, dynamic> _optimizationSettings = {};
  
  PerformanceMonitor() {
    _initializeMetrics();
  }
  
  /// Apple optimization: Initialize performance metrics
  void _initializeMetrics() {
    _metrics.clear();
    _metrics['session_start_time'] = 0;
    _metrics['total_detections'] = 0;
    _metrics['average_latency_ms'] = 0.0;
    _metrics['peak_latency_ms'] = 0.0;
    _metrics['average_memory_mb'] = 0.0;
    _metrics['peak_memory_mb'] = 0.0;
    _metrics['average_cpu_percent'] = 0.0;
    _metrics['peak_cpu_percent'] = 0.0;
    _metrics['detections_per_second'] = 0.0;
    _metrics['performance_score'] = 100.0;
    _metrics['optimization_level'] = 'none';
    _metrics['last_update'] = 0;
  }
  
  /// Apple optimization: Start performance monitoring
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _sessionStartTime = DateTime.now();
    _metrics['session_start_time'] = _sessionStartTime!.millisecondsSinceEpoch;
    
    // Apple optimization: Start periodic monitoring
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isMonitoring) {
        timer.cancel();
        return;
      }
      
      _updatePerformanceMetrics();
    });
  }
  
  /// Apple optimization: Stop performance monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    // Apple optimization: Final metrics update
    _updatePerformanceMetrics();
  }
  
  /// Apple optimization: Record detection event
  void recordDetection({double? latency, bool isTruePositive = true}) {
    try {
      final timestamp = DateTime.now();
      
      // Apple optimization: Update detection count
      _metrics['total_detections'] = (_metrics['total_detections'] ?? 0) + 1;
      
      // Apple optimization: Record latency
      if (latency != null) {
        _latencyHistory.add(latency);
        _updateLatencyMetrics();
      }
      
      // Apple optimization: Record detection timestamp
      _detectionHistory.add(timestamp.millisecondsSinceEpoch);
      
      // Apple optimization: Check detection rate
      _checkDetectionRate();
      
      // Apple optimization: Trigger optimization if needed
      _checkPerformanceOptimization();
      
    } catch (e) {
      _addPerformanceAlert('Error recording detection: $e');
    }
  }
  
  /// Apple optimization: Update performance metrics
  void _updatePerformanceMetrics() {
    try {
      final currentTime = DateTime.now();
      
      // Apple optimization: Measure current performance
      final currentMemory = _getCurrentMemoryUsage();
      final currentCpu = _getCurrentCpuUsage();
      
      // Apple optimization: Update history
      _memoryHistory.add(currentMemory);
      _cpuHistory.add(currentCpu);
      
      // Apple optimization: Limit history size
      _limitHistorySize();
      
      // Apple optimization: Calculate metrics
      _calculatePerformanceMetrics();
      
      // Apple optimization: Update performance score
      _updatePerformanceScore();
      
      // Apple optimization: Check performance thresholds
      _checkPerformanceThresholds();
      
      // Apple optimization: Update timestamp
      _metrics['last_update'] = currentTime.millisecondsSinceEpoch;
      
      // Apple optimization: Trigger metrics update callback
      onMetricsUpdate?.call(Map.unmodifiable(_metrics));
      
    } catch (e) {
      _addPerformanceAlert('Error updating performance metrics: $e');
    }
  }
  
  /// Apple optimization: Get current memory usage (simplified)
  double _getCurrentMemoryUsage() {
    try {
      // Apple optimization: Simplified memory measurement
      // In real implementation, use platform-specific memory APIs
      final random = Random();
      return 20.0 + random.nextDouble() * 30.0; // Simulated memory usage
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Apple optimization: Get current CPU usage (simplified)
  double _getCurrentCpuUsage() {
    try {
      // Apple optimization: Simplified CPU measurement
      // In real implementation, use platform-specific CPU APIs
      final random = Random();
      return 5.0 + random.nextDouble() * 15.0; // Simulated CPU usage
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Apple optimization: Update latency metrics
  void _updateLatencyMetrics() {
    if (_latencyHistory.isEmpty) return;
    
    final averageLatency = _latencyHistory.reduce((a, b) => a + b) / _latencyHistory.length;
    final peakLatency = _latencyHistory.reduce(max);
    
    _metrics['average_latency_ms'] = averageLatency;
    _metrics['peak_latency_ms'] = peakLatency;
  }
  
  /// Apple optimization: Check detection rate
  void _checkDetectionRate() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final oneSecondAgo = now - 1000;
    
    // Apple optimization: Count detections in last second
    final recentDetections = _detectionHistory.where((timestamp) => timestamp >= oneSecondAgo).length;
    _metrics['detections_per_second'] = recentDetections.toDouble();
    
    // Apple optimization: Clean old detection history
    _detectionHistory.removeWhere((timestamp) => timestamp < oneSecondAgo);
  }
  
  /// Apple optimization: Calculate performance metrics
  void _calculatePerformanceMetrics() {
    if (_memoryHistory.isNotEmpty) {
      final averageMemory = _memoryHistory.reduce((a, b) => a + b) / _memoryHistory.length;
      final peakMemory = _memoryHistory.reduce(max);
      
      _metrics['average_memory_mb'] = averageMemory;
      _metrics['peak_memory_mb'] = peakMemory;
    }
    
    if (_cpuHistory.isNotEmpty) {
      final averageCpu = _cpuHistory.reduce((a, b) => a + b) / _cpuHistory.length;
      final peakCpu = _cpuHistory.reduce(max);
      
      _metrics['average_cpu_percent'] = averageCpu;
      _metrics['peak_cpu_percent'] = peakCpu;
    }
  }
  
  /// Apple optimization: Update performance score
  void _updatePerformanceScore() {
    double score = 100.0;
    
    // Apple optimization: Penalize high latency
    final averageLatency = _metrics['average_latency_ms'] as double? ?? 0.0;
    if (averageLatency > _maxLatencyMs) {
      score -= (averageLatency - _maxLatencyMs) * 2;
    }
    
    // Apple optimization: Penalize high memory usage
    final averageMemory = _metrics['average_memory_mb'] as double? ?? 0.0;
    if (averageMemory > _maxMemoryMB) {
      score -= (averageMemory - _maxMemoryMB) * 0.5;
    }
    
    // Apple optimization: Penalize high CPU usage
    final averageCpu = _metrics['average_cpu_percent'] as double? ?? 0.0;
    if (averageCpu > _maxCpuPercent) {
      score -= (averageCpu - _maxCpuPercent) * 1.5;
    }
    
    // Apple optimization: Penalize high detection rate
    final detectionsPerSecond = _metrics['detections_per_second'] as double? ?? 0.0;
    if (detectionsPerSecond > _maxDetectionsPerSecond) {
      score -= (detectionsPerSecond - _maxDetectionsPerSecond) * 5;
    }
    
    // Apple optimization: Ensure score is within bounds
    score = score.clamp(0.0, 100.0);
    _metrics['performance_score'] = score;
  }
  
  /// Apple optimization: Check performance thresholds
  void _checkPerformanceThresholds() {
    final averageLatency = _metrics['average_latency_ms'] as double? ?? 0.0;
    final averageMemory = _metrics['average_memory_mb'] as double? ?? 0.0;
    final averageCpu = _metrics['average_cpu_percent'] as double? ?? 0.0;
    final detectionsPerSecond = _metrics['detections_per_second'] as double? ?? 0.0;
    
    // Apple optimization: Check latency threshold
    if (averageLatency > _maxLatencyMs) {
      _addPerformanceAlert('High latency detected: ${averageLatency.toStringAsFixed(1)}ms');
    }
    
    // Apple optimization: Check memory threshold
    if (averageMemory > _maxMemoryMB) {
      _addPerformanceAlert('High memory usage detected: ${averageMemory.toStringAsFixed(1)}MB');
    }
    
    // Apple optimization: Check CPU threshold
    if (averageCpu > _maxCpuPercent) {
      _addPerformanceAlert('High CPU usage detected: ${averageCpu.toStringAsFixed(1)}%');
    }
    
    // Apple optimization: Check detection rate threshold
    if (detectionsPerSecond > _maxDetectionsPerSecond) {
      _addPerformanceAlert('High detection rate detected: ${detectionsPerSecond.toStringAsFixed(1)}/s');
    }
  }
  
  /// Apple optimization: Check if performance optimization is needed
  void _checkPerformanceOptimization() {
    final performanceScore = _metrics['performance_score'] as double? ?? 100.0;
    
    if (performanceScore < 70.0 && !_isOptimized) {
      _optimizePerformance();
    } else if (performanceScore > 90.0 && _isOptimized) {
      _restorePerformance();
    }
  }
  
  /// Apple optimization: Optimize performance
  void _optimizePerformance() {
    try {
      _isOptimized = true;
      _optimizationSettings = {
        'reduced_fft_size': true,
        'increased_smoothing': true,
        'reduced_update_frequency': true,
        'simplified_analysis': true,
      };
      
      _metrics['optimization_level'] = 'high';
      _addPerformanceAlert('Performance optimization activated');
      
    } catch (e) {
      _addPerformanceAlert('Error optimizing performance: $e');
    }
  }
  
  /// Apple optimization: Restore performance
  void _restorePerformance() {
    try {
      _isOptimized = false;
      _optimizationSettings.clear();
      
      _metrics['optimization_level'] = 'none';
      _addPerformanceAlert('Performance optimization deactivated');
      
    } catch (e) {
      _addPerformanceAlert('Error restoring performance: $e');
    }
  }
  
  /// Apple optimization: Add performance alert
  void _addPerformanceAlert(String alert) {
    final timestamp = DateTime.now();
    final alertMessage = '${timestamp.toString()}: $alert';
    
    _performanceAlerts.add(alertMessage);
    
    // Apple optimization: Limit alerts history
    if (_performanceAlerts.length > _maxAlerts) {
      _performanceAlerts.removeAt(0);
    }
    
    // Apple optimization: Trigger alert callback
    onPerformanceAlert?.call(alert);
  }
  
  /// Apple optimization: Limit history size for memory efficiency
  void _limitHistorySize() {
    const maxHistorySize = 100;
    
    if (_latencyHistory.length > maxHistorySize) {
      _latencyHistory.removeAt(0);
    }
    
    if (_memoryHistory.length > maxHistorySize) {
      _memoryHistory.removeAt(0);
    }
    
    if (_cpuHistory.length > maxHistorySize) {
      _cpuHistory.removeAt(0);
    }
  }
  
  /// Apple optimization: Get current performance metrics
  Map<String, dynamic> get currentMetrics => Map.unmodifiable(_metrics);
  
  /// Apple optimization: Get performance alerts
  List<String> get performanceAlerts => List.unmodifiable(_performanceAlerts);
  
  /// Apple optimization: Get optimization settings
  Map<String, dynamic> get optimizationSettings => Map.unmodifiable(_optimizationSettings);
  
  /// Apple optimization: Get monitoring status
  bool get isMonitoring => _isMonitoring;
  
  /// Apple optimization: Get optimization status
  bool get isOptimized => _isOptimized;
  
  /// Apple optimization: Get session duration
  Duration get sessionDuration {
    if (_sessionStartTime == null) return Duration.zero;
    return DateTime.now().difference(_sessionStartTime!);
  }
  
  /// Apple optimization: Get performance summary
  Map<String, dynamic> get performanceSummary {
    return {
      'session_duration_seconds': sessionDuration.inSeconds,
      'total_detections': _metrics['total_detections'] ?? 0,
      'average_latency_ms': _metrics['average_latency_ms'] ?? 0.0,
      'peak_latency_ms': _metrics['peak_latency_ms'] ?? 0.0,
      'average_memory_mb': _metrics['average_memory_mb'] ?? 0.0,
      'peak_memory_mb': _metrics['peak_memory_mb'] ?? 0.0,
      'average_cpu_percent': _metrics['average_cpu_percent'] ?? 0.0,
      'peak_cpu_percent': _metrics['peak_cpu_percent'] ?? 0.0,
      'detections_per_second': _metrics['detections_per_second'] ?? 0.0,
      'performance_score': _metrics['performance_score'] ?? 100.0,
      'optimization_level': _metrics['optimization_level'] ?? 'none',
      'total_alerts': _performanceAlerts.length,
    };
  }
  
  /// Apple optimization: Save performance data
  Future<bool> savePerformanceData() async {
    try {
      // Apple optimization: Save performance data to persistent storage
      // In real implementation, save to local storage or send to analytics
      final data = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'session_duration': sessionDuration.inSeconds,
        'performance_summary': performanceSummary,
        'optimization_settings': _optimizationSettings,
        'performance_alerts': _performanceAlerts,
      };
      
      // Apple optimization: Simulate saving (replace with actual implementation)
      print('Performance data saved: $data');
      return true;
      
    } catch (e) {
      _addPerformanceAlert('Error saving performance data: $e');
      return false;
    }
  }
  
  /// Apple optimization: Clear performance data
  void clearPerformanceData() {
    try {
      _latencyHistory.clear();
      _memoryHistory.clear();
      _cpuHistory.clear();
      _detectionHistory.clear();
      _performanceAlerts.clear();
      _optimizationSettings.clear();
      
      _isOptimized = false;
      _initializeMetrics();
      
    } catch (e) {
      _addPerformanceAlert('Error clearing performance data: $e');
    }
  }
  
  /// Apple optimization: Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    final performanceScore = _metrics['performance_score'] as double? ?? 100.0;
    
    if (performanceScore < 50.0) {
      recommendations.add('Critical performance issues detected. Consider restarting the app.');
    } else if (performanceScore < 70.0) {
      recommendations.add('Performance optimization is active to improve responsiveness.');
    } else if (performanceScore < 85.0) {
      recommendations.add('Consider reducing audio processing complexity for better performance.');
    } else {
      recommendations.add('Performance is optimal. No recommendations needed.');
    }
    
    return recommendations;
  }
  
  /// Apple optimization: Dispose resources
  void dispose() {
    try {
      stopMonitoring();
      savePerformanceData();
      
    } catch (e) {
      print('Error disposing performance monitor: $e');
    }
  }
} 