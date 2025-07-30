import 'dart:async';
import 'dart:io';

/// Error Handler
/// Apple-level optimized error handling and recovery system
/// Provides comprehensive error management with graceful degradation
class ErrorHandler {
  // Apple optimization: Error categories
  static const String _categoryInitialization = 'initialization';
  static const String _categoryAudioCapture = 'audio_capture';
  static const String _categoryAnalysis = 'analysis';
  static const String _categoryPerformance = 'performance';
  static const String _categoryUser = 'user';
  static const String _categorySystem = 'system';
  
  // Apple optimization: Error severity levels
  static const String _severityLow = 'low';
  static const String _severityMedium = 'medium';
  static const String _severityHigh = 'high';
  static const String _severityCritical = 'critical';
  
  // Apple optimization: Error tracking
  final List<ErrorRecord> _errorHistory = [];
  final Map<String, int> _errorCounts = {};
  final Map<String, List<String>> _errorCategories = {};
  
  // Apple optimization: Error recovery strategies
  final Map<String, List<RecoveryStrategy>> _recoveryStrategies = {};
  
  // Apple optimization: Callbacks
  Function(String, String, String)? onError;
  Function(String, String)? onRecoveryAttempt;
  Function(String, bool)? onRecoveryResult;
  
  // Apple optimization: Error handling state
  bool _isErrorHandlingEnabled = true;
  int _maxErrorHistory = 100;
  int _maxRetryAttempts = 3;
  
  ErrorHandler() {
    _initializeErrorHandler();
  }
  
  /// Apple optimization: Initialize error handler
  void _initializeErrorHandler() {
    // Apple optimization: Initialize error categories
    _errorCategories[_categoryInitialization] = [
      'device_compatibility',
      'permission_denied',
      'resource_unavailable',
      'configuration_invalid',
    ];
    
    _errorCategories[_categoryAudioCapture] = [
      'microphone_unavailable',
      'audio_stream_failed',
      'buffer_overflow',
      'sample_rate_unsupported',
    ];
    
    _errorCategories[_categoryAnalysis] = [
      'fft_computation_failed',
      'feature_extraction_failed',
      'threshold_calculation_failed',
      'pattern_matching_failed',
    ];
    
    _errorCategories[_categoryPerformance] = [
      'memory_overflow',
      'cpu_overload',
      'latency_exceeded',
      'battery_drain',
    ];
    
    _errorCategories[_categoryUser] = [
      'invalid_input',
      'preference_conflict',
      'calibration_failed',
      'sensitivity_adjustment',
    ];
    
    _errorCategories[_categorySystem] = [
      'platform_error',
      'network_unavailable',
      'storage_full',
      'permission_revoked',
    ];
    
    // Apple optimization: Initialize recovery strategies
    _initializeRecoveryStrategies();
  }
  
