/// Strike Sound Characteristics
/// Apple-level optimized feature library for strike sound identification
/// Based on physical acoustic properties rather than pre-trained models
class StrikeSoundCharacteristics {
  // Energy characteristics
  final double minEnergyRatio;
  final double maxEnergyRatio;
  final double energySpikeThreshold;
  
  // Frequency characteristics
  final double minDominantFrequency;
  final double maxDominantFrequency;
  final double minSpectralCentroid;
  final double maxSpectralCentroid;
  final double minSpectralRolloff;
  final double maxSpectralRolloff;
  final double minSpectralBandwidth;
  final double maxSpectralBandwidth;
  
  // Temporal characteristics
  final double minAttackTime;
  final double maxAttackTime;
  final double minDecayTime;
  final double maxDecayTime;
  
  // Time-domain characteristics
  final double minZeroCrossingRate;
  final double maxZeroCrossingRate;
  final double minRMSEnergy;
  final double maxRMSEnergy;
  
  // Apple optimization: Weighted feature importance
  final Map<String, double> featureWeights;
  
  const StrikeSoundCharacteristics({
    // Energy characteristics for strike detection
    this.minEnergyRatio = 2.0,
    this.maxEnergyRatio = 50.0,
    this.energySpikeThreshold = 3.0,
    
    // Frequency range for typical strike sounds (punching bag, boxing, etc.)
    this.minDominantFrequency = 100.0,   // Hz
    this.maxDominantFrequency = 2000.0,  // Hz
    this.minSpectralCentroid = 500.0,    // Hz
    this.maxSpectralCentroid = 3000.0,   // Hz
    this.minSpectralRolloff = 800.0,     // Hz
    this.maxSpectralRolloff = 4000.0,    // Hz
    this.minSpectralBandwidth = 200.0,   // Hz
    this.maxSpectralBandwidth = 2500.0,  // Hz
    
    // Temporal characteristics for rapid strike sounds
    this.minAttackTime = 0.001,          // seconds
    this.maxAttackTime = 0.05,           // seconds
    this.minDecayTime = 0.05,            // seconds
    this.maxDecayTime = 0.5,             // seconds
    
    // Time-domain characteristics
    this.minZeroCrossingRate = 0.05,
    this.maxZeroCrossingRate = 0.6,
    this.minRMSEnergy = 0.01,
    this.maxRMSEnergy = 1.0,
    
    // Apple optimization: Feature importance weights
    this.featureWeights = const {
      'energy_ratio': 0.25,
      'dominant_frequency': 0.15,
      'spectral_centroid': 0.15,
      'spectral_rolloff': 0.10,
      'attack_time': 0.15,
      'decay_time': 0.10,
      'zero_crossing_rate': 0.05,
      'rms_energy': 0.05,
    },
  });
  
  /// Apple optimization: Create characteristics for different strike types
  factory StrikeSoundCharacteristics.forStrikeType(StrikeType type) {
    switch (type) {
      case StrikeType.punchingBag:
        return const StrikeSoundCharacteristics(
          minDominantFrequency: 150.0,
          maxDominantFrequency: 1500.0,
          minSpectralCentroid: 600.0,
          maxSpectralCentroid: 2500.0,
          minAttackTime: 0.002,
          maxAttackTime: 0.03,
          minDecayTime: 0.08,
          maxDecayTime: 0.4,
          featureWeights: {
            'energy_ratio': 0.30,
            'dominant_frequency': 0.20,
            'spectral_centroid': 0.15,
            'spectral_rolloff': 0.10,
            'attack_time': 0.15,
            'decay_time': 0.05,
            'zero_crossing_rate': 0.03,
            'rms_energy': 0.02,
          },
        );
        
      case StrikeType.boxing:
        return const StrikeSoundCharacteristics(
          minDominantFrequency: 200.0,
          maxDominantFrequency: 1800.0,
          minSpectralCentroid: 700.0,
          maxSpectralCentroid: 2800.0,
          minAttackTime: 0.001,
          maxAttackTime: 0.02,
          minDecayTime: 0.05,
          maxDecayTime: 0.3,
          featureWeights: {
            'energy_ratio': 0.35,
            'dominant_frequency': 0.15,
            'spectral_centroid': 0.15,
            'spectral_rolloff': 0.10,
            'attack_time': 0.20,
            'decay_time': 0.03,
            'zero_crossing_rate': 0.01,
            'rms_energy': 0.01,
          },
        );
        
      case StrikeType.kickboxing:
        return const StrikeSoundCharacteristics(
          minDominantFrequency: 80.0,
          maxDominantFrequency: 1200.0,
          minSpectralCentroid: 400.0,
          maxSpectralCentroid: 2000.0,
          minAttackTime: 0.003,
          maxAttackTime: 0.04,
          minDecayTime: 0.1,
          maxDecayTime: 0.6,
          featureWeights: {
            'energy_ratio': 0.25,
            'dominant_frequency': 0.20,
            'spectral_centroid': 0.15,
            'spectral_rolloff': 0.15,
            'attack_time': 0.10,
            'decay_time': 0.10,
            'zero_crossing_rate': 0.03,
            'rms_energy': 0.02,
          },
        );
        
      case StrikeType.general:
      default:
        return const StrikeSoundCharacteristics();
    }
  }
  
