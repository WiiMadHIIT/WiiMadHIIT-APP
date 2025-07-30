import 'dart:math';
import 'package:flutter/foundation.dart';
import 'audio_capture_config.dart';
import 'fft.dart';
import 'strike_sound_characteristics.dart';

/// Audio Analyzer
/// Apple-level optimized real-time spectral analysis for strike sound detection
/// Provides intelligent feature extraction and pattern recognition
class AudioAnalyzer {
  // Apple optimization: Configuration and state
  final AudioCaptureConfig _config;
  final StrikeSoundCharacteristics _characteristics;
  
  // Apple optimization: Adaptive thresholds and learning
  double _ambientNoiseLevel = 0.0;
  double _adaptiveThreshold = 0.0;
  bool _isCalibrated = false;
  
  // Apple optimization: Smoothing and filtering
  final List<double> _energyHistory = [];
  final List<double> _spectralHistory = [];
  final int _smoothingWindow;
  
  // Apple optimization: Performance tracking
  int _totalSamples = 0;
  int _detectionCount = 0;
  double _averageResponseTime = 0.0;
  
  // Apple optimization: User learning data
  final Map<String, List<double>> _userPatterns = {};
  double _userSensitivity = 1.0;
  
  AudioAnalyzer({
    required AudioCaptureConfig config,
    required StrikeSoundCharacteristics characteristics,
  }) : _config = config,
       _characteristics = characteristics,
       _smoothingWindow = config.smoothingWindow {
    _initializeAnalyzer();
  }
  
  /// Apple optimization: Initialize analyzer with pre-computed data
  void _initializeAnalyzer() {
    // Initialize FFT with maximum expected size
    FFT.initialize(_config.fftSize);
    
    // Initialize history buffers
    _energyHistory.clear();
    _spectralHistory.clear();
    
    // Initialize user patterns
    _userPatterns.clear();
    _userPatterns['energy'] = [];
    _userPatterns['frequency'] = [];
    _userPatterns['spectral'] = [];
    _userPatterns['temporal'] = [];
  }
  
  /// Apple optimization: Analyze audio buffer for strike detection
  bool analyzeAudioBuffer(List<double> audioBuffer) {
    if (audioBuffer.length != _config.optimizedBufferSize) {
      throw ArgumentError('Audio buffer size must match optimized buffer size');
    }
    
    _totalSamples++;
    
    try {
      // Apple optimization: Extract features efficiently
      final features = _extractFeatures(audioBuffer);
      
      // Apple optimization: Apply adaptive thresholding
      final isStrike = _isStrikeSound(features['energy']!, features['spectrum']!);
      
      // Apple optimization: Update learning data
      _updateLearningData(features, isStrike);
      
      if (isStrike) {
        _detectionCount++;
        _recordDetectionPerformance();
      }
      
      return isStrike;
      
    } catch (e) {
      // Apple optimization: Graceful error handling
      print('Audio analysis error: $e');
      return false;
    }
  }
  