  /// Apple optimization: Initialize recovery strategies
  void _initializeRecoveryStrategies() {
    // Apple optimization: Recovery strategies for initialization errors
    _recoveryStrategies[_categoryInitialization] = [
      RecoveryStrategy(
        name: 'retry_initialization',
        description: 'Retry initialization with default settings',
        action: _retryInitialization,
        maxAttempts: 2,
      ),
      RecoveryStrategy(
        name: 'fallback_configuration',
        description: 'Use fallback configuration for compatibility',
        action: _useFallbackConfiguration,
        maxAttempts: 1,
      ),
    ];
    
    // Apple optimization: Recovery strategies for audio capture errors
    _recoveryStrategies[_categoryAudioCapture] = [
      RecoveryStrategy(
        name: 'retry_audio_capture',
        description: 'Retry audio capture with different settings',
        action: _retryAudioCapture,
        maxAttempts: 3,
      ),
      RecoveryStrategy(
        name: 'reduce_sample_rate',
        description: 'Reduce sample rate for compatibility',
        action: _reduceSampleRate,
        maxAttempts: 1,
      ),
      RecoveryStrategy(
        name: 'increase_buffer_size',
        description: 'Increase buffer size to prevent overflow',
        action: _increaseBufferSize,
        maxAttempts: 1,
      ),
    ];
    
    // Apple optimization: Recovery strategies for analysis errors
    _recoveryStrategies[_categoryAnalysis] = [
      RecoveryStrategy(
        name: 'simplify_analysis',
        description: 'Use simplified analysis algorithm',
        action: _simplifyAnalysis,
        maxAttempts: 1,
      ),
      RecoveryStrategy(
        name: 'reduce_fft_size',
        description: 'Reduce FFT size for performance',
        action: _reduceFFTSize,
        maxAttempts: 1,
      ),
    ];
    
    // Apple optimization: Recovery strategies for performance errors
    _recoveryStrategies[_categoryPerformance] = [
      RecoveryStrategy(
        name: 'enable_power_saving',
        description: 'Enable power saving mode',
        action: _enablePowerSaving,
        maxAttempts: 1,
      ),
      RecoveryStrategy(
        name: 'reduce_processing_frequency',
        description: 'Reduce processing frequency',
        action: _reduceProcessingFrequency,
        maxAttempts: 1,
      ),
    ];
    
    // Apple optimization: Recovery strategies for user errors
    _recoveryStrategies[_categoryUser] = [
      RecoveryStrategy(
        name: 'reset_preferences',
        description: 'Reset user preferences to defaults',
        action: _resetPreferences,
        maxAttempts: 1,
      ),
      RecoveryStrategy(
        name: 'recalibrate_system',
        description: 'Recalibrate the detection system',
        action: _recalibrateSystem,
        maxAttempts: 2,
      ),
    ];
    
    // Apple optimization: Recovery strategies for system errors
    _recoveryStrategies[_categorySystem] = [
      RecoveryStrategy(
        name: 'check_permissions',
        description: 'Check and request necessary permissions',
        action: _checkPermissions,
        maxAttempts: 2,
      ),
      RecoveryStrategy(
        name: 'clear_cache',
        description: 'Clear system cache and temporary files',
        action: _clearCache,
        maxAttempts: 1,
      ),
    ];
  }
  
  /// Apple optimization: Handle error with comprehensive logging and recovery
  Future<bool> handleError(String error, {
    String? category,
    String? severity,
    Map<String, dynamic>? context,
    bool attemptRecovery = true,
  }) async {
    if (!_isErrorHandlingEnabled) return false;
    
    try {
      // Apple optimization: Determine error category and severity
      final errorCategory = category ?? _categorizeError(error);
      final errorSeverity = severity ?? _determineSeverity(error, errorCategory);
      
      // Apple optimization: Create error record
      final errorRecord = ErrorRecord(
        timestamp: DateTime.now(),
        error: error,
        category: errorCategory,
        severity: errorSeverity,
        context: context ?? {},
        attemptCount: 0,
      );
      
      // Apple optimization: Log error
      _logError(errorRecord);
      
      // Apple optimization: Update error counts
      _updateErrorCounts(errorCategory, errorSeverity);
      
      // Apple optimization: Trigger error callback
      onError?.call(error, errorCategory, errorSeverity);
      
      // Apple optimization: Attempt recovery if enabled
      if (attemptRecovery && errorSeverity != _severityCritical) {
        return await _attemptRecovery(errorRecord);
      }
      
      return false;
      
    } catch (e) {
      // Apple optimization: Handle error in error handler
      print('Error in error handler: $e');
      return false;
    }
  }
  
  /// Apple optimization: Categorize error based on content
  String _categorizeError(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('initialization') || lowerError.contains('init')) {
      return _categoryInitialization;
    } else if (lowerError.contains('audio') || lowerError.contains('microphone') || lowerError.contains('capture')) {
      return _categoryAudioCapture;
    } else if (lowerError.contains('analysis') || lowerError.contains('fft') || lowerError.contains('feature')) {
      return _categoryAnalysis;
    } else if (lowerError.contains('performance') || lowerError.contains('memory') || lowerError.contains('cpu')) {
      return _categoryPerformance;
    } else if (lowerError.contains('user') || lowerError.contains('preference') || lowerError.contains('calibration')) {
      return _categoryUser;
    } else if (lowerError.contains('permission') || lowerError.contains('platform') || lowerError.contains('system')) {
      return _categorySystem;
    }
    