  /// Apple optimization: Create adaptive characteristics based on environment
  factory StrikeSoundCharacteristics.adaptive({
    required double ambientNoiseLevel,
    required double roomReverb,
    required bool isOutdoor,
  }) {
    double noiseAdjustment = 1.0;
    if (ambientNoiseLevel > 0.5) {
      noiseAdjustment = 1.5; // Increase thresholds in noisy environments
    }
    
    double reverbAdjustment = 1.0;
    if (roomReverb > 0.3) {
      reverbAdjustment = 1.2; // Adjust for room acoustics
    }
    
    return StrikeSoundCharacteristics(
      minEnergyRatio: 2.0 * noiseAdjustment,
      maxEnergyRatio: 50.0 * noiseAdjustment,
      energySpikeThreshold: 3.0 * noiseAdjustment,
      
      // Adjust frequency ranges based on environment
      minDominantFrequency: isOutdoor ? 120.0 : 100.0,
      maxDominantFrequency: isOutdoor ? 1800.0 : 2000.0,
      
      // Adjust temporal characteristics based on reverb
      minAttackTime: 0.001 * reverbAdjustment,
      maxAttackTime: 0.05 * reverbAdjustment,
      minDecayTime: 0.05 * reverbAdjustment,
      maxDecayTime: 0.5 * reverbAdjustment,
    );
  }
  
  /// Apple optimization: Validate characteristics
  bool get isValid {
    return minEnergyRatio > 0 &&
           maxEnergyRatio > minEnergyRatio &&
           energySpikeThreshold > 0 &&
           minDominantFrequency > 0 &&
           maxDominantFrequency > minDominantFrequency &&
           minSpectralCentroid > 0 &&
           maxSpectralCentroid > minSpectralCentroid &&
           minSpectralRolloff > 0 &&
           maxSpectralRolloff > minSpectralRolloff &&
           minSpectralBandwidth > 0 &&
           maxSpectralBandwidth > minSpectralBandwidth &&
           minAttackTime > 0 &&
           maxAttackTime > minAttackTime &&
           minDecayTime > 0 &&
           maxDecayTime > minDecayTime &&
           minZeroCrossingRate >= 0 &&
           maxZeroCrossingRate > minZeroCrossingRate &&
           minRMSEnergy > 0 &&
           maxRMSEnergy > minRMSEnergy &&
           featureWeights.values.every((weight) => weight >= 0 && weight <= 1);
  }
  
  /// Apple optimization: Get weighted feature score
  double getWeightedScore(Map<String, double> featureScores) {
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    for (final entry in featureWeights.entries) {
      final featureName = entry.key;
      final weight = entry.value;
      
      if (featureScores.containsKey(featureName)) {
        totalScore += featureScores[featureName]! * weight;
        totalWeight += weight;
      }
    }
    
    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }
  
  /// Apple optimization: Check if energy characteristics match
  bool matchesEnergyCharacteristics(double energyRatio, double rmsEnergy) {
    return energyRatio >= minEnergyRatio &&
           energyRatio <= maxEnergyRatio &&
           rmsEnergy >= minRMSEnergy &&
           rmsEnergy <= maxRMSEnergy;
  }
  
