import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User Preferences
/// Apple-level optimized user preferences management for audio detection
/// Provides persistent storage and intelligent default settings
class UserPreferences {
  static const String _prefsKey = 'strike_audio_detection_preferences';
  static const String _sensitivityKey = 'user_sensitivity';
  static const String _enabledKey = 'audio_detection_enabled';
  static const String _autoCalibrationKey = 'auto_calibration_enabled';
  static const String _adaptiveThresholdsKey = 'adaptive_thresholds_enabled';
  static const String _performanceOptimizationKey = 'performance_optimization_enabled';
  static const String _hapticFeedbackKey = 'haptic_feedback_enabled';
  static const String _visualFeedbackKey = 'visual_feedback_enabled';
  static const String _powerOptimizationKey = 'power_optimization_enabled';
  static const String _strikeTypeKey = 'strike_type';
  static const String _lastCalibrationKey = 'last_calibration_time';
  static const String _usageStatsKey = 'usage_statistics';
  
  // Apple optimization: Default preferences
  static const Map<String, dynamic> _defaultPreferences = {
    'user_sensitivity': 1.0,
    'audio_detection_enabled': true,
    'auto_calibration_enabled': true,
    'adaptive_thresholds_enabled': true,
    'performance_optimization_enabled': true,
    'haptic_feedback_enabled': true,
    'visual_feedback_enabled': true,
    'power_optimization_enabled': true,
    'strike_type': 'general',
    'last_calibration_time': 0,
    'usage_statistics': {
      'total_sessions': 0,
      'total_detections': 0,
      'average_session_duration': 0,
      'last_used': 0,
      'preferred_strike_type': 'general',
    },
  };
  
  // Apple optimization: Shared preferences instance
  SharedPreferences? _prefs;
  
  /// Apple optimization: Initialize preferences
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      print('Failed to initialize SharedPreferences: $e');
    }
  }
  
  /// Apple optimization: Get all audio detection preferences
  Future<Map<String, dynamic>> getAudioDetectionPreferences() async {
    await _ensureInitialized();
    
    try {
      final prefsData = _prefs?.getString(_prefsKey);
      if (prefsData != null) {
        final savedPrefs = json.decode(prefsData) as Map<String, dynamic>;
        return _mergeWithDefaults(savedPrefs);
      }
      
      // Return defaults if no saved preferences
      return Map.from(_defaultPreferences);
      
    } catch (e) {
      print('Error loading preferences: $e');
      return Map.from(_defaultPreferences);
    }
  }
  
  /// Apple optimization: Save audio detection preferences
  Future<bool> saveAudioDetectionPreferences(Map<String, dynamic> preferences) async {
    await _ensureInitialized();
    
    try {
      // Apple optimization: Validate preferences before saving
      final validatedPrefs = _validatePreferences(preferences);
      
      // Apple optimization: Merge with existing preferences
      final currentPrefs = await getAudioDetectionPreferences();
      final mergedPrefs = {...currentPrefs, ...validatedPrefs};
      
      // Apple optimization: Save to SharedPreferences
      final prefsJson = json.encode(mergedPrefs);
      final success = await _prefs?.setString(_prefsKey, prefsJson) ?? false;
      
      if (success) {
        _updateUsageStatistics();
      }
      
      return success;
      
    } catch (e) {
      print('Error saving preferences: $e');
      return false;
    }
  }
  
  /// Apple optimization: Get user sensitivity
  Future<double> getUserSensitivity() async {
    final prefs = await getAudioDetectionPreferences();
    return (prefs[_sensitivityKey] as num?)?.toDouble() ?? 1.0;
  }
  
  /// Apple optimization: Save user sensitivity
  Future<bool> saveUserSensitivity(double sensitivity) async {
    return await saveAudioDetectionPreferences({
      _sensitivityKey: sensitivity.clamp(0.5, 2.0),
    });
  }
  
  /// Apple optimization: Get audio detection enabled state
  Future<bool> getAudioDetectionEnabled() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_enabledKey] as bool? ?? true;
  }
  
  /// Apple optimization: Save audio detection enabled state
  Future<bool> saveAudioDetectionEnabled(bool enabled) async {
    return await saveAudioDetectionPreferences({
      _enabledKey: enabled,
    });
  }
  
  /// Apple optimization: Get auto calibration enabled state
  Future<bool> getAutoCalibrationEnabled() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_autoCalibrationKey] as bool? ?? true;
  }
  
  /// Apple optimization: Save auto calibration enabled state
  Future<bool> saveAutoCalibrationEnabled(bool enabled) async {
    return await saveAudioDetectionPreferences({
      _autoCalibrationKey: enabled,
    });
  }
  
  /// Apple optimization: Get adaptive thresholds enabled state
  Future<bool> getAdaptiveThresholdsEnabled() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_adaptiveThresholdsKey] as bool? ?? true;
  }
  
  /// Apple optimization: Save adaptive thresholds enabled state
  Future<bool> saveAdaptiveThresholdsEnabled(bool enabled) async {
    return await saveAudioDetectionPreferences({
      _adaptiveThresholdsKey: enabled,
    });
  }
  
  /// Apple optimization: Get performance optimization enabled state
  Future<bool> getPerformanceOptimizationEnabled() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_performanceOptimizationKey] as bool? ?? true;
  }
  
  /// Apple optimization: Save performance optimization enabled state
  Future<bool> savePerformanceOptimizationEnabled(bool enabled) async {
    return await saveAudioDetectionPreferences({
      _performanceOptimizationKey: enabled,
    });
  }
  
  /// Apple optimization: Get haptic feedback enabled state
  Future<bool> getHapticFeedbackEnabled() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_hapticFeedbackKey] as bool? ?? true;
  }
  
  /// Apple optimization: Save haptic feedback enabled state
  Future<bool> saveHapticFeedbackEnabled(bool enabled) async {
    return await saveAudioDetectionPreferences({
      _hapticFeedbackKey: enabled,
    });
  }
  
  /// Apple optimization: Get visual feedback enabled state
  Future<bool> getVisualFeedbackEnabled() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_visualFeedbackKey] as bool? ?? true;
  }
  
  /// Apple optimization: Save visual feedback enabled state
  Future<bool> saveVisualFeedbackEnabled(bool enabled) async {
    return await saveAudioDetectionPreferences({
      _visualFeedbackKey: enabled,
    });
  }
  
  /// Apple optimization: Get power optimization enabled state
  Future<bool> getPowerOptimizationEnabled() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_powerOptimizationKey] as bool? ?? true;
  }
  
  /// Apple optimization: Save power optimization enabled state
  Future<bool> savePowerOptimizationEnabled(bool enabled) async {
    return await saveAudioDetectionPreferences({
      _powerOptimizationKey: enabled,
    });
  }
  
  /// Apple optimization: Get strike type preference
  Future<String> getStrikeType() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_strikeTypeKey] as String? ?? 'general';
  }
  
  /// Apple optimization: Save strike type preference
  Future<bool> saveStrikeType(String strikeType) async {
    return await saveAudioDetectionPreferences({
      _strikeTypeKey: strikeType,
    });
  }
  
  /// Apple optimization: Get last calibration time
  Future<int> getLastCalibrationTime() async {
    final prefs = await getAudioDetectionPreferences();
    return prefs[_lastCalibrationKey] as int? ?? 0;
  }
  
  /// Apple optimization: Save last calibration time
  Future<bool> saveLastCalibrationTime(int timestamp) async {
    return await saveAudioDetectionPreferences({
      _lastCalibrationKey: timestamp,
    });
  }
  
  /// Apple optimization: Get usage statistics
  Future<Map<String, dynamic>> getUsageStatistics() async {
    final prefs = await getAudioDetectionPreferences();
    final stats = prefs[_usageStatsKey] as Map<String, dynamic>?;
    return stats ?? _defaultPreferences[_usageStatsKey] as Map<String, dynamic>;
  }
  
  /// Apple optimization: Update usage statistics
  Future<bool> updateUsageStatistics({
    int? totalSessions,
    int? totalDetections,
    int? sessionDuration,
    String? preferredStrikeType,
  }) async {
    try {
      final currentStats = await getUsageStatistics();
      
      final updatedStats = <String, dynamic>{
        'total_sessions': (currentStats['total_sessions'] as int? ?? 0) + (totalSessions ?? 0),
        'total_detections': (currentStats['total_detections'] as int? ?? 0) + (totalDetections ?? 0),
        'average_session_duration': _calculateAverageSessionDuration(
          currentStats['average_session_duration'] as int? ?? 0,
          currentStats['total_sessions'] as int? ?? 0,
          sessionDuration ?? 0,
        ),
        'last_used': DateTime.now().millisecondsSinceEpoch,
        'preferred_strike_type': preferredStrikeType ?? currentStats['preferred_strike_type'] ?? 'general',
      };
      
      return await saveAudioDetectionPreferences({
        _usageStatsKey: updatedStats,
      });
      
    } catch (e) {
      print('Error updating usage statistics: $e');
      return false;
    }
  }
  
  /// Apple optimization: Calculate average session duration
  int _calculateAverageSessionDuration(int currentAverage, int totalSessions, int newDuration) {
    if (totalSessions == 0) return newDuration;
    
    final totalDuration = currentAverage * totalSessions + newDuration;
    return totalDuration ~/ (totalSessions + 1);
  }
  
  /// Apple optimization: Get recommended settings based on usage
  Future<Map<String, dynamic>> getRecommendedSettings() async {
    try {
      final usageStats = await getUsageStatistics();
      final totalSessions = usageStats['total_sessions'] as int? ?? 0;
      final preferredStrikeType = usageStats['preferred_strike_type'] as String? ?? 'general';
      
      // Apple optimization: Adaptive recommendations based on usage
      Map<String, dynamic> recommendations = {};
      
      if (totalSessions < 5) {
        // New user - conservative settings
        recommendations = {
          'user_sensitivity': 0.8,
          'auto_calibration_enabled': true,
          'adaptive_thresholds_enabled': true,
          'performance_optimization_enabled': true,
          'haptic_feedback_enabled': true,
          'visual_feedback_enabled': true,
          'power_optimization_enabled': true,
        };
      } else if (totalSessions < 20) {
        // Intermediate user - balanced settings
        recommendations = {
          'user_sensitivity': 1.0,
          'auto_calibration_enabled': true,
          'adaptive_thresholds_enabled': true,
          'performance_optimization_enabled': true,
          'haptic_feedback_enabled': true,
          'visual_feedback_enabled': false, // Reduce visual clutter
          'power_optimization_enabled': true,
        };
      } else {
        // Experienced user - optimized settings
        recommendations = {
          'user_sensitivity': 1.2,
          'auto_calibration_enabled': false, // Manual calibration preferred
          'adaptive_thresholds_enabled': true,
          'performance_optimization_enabled': true,
          'haptic_feedback_enabled': false, // Reduce haptic feedback
          'visual_feedback_enabled': false,
          'power_optimization_enabled': true,
        };
      }
      
      // Apple optimization: Adjust based on preferred strike type
      if (preferredStrikeType != 'general') {
        recommendations['strike_type'] = preferredStrikeType;
      }
      
      return recommendations;
      
    } catch (e) {
      print('Error getting recommended settings: $e');
      return {};
    }
  }
  
  /// Apple optimization: Apply recommended settings
  Future<bool> applyRecommendedSettings() async {
    try {
      final recommendations = await getRecommendedSettings();
      return await saveAudioDetectionPreferences(recommendations);
      
    } catch (e) {
      print('Error applying recommended settings: $e');
      return false;
    }
  }
  
  /// Apple optimization: Reset preferences to defaults
  Future<bool> resetToDefaults() async {
    try {
      final success = await _prefs?.remove(_prefsKey) ?? false;
      if (success) {
        // Apple optimization: Initialize with defaults
        await saveAudioDetectionPreferences(_defaultPreferences);
      }
      return success;
      
    } catch (e) {
      print('Error resetting preferences: $e');
      return false;
    }
  }
  
  /// Apple optimization: Export preferences for backup
  Future<String> exportPreferences() async {
    try {
      final prefs = await getAudioDetectionPreferences();
      return json.encode(prefs);
      
    } catch (e) {
      print('Error exporting preferences: $e');
      return '';
    }
  }
  
  /// Apple optimization: Import preferences from backup
  Future<bool> importPreferences(String prefsJson) async {
    try {
      final prefs = json.decode(prefsJson) as Map<String, dynamic>;
      final validatedPrefs = _validatePreferences(prefs);
      return await saveAudioDetectionPreferences(validatedPrefs);
      
    } catch (e) {
      print('Error importing preferences: $e');
      return false;
    }
  }
  
  /// Apple optimization: Ensure SharedPreferences is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
  
  /// Apple optimization: Merge saved preferences with defaults
  Map<String, dynamic> _mergeWithDefaults(Map<String, dynamic> savedPrefs) {
    final merged = Map<String, dynamic>.from(_defaultPreferences);
    
    for (final entry in savedPrefs.entries) {
      if (merged.containsKey(entry.key)) {
        merged[entry.key] = entry.value;
      }
    }
    
    return merged;
  }
  
  /// Apple optimization: Validate preferences before saving
  Map<String, dynamic> _validatePreferences(Map<String, dynamic> prefs) {
    final validated = <String, dynamic>{};
    
    // Apple optimization: Validate sensitivity
    if (prefs.containsKey(_sensitivityKey)) {
      final sensitivity = prefs[_sensitivityKey];
      if (sensitivity is num) {
        validated[_sensitivityKey] = sensitivity.clamp(0.5, 2.0);
      }
    }
    
    // Apple optimization: Validate boolean values
    final boolKeys = [
      _enabledKey, _autoCalibrationKey, _adaptiveThresholdsKey,
      _performanceOptimizationKey, _hapticFeedbackKey, _visualFeedbackKey,
      _powerOptimizationKey,
    ];
    
    for (final key in boolKeys) {
      if (prefs.containsKey(key)) {
        final value = prefs[key];
        if (value is bool) {
          validated[key] = value;
        }
      }
    }
    
    // Apple optimization: Validate strike type
    if (prefs.containsKey(_strikeTypeKey)) {
      final strikeType = prefs[_strikeTypeKey];
      if (strikeType is String && ['general', 'punchingBag', 'boxing', 'kickboxing'].contains(strikeType)) {
        validated[_strikeTypeKey] = strikeType;
      }
    }
    
    // Apple optimization: Validate timestamp
    if (prefs.containsKey(_lastCalibrationKey)) {
      final timestamp = prefs[_lastCalibrationKey];
      if (timestamp is int && timestamp >= 0) {
        validated[_lastCalibrationKey] = timestamp;
      }
    }
    
    return validated;
  }
  
  /// Apple optimization: Update usage statistics
  void _updateUsageStatistics() {
    // Apple optimization: Update last used timestamp
    updateUsageStatistics();
  }
} 