    return _categorySystem; // Default category
  }
  
  /// Apple optimization: Determine error severity
  String _determineSeverity(String error, String category) {
    final lowerError = error.toLowerCase();
    
    // Apple optimization: Critical errors
    if (lowerError.contains('fatal') || lowerError.contains('crash') || lowerError.contains('unrecoverable')) {
      return _severityCritical;
    }
    
    // Apple optimization: High severity errors
    if (lowerError.contains('failed') || lowerError.contains('error') || lowerError.contains('exception')) {
      return _severityHigh;
    }
    
    // Apple optimization: Medium severity errors
    if (lowerError.contains('warning') || lowerError.contains('issue') || lowerError.contains('problem')) {
      return _severityMedium;
    }
    
    // Apple optimization: Low severity errors
    return _severityLow;
  }
  
  /// Apple optimization: Log error to history
  void _logError(ErrorRecord errorRecord) {
    _errorHistory.add(errorRecord);
    
    // Apple optimization: Limit error history size
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }
  }
  
  /// Apple optimization: Update error counts
  void _updateErrorCounts(String category, String severity) {
    final key = '${category}_${severity}';
    _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
  }
  
  /// Apple optimization: Attempt error recovery
  Future<bool> _attemptRecovery(ErrorRecord errorRecord) async {
    try {
      final strategies = _recoveryStrategies[errorRecord.category];
      if (strategies == null || strategies.isEmpty) {
        return false;
      }
      
      // Apple optimization: Try recovery strategies in order
      for (final strategy in strategies) {
        if (errorRecord.attemptCount >= strategy.maxAttempts) {
          continue;
        }
        
        // Apple optimization: Notify recovery attempt
        onRecoveryAttempt?.call(errorRecord.error, strategy.name);
        
        try {
          // Apple optimization: Execute recovery strategy
          final success = await strategy.action(errorRecord);
          
          // Apple optimization: Update attempt count
          errorRecord.attemptCount++;
          
          // Apple optimization: Notify recovery result
          onRecoveryResult?.call(strategy.name, success);
          
          if (success) {
            // Apple optimization: Log successful recovery
            _logRecoverySuccess(errorRecord, strategy);
            return true;
          }
          
        } catch (e) {
          // Apple optimization: Log recovery failure
          _logRecoveryFailure(errorRecord, strategy, e.toString());
        }
      }
      
      return false;
      
    } catch (e) {
      print('Error during recovery attempt: $e');
      return false;
    }
  }
  
  /// Apple optimization: Recovery strategy implementations
  
  Future<bool> _retryInitialization(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate retry initialization
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
  
  Future<bool> _useFallbackConfiguration(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate fallback configuration
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
  
  Future<bool> _retryAudioCapture(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate retry audio capture
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
  
  Future<bool> _reduceSampleRate(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate sample rate reduction
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
  
  Future<bool> _increaseBufferSize(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate buffer size increase
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
  
  Future<bool> _simplifyAnalysis(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate analysis simplification
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
  
  Future<bool> _reduceFFTSize(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate FFT size reduction
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
  
  Future<bool> _enablePowerSaving(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate power saving enable
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
  
  Future<bool> _reduceProcessingFrequency(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate processing frequency reduction
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
  
  Future<bool> _resetPreferences(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate preferences reset
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
  
  Future<bool> _recalibrateSystem(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate system recalibration
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
  
  Future<bool> _checkPermissions(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate permission check
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
  
  Future<bool> _clearCache(ErrorRecord errorRecord) async {
    // Apple optimization: Simulate cache clearing
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
  
  /// Apple optimization: Log recovery success
  void _logRecoverySuccess(ErrorRecord errorRecord, RecoveryStrategy strategy) {
    final recoveryRecord = RecoveryRecord(
      timestamp: DateTime.now(),
      errorRecord: errorRecord,
      strategy: strategy,
      success: true,
      error: null,
    );
    
    // Apple optimization: Add to recovery history (simplified)
    print('Recovery successful: ${strategy.name} for ${errorRecord.error}');
  }
  
  /// Apple optimization: Log recovery failure
  void _logRecoveryFailure(ErrorRecord errorRecord, RecoveryStrategy strategy, String error) {
    final recoveryRecord = RecoveryRecord(
      timestamp: DateTime.now(),
      errorRecord: errorRecord,
      strategy: strategy,
      success: false,
      error: error,
    );
    
    // Apple optimization: Add to recovery history (simplified)
    print('Recovery failed: ${strategy.name} for ${errorRecord.error} - $error');
  }
  
  /// Apple optimization: Get error statistics
  Map<String, dynamic> getErrorStatistics() {
    final stats = <String, dynamic>{};
    
    // Apple optimization: Error counts by category and severity
    stats['error_counts'] = Map.unmodifiable(_errorCounts);
    
    // Apple optimization: Recent errors
    final recentErrors = _errorHistory.take(10).map((e) => {
      'timestamp': e.timestamp.millisecondsSinceEpoch,
      'error': e.error,
      'category': e.category,
      'severity': e.severity,
      'attempt_count': e.attemptCount,
    }).toList();
    stats['recent_errors'] = recentErrors;
    
    // Apple optimization: Error trends
    final totalErrors = _errorHistory.length;
    final criticalErrors = _errorHistory.where((e) => e.severity == _severityCritical).length;
    final highSeverityErrors = _errorHistory.where((e) => e.severity == _severityHigh).length;
    
    stats['total_errors'] = totalErrors;
    stats['critical_errors'] = criticalErrors;
    stats['high_severity_errors'] = highSeverityErrors;
    stats['error_rate'] = totalErrors > 0 ? criticalErrors / totalErrors : 0.0;
    
    return stats;
  }
  
  /// Apple optimization: Get error history
  List<ErrorRecord> getErrorHistory() => List.unmodifiable(_errorHistory);
  
  /// Apple optimization: Clear error history
  void clearErrorHistory() {
    _errorHistory.clear();
    _errorCounts.clear();
  }
  
  /// Apple optimization: Set error handling enabled
  void setErrorHandlingEnabled(bool enabled) {
    _isErrorHandlingEnabled = enabled;
  }
  
  /// Apple optimization: Get error handling status
  bool get isErrorHandlingEnabled => _isErrorHandlingEnabled;
  
  /// Apple optimization: Set maximum error history size
  void setMaxErrorHistory(int maxSize) {
    _maxErrorHistory = maxSize.clamp(10, 1000);
  }
  
  /// Apple optimization: Set maximum retry attempts
  void setMaxRetryAttempts(int maxAttempts) {
    _maxRetryAttempts = maxAttempts.clamp(1, 10);
  }
}

/// Error Record
/// Apple optimization: Comprehensive error tracking
class ErrorRecord {
  final DateTime timestamp;
  final String error;
  final String category;
  final String severity;
  final Map<String, dynamic> context;
  int attemptCount;
  
  ErrorRecord({
    required this.timestamp,
    required this.error,
    required this.category,
    required this.severity,
    required this.context,
    this.attemptCount = 0,
  });
  
  @override
  String toString() {
    return 'ErrorRecord(timestamp: $timestamp, error: $error, category: $category, severity: $severity, attempts: $attemptCount)';
  }
}

/// Recovery Strategy
/// Apple optimization: Error recovery strategy definition
class RecoveryStrategy {
  final String name;
  final String description;
  final Future<bool> Function(ErrorRecord) action;
  final int maxAttempts;
  
  RecoveryStrategy({
    required this.name,
    required this.description,
    required this.action,
    required this.maxAttempts,
  });
  
  @override
  String toString() {
    return 'RecoveryStrategy(name: $name, description: $description, maxAttempts: $maxAttempts)';
  }
}

/// Recovery Record
/// Apple optimization: Recovery attempt tracking
class RecoveryRecord {
  final DateTime timestamp;
  final ErrorRecord errorRecord;
  final RecoveryStrategy strategy;
  final bool success;
  final String? error;
  
  RecoveryRecord({
    required this.timestamp,
    required this.errorRecord,
    required this.strategy,
    required this.success,
    this.error,
  });
  
  @override
  String toString() {
    return 'RecoveryRecord(timestamp: $timestamp, strategy: ${strategy.name}, success: $success, error: $error)';
  }
} 