  /// Apple optimization: Check if frequency characteristics match
  bool matchesFrequencyCharacteristics(Map<String, double> spectrum) {
    final dominantFreq = spectrum['dominant_freq'] ?? 0.0;
    final spectralCentroid = spectrum['spectral_centroid'] ?? 0.0;
    final spectralRolloff = spectrum['spectral_rolloff'] ?? 0.0;
    final spectralBandwidth = spectrum['spectral_bandwidth'] ?? 0.0;
    
    return dominantFreq >= minDominantFrequency &&
           dominantFreq <= maxDominantFrequency &&
           spectralCentroid >= minSpectralCentroid &&
           spectralCentroid <= maxSpectralCentroid &&
           spectralRolloff >= minSpectralRolloff &&
           spectralRolloff <= maxSpectralRolloff &&
           spectralBandwidth >= minSpectralBandwidth &&
           spectralBandwidth <= maxSpectralBandwidth;
  }
  
  /// Apple optimization: Check if temporal characteristics match
  bool matchesTemporalCharacteristics(double attackTime, double decayTime) {
    return attackTime >= minAttackTime &&
           attackTime <= maxAttackTime &&
           decayTime >= minDecayTime &&
           decayTime <= maxDecayTime;
  }
  
  /// Apple optimization: Check if time-domain characteristics match
  bool matchesTimeDomainCharacteristics(double zeroCrossingRate) {
    return zeroCrossingRate >= minZeroCrossingRate &&
           zeroCrossingRate <= maxZeroCrossingRate;
  }
  
  /// Apple optimization: Create a copy with modifications
  StrikeSoundCharacteristics copyWith({
    double? minEnergyRatio,
    double? maxEnergyRatio,
    double? energySpikeThreshold,
    double? minDominantFrequency,
    double? maxDominantFrequency,
    double? minSpectralCentroid,
    double? maxSpectralCentroid,
    double? minSpectralRolloff,
    double? maxSpectralRolloff,
    double? minSpectralBandwidth,
    double? maxSpectralBandwidth,
    double? minAttackTime,
    double? maxAttackTime,
    double? minDecayTime,
    double? maxDecayTime,
    double? minZeroCrossingRate,
    double? maxZeroCrossingRate,
    double? minRMSEnergy,
    double? maxRMSEnergy,
    Map<String, double>? featureWeights,
  }) {
    return StrikeSoundCharacteristics(
      minEnergyRatio: minEnergyRatio ?? this.minEnergyRatio,
      maxEnergyRatio: maxEnergyRatio ?? this.maxEnergyRatio,
      energySpikeThreshold: energySpikeThreshold ?? this.energySpikeThreshold,
      minDominantFrequency: minDominantFrequency ?? this.minDominantFrequency,
      maxDominantFrequency: maxDominantFrequency ?? this.maxDominantFrequency,
      minSpectralCentroid: minSpectralCentroid ?? this.minSpectralCentroid,
      maxSpectralCentroid: maxSpectralCentroid ?? this.maxSpectralCentroid,
      minSpectralRolloff: minSpectralRolloff ?? this.minSpectralRolloff,
      maxSpectralRolloff: maxSpectralRolloff ?? this.maxSpectralRolloff,
      minSpectralBandwidth: minSpectralBandwidth ?? this.minSpectralBandwidth,
      maxSpectralBandwidth: maxSpectralBandwidth ?? this.maxSpectralBandwidth,
      minAttackTime: minAttackTime ?? this.minAttackTime,
      maxAttackTime: maxAttackTime ?? this.maxAttackTime,
      minDecayTime: minDecayTime ?? this.minDecayTime,
      maxDecayTime: maxDecayTime ?? this.maxDecayTime,
      minZeroCrossingRate: minZeroCrossingRate ?? this.minZeroCrossingRate,
      maxZeroCrossingRate: maxZeroCrossingRate ?? this.maxZeroCrossingRate,
      minRMSEnergy: minRMSEnergy ?? this.minRMSEnergy,
      maxRMSEnergy: maxRMSEnergy ?? this.maxRMSEnergy,
      featureWeights: featureWeights ?? this.featureWeights,
    );
  }
  
  @override
  String toString() {
    return 'StrikeSoundCharacteristics('
        'energyRatio: ${minEnergyRatio.toStringAsFixed(1)}-${maxEnergyRatio.toStringAsFixed(1)}, '
        'dominantFreq: ${minDominantFrequency.toStringAsFixed(0)}-${maxDominantFrequency.toStringAsFixed(0)}Hz, '
        'attackTime: ${(minAttackTime * 1000).toStringAsFixed(1)}-${(maxAttackTime * 1000).toStringAsFixed(1)}ms'
        ')';
  }
}

/// Strike types for different training scenarios
enum StrikeType {
  punchingBag,
  boxing,
  kickboxing,
  general,
} 