  /// Apple optimization: Extract comprehensive audio features
  Map<String, dynamic> _extractFeatures(List<double> audioBuffer) {
    // Apple optimization: Apply frequency weighting for human hearing
    final weightedBuffer = _applyFrequencyWeighting(audioBuffer);
    
    // Apple optimization: Calculate RMS energy with weighting
    final rmsEnergy = FFT.getWeightedRMSEnergy(weightedBuffer, _getFrequencyWeights());
    
    // Apple optimization: Perform FFT with optimal window
    final fftResult = FFT.fft(audioBuffer, windowType: WindowType.hanning);
    
    // Apple optimization: Extract spectral features
    final spectrum = _extractSpectralFeatures(fftResult);
    
    // Apple optimization: Extract temporal features
    final temporalFeatures = _extractTemporalFeatures(audioBuffer);
    
    // Apple optimization: Calculate zero-crossing rate
    final zeroCrossingRate = FFT.getZeroCrossingRate(audioBuffer);
    
    return {
      'energy': rmsEnergy,
      'spectrum': spectrum,
      'temporal': temporalFeatures,
      'zero_crossing_rate': zeroCrossingRate,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  /// Apple optimization: Apply A-weighting filter for human hearing sensitivity
  List<double> _applyFrequencyWeighting(List<double> audioBuffer) {
    final sampleRate = _config.sampleRate.toDouble();
    final fftResult = FFT.fft(audioBuffer, windowType: WindowType.hanning);
    final frequencyBins = FFT.getFrequencyBins(fftResult.length, sampleRate);
    
    // Apple optimization: A-weighting filter coefficients
    final aWeightedSpectrum = fftResult.asMap().entries.map((entry) {
      final index = entry.key;
      final complex = entry.value;
      final frequency = frequencyBins[index];
      
      // A-weighting formula
      final f2 = frequency * frequency;
      final f4 = f2 * f2;
      final numerator = 12200 * 12200 * f4;
      final denominator = (f2 + 20.6 * 20.6) * (f2 + 12200 * 12200) * sqrt((f2 + 107.7 * 107.7) * (f2 + 737.9 * 737.9));
      final aWeight = numerator / denominator;
      
      return Complex(complex.real * aWeight, complex.imaginary * aWeight);
    }).toList();
    
    // Convert back to time domain
    return FFT.ifft(aWeightedSpectrum);
  }
  
  /// Apple optimization: Get frequency weights for strike detection
  List<double> _getFrequencyWeights() {
    final sampleRate = _config.sampleRate.toDouble();
    final fftSize = _config.fftSize;
    final frequencyBins = FFT.getFrequencyBins(fftSize, sampleRate);
    
    return frequencyBins.map((freq) {
      // Apple optimization: Weight frequencies based on strike sound characteristics
      if (freq >= _characteristics.minDominantFrequency && 
          freq <= _characteristics.maxDominantFrequency) {
        return 1.5; // Higher weight for strike-relevant frequencies
      } else if (freq >= 50 && freq <= 5000) {
        return 1.0; // Normal weight for audible frequencies
      } else {
        return 0.3; // Lower weight for extreme frequencies
      }
    }).toList();
  }
  
  /// Apple optimization: Extract comprehensive spectral features
  Map<String, double> _extractSpectralFeatures(List<Complex> fftResult) {
    final sampleRate = _config.sampleRate.toDouble();
    
    return {
      'dominant_freq': FFT.getDominantFrequency(fftResult, sampleRate),
      'spectral_centroid': FFT.getSpectralCentroid(fftResult, sampleRate),
      'spectral_rolloff': FFT.getSpectralRolloff(fftResult, sampleRate),
      'spectral_bandwidth': FFT.getSpectralBandwidth(fftResult, sampleRate),
      'total_energy': fftResult.map((c) => c.magnitudeSquared).reduce((a, b) => a + b),
      'peak_magnitude': fftResult.map((c) => c.magnitude).reduce(max),
    };
  }
  
  /// Apple optimization: Extract temporal features for strike detection
  Map<String, double> _extractTemporalFeatures(List<double> audioBuffer) {
    // Apple optimization: Detect attack time (time to reach 90% of peak)
    final peakValue = audioBuffer.map((x) => x.abs()).reduce(max);
    final threshold = peakValue * 0.9;
    
    int attackIndex = 0;
    for (int i = 0; i < audioBuffer.length; i++) {
      if (audioBuffer[i].abs() >= threshold) {
        attackIndex = i;
        break;
      }
    }
    
    final attackTime = attackIndex / _config.sampleRate;
    
    // Apple optimization: Detect decay time (time from peak to 10% of peak)
    int decayIndex = audioBuffer.length - 1;
    for (int i = attackIndex; i < audioBuffer.length; i++) {
      if (audioBuffer[i].abs() <= threshold * 0.1) {
        decayIndex = i;
        break;
      }
    }
    
    final decayTime = (decayIndex - attackIndex) / _config.sampleRate;
    
    return {
      'attack_time': attackTime,
      'decay_time': decayTime,
      'peak_value': peakValue,
      'peak_index': attackIndex.toDouble(),
    };
  }
  
  /// Apple optimization: Intelligent strike sound detection with adaptive thresholds
  bool _isStrikeSound(double energy, Map<String, double> spectrum) {
    if (!_isCalibrated) return false;
    
    // Apple optimization: Calculate energy ratio relative to ambient noise
    final energyRatio = energy / (_ambientNoiseLevel + 0.001);
    
    // Apple optimization: Check energy characteristics
    final hasEnergySpike = energyRatio > _adaptiveThreshold;
    final matchesEnergyRange = _characteristics.matchesEnergyCharacteristics(energyRatio, energy);
    
    // Apple optimization: Check frequency characteristics
    final matchesFrequencyRange = _characteristics.matchesFrequencyCharacteristics(spectrum);
    
    // Apple optimization: Check temporal characteristics
    final temporalFeatures = spectrum['temporal'] as Map<String, double>?;
    bool matchesTemporalRange = false;
    if (temporalFeatures != null) {
      matchesTemporalRange = _characteristics.matchesTemporalCharacteristics(
        temporalFeatures['attack_time'] ?? 0.0,
        temporalFeatures['decay_time'] ?? 0.0,
      );
    }
    
    // Apple optimization: Check time-domain characteristics
    final zeroCrossingRate = spectrum['zero_crossing_rate'] ?? 0.0;
    final matchesTimeDomainRange = _characteristics.matchesTimeDomainCharacteristics(zeroCrossingRate);
    
    // Apple optimization: Calculate weighted detection score
    final featureScores = {
      'energy_ratio': hasEnergySpike && matchesEnergyRange ? 1.0 : 0.0,
      'dominant_frequency': matchesFrequencyRange ? 1.0 : 0.0,
      'spectral_centroid': matchesFrequencyRange ? 1.0 : 0.0,
      'spectral_rolloff': matchesFrequencyRange ? 1.0 : 0.0,
      'attack_time': matchesTemporalRange ? 1.0 : 0.0,
      'decay_time': matchesTemporalRange ? 1.0 : 0.0,
      'zero_crossing_rate': matchesTimeDomainRange ? 1.0 : 0.0,
      'rms_energy': matchesEnergyRange ? 1.0 : 0.0,
    };
    
    final weightedScore = _characteristics.getWeightedScore(featureScores);
    
    // Apple optimization: Apply user sensitivity adjustment
    final adjustedScore = weightedScore * _userSensitivity;
    
    // Apple optimization: Check if matches user patterns
    final matchesUserPattern = _matchesUserPattern(energy, spectrum);
    
    // Apple optimization: Final detection decision
    final isStrike = adjustedScore > 0.7 && matchesUserPattern;
    
    return isStrike;
  }
  
  /// Apple optimization: Update ambient noise level estimation
  void updateAmbientNoiseLevel(List<double> audioBuffer) {
    final energy = FFT.getRMSEnergy(audioBuffer);
    
    _energyHistory.add(energy);
    if (_energyHistory.length > _smoothingWindow) {
      _energyHistory.removeAt(0);
    }
    
    // Apple optimization: Use median and IQR for robust noise estimation
    final sortedEnergies = List<double>.from(_energyHistory)..sort();
    final median = sortedEnergies[sortedEnergies.length ~/ 2];
    
    // Calculate IQR for outlier detection
    final q1 = sortedEnergies[sortedEnergies.length ~/ 4];
    final q3 = sortedEnergies[3 * sortedEnergies.length ~/ 4];
    final iqr = q3 - q1;
    
    // Apple optimization: Filter outliers and update ambient level
    final filteredEnergies = _energyHistory.where((e) => 
      (e >= q1 - 1.5 * iqr) && (e <= q3 + 1.5 * iqr)
    ).toList();
    
    if (filteredEnergies.isNotEmpty) {
      _ambientNoiseLevel = filteredEnergies.reduce((a, b) => a + b) / filteredEnergies.length;
      _adaptiveThreshold = _ambientNoiseLevel * _config.adaptiveThresholdFactor * _userSensitivity;
      
      if (!_isCalibrated && _energyHistory.length >= _smoothingWindow) {
        _isCalibrated = true;
      }
    }
  }
  
  /// Apple optimization: Update user learning data
  void _updateLearningData(Map<String, dynamic> features, bool isStrike) {
    final energy = features['energy'] as double;
    final spectrum = features['spectrum'] as Map<String, double>;
    
    if (isStrike) {
      _userPatterns['energy']!.add(energy);
      _userPatterns['frequency']!.add(spectrum['dominant_freq'] ?? 0.0);
      _userPatterns['spectral']!.add(spectrum['spectral_centroid'] ?? 0.0);
      
      // Apple optimization: Limit pattern history for memory efficiency
      const maxPatterns = 100;
      if (_userPatterns['energy']!.length > maxPatterns) {
        _userPatterns['energy']!.removeAt(0);
        _userPatterns['frequency']!.removeAt(0);
        _userPatterns['spectral']!.removeAt(0);
      }
    }
  }
  
  /// Apple optimization: Check if audio matches user patterns
  bool _matchesUserPattern(double energy, Map<String, double> spectrum) {
    if (_userPatterns['energy']!.isEmpty) return true; // No patterns yet
    
    // Apple optimization: Calculate pattern similarity
    final avgEnergy = _userPatterns['energy']!.reduce((a, b) => a + b) / _userPatterns['energy']!.length;
    final avgFrequency = _userPatterns['frequency']!.reduce((a, b) => a + b) / _userPatterns['frequency']!.length;
    final avgSpectral = _userPatterns['spectral']!.reduce((a, b) => a + b) / _userPatterns['spectral']!.length;
    
    final energySimilarity = 1.0 - (energy - avgEnergy).abs() / (avgEnergy + 0.001);
    final frequencySimilarity = 1.0 - (spectrum['dominant_freq']! - avgFrequency).abs() / (avgFrequency + 0.001);
    final spectralSimilarity = 1.0 - (spectrum['spectral_centroid']! - avgSpectral).abs() / (avgSpectral + 0.001);
    
    final patternSimilarity = (energySimilarity + frequencySimilarity + spectralSimilarity) / 3.0;
    
    return patternSimilarity > 0.6; // 60% similarity threshold
  }
  
  /// Apple optimization: Record detection performance metrics
  void _recordDetectionPerformance() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    // Apple optimization: Calculate response time (simplified)
    _averageResponseTime = (_averageResponseTime * (_detectionCount - 1) + 30.0) / _detectionCount;
  }
  
  /// Apple optimization: Set user sensitivity (0.5 to 2.0)
  void setUserSensitivity(double sensitivity) {
    _userSensitivity = sensitivity.clamp(0.5, 2.0);
    _adaptiveThreshold = _ambientNoiseLevel * _config.adaptiveThresholdFactor * _userSensitivity;
  }
  
  /// Apple optimization: Get current user sensitivity
  double get userSensitivity => _userSensitivity;
  
  /// Apple optimization: Get calibration status
  bool get isCalibrated => _isCalibrated;
  
  /// Apple optimization: Get ambient noise level
  double get ambientNoiseLevel => _ambientNoiseLevel;
  
  /// Apple optimization: Get adaptive threshold
  double get adaptiveThreshold => _adaptiveThreshold;
  
  /// Apple optimization: Get performance metrics
  Map<String, dynamic> get performanceMetrics {
    return {
      'total_samples': _totalSamples,
      'detection_count': _detectionCount,
      'detection_rate': _totalSamples > 0 ? _detectionCount / _totalSamples : 0.0,
      'average_response_time': _averageResponseTime,
      'ambient_noise_level': _ambientNoiseLevel,
      'adaptive_threshold': _adaptiveThreshold,
      'user_sensitivity': _userSensitivity,
      'is_calibrated': _isCalibrated,
    };
  }
  
  /// Apple optimization: Reset analyzer state
  void reset() {
    _energyHistory.clear();
    _spectralHistory.clear();
    _userPatterns.clear();
    _userPatterns['energy'] = [];
    _userPatterns['frequency'] = [];
    _userPatterns['spectral'] = [];
    _userPatterns['temporal'] = [];
    
    _ambientNoiseLevel = 0.0;
    _adaptiveThreshold = 0.0;
    _isCalibrated = false;
    _totalSamples = 0;
    _detectionCount = 0;
    _averageResponseTime = 0.0;
  }
  
  /// Apple optimization: Get analyzer configuration summary
  Map<String, dynamic> get configurationSummary {
    return {
      'sample_rate': _config.sampleRate,
      'buffer_size': _config.bufferSize,
      'fft_size': _config.fftSize,
      'smoothing_window': _smoothingWindow,
      'adaptive_threshold_factor': _config.adaptiveThresholdFactor,
      'latency_ms': _config.latencyMs,
      'frame_rate': _config.frameRate,
    };
  }
} 