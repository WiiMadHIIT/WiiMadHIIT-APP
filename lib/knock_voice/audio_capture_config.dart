/// Audio Capture Configuration
/// Apple-level optimized configuration for real-time audio capture
/// with intelligent noise suppression and adaptive settings
class AudioCaptureConfig {
  // Core audio settings
  final int sampleRate;
  final int bufferSize;
  final int channels;
  
  // Apple optimization: Noise reduction and echo cancellation
  final bool enableNoiseReduction;
  final bool enableEchoCancellation;
  final bool enableAutomaticGainControl;
  
  // Apple optimization: Adaptive threshold settings
  final double adaptiveThresholdFactor;
  final double minimumThreshold;
  final double maximumThreshold;
  
  // Apple optimization: Performance settings
  final int fftSize;
  final double overlapFactor;
  final int smoothingWindow;
  
  // Apple optimization: User experience settings
  final bool enableHapticFeedback;
  final bool enableVisualFeedback;
  final int debounceTimeMs;
  
  // Apple optimization: Power management
  final bool enablePowerOptimization;
  final int powerSavingIntervalMs;
  
  const AudioCaptureConfig({
    // Core settings optimized for strike detection
    this.sampleRate = 44100,
    this.bufferSize = 1024,
    this.channels = 1,
    
    // Apple optimization: Enhanced audio processing
    this.enableNoiseReduction = true,
    this.enableEchoCancellation = true,
    this.enableAutomaticGainControl = true,
    
    // Apple optimization: Intelligent threshold management
    this.adaptiveThresholdFactor = 2.5,
    this.minimumThreshold = 0.1,
    this.maximumThreshold = 10.0,
    
    // Apple optimization: Performance tuning
    this.fftSize = 2048,
    this.overlapFactor = 0.75,
    this.smoothingWindow = 5,
    
    // Apple optimization: User experience
    this.enableHapticFeedback = true,
    this.enableVisualFeedback = true,
    this.debounceTimeMs = 100,
    
    // Apple optimization: Power efficiency
    this.enablePowerOptimization = true,
    this.powerSavingIntervalMs = 5000,
  });
  
  /// Apple optimization: Create configuration based on device capabilities
  factory AudioCaptureConfig.forDevice({
    required bool isHighEndDevice,
    required bool hasAdvancedAudioProcessing,
    required double batteryLevel,
  }) {
    return AudioCaptureConfig(
      // Adjust sample rate based on device capabilities
      sampleRate: isHighEndDevice ? 48000 : 44100,
      bufferSize: isHighEndDevice ? 512 : 1024,
      
      // Enable advanced features only on capable devices
      enableNoiseReduction: hasAdvancedAudioProcessing,
      enableEchoCancellation: hasAdvancedAudioProcessing,
      enableAutomaticGainControl: hasAdvancedAudioProcessing,
      
      // Adjust performance based on battery level
      fftSize: batteryLevel > 0.3 ? 2048 : 1024,
      powerSavingIntervalMs: batteryLevel > 0.5 ? 10000 : 5000,
    );
  }
  
  /// Apple optimization: Create configuration for different environments
  factory AudioCaptureConfig.forEnvironment({
    required bool isNoisyEnvironment,
    required bool isQuietEnvironment,
    required bool isOutdoorEnvironment,
  }) {
    return AudioCaptureConfig(
      // Adjust thresholds based on environment
      adaptiveThresholdFactor: isNoisyEnvironment ? 3.5 : 2.5,
      minimumThreshold: isQuietEnvironment ? 0.05 : 0.1,
      maximumThreshold: isNoisyEnvironment ? 15.0 : 10.0,
      
      // Adjust processing based on environment
      enableNoiseReduction: isNoisyEnvironment,
      smoothingWindow: isNoisyEnvironment ? 7 : 5,
    );
  }
  
  /// Apple optimization: Validate configuration
  bool get isValid {
    return sampleRate > 0 &&
           bufferSize > 0 &&
           channels > 0 &&
           adaptiveThresholdFactor > 0 &&
           minimumThreshold >= 0 &&
           maximumThreshold > minimumThreshold &&
           fftSize > 0 &&
           overlapFactor > 0 && overlapFactor < 1 &&
           smoothingWindow > 0 &&
           debounceTimeMs >= 0 &&
           powerSavingIntervalMs > 0;
  }
  
  /// Apple optimization: Get optimized buffer size for FFT
  int get optimizedBufferSize {
    // Ensure buffer size is power of 2 for efficient FFT
    int size = bufferSize;
    while (size < fftSize) {
      size *= 2;
    }
    return size;
  }
  
  /// Apple optimization: Get hop size for overlapping windows
  int get hopSize {
    return (optimizedBufferSize * (1 - overlapFactor)).round();
  }
  
  /// Apple optimization: Get frame rate for real-time processing
  double get frameRate {
    return sampleRate / hopSize;
  }
  
  /// Apple optimization: Get latency in milliseconds
  double get latencyMs {
    return (optimizedBufferSize / sampleRate) * 1000;
  }
  
  /// Apple optimization: Create a copy with modifications
  AudioCaptureConfig copyWith({
    int? sampleRate,
    int? bufferSize,
    int? channels,
    bool? enableNoiseReduction,
    bool? enableEchoCancellation,
    bool? enableAutomaticGainControl,
    double? adaptiveThresholdFactor,
    double? minimumThreshold,
    double? maximumThreshold,
    int? fftSize,
    double? overlapFactor,
    int? smoothingWindow,
    bool? enableHapticFeedback,
    bool? enableVisualFeedback,
    int? debounceTimeMs,
    bool? enablePowerOptimization,
    int? powerSavingIntervalMs,
  }) {
    return AudioCaptureConfig(
      sampleRate: sampleRate ?? this.sampleRate,
      bufferSize: bufferSize ?? this.bufferSize,
      channels: channels ?? this.channels,
      enableNoiseReduction: enableNoiseReduction ?? this.enableNoiseReduction,
      enableEchoCancellation: enableEchoCancellation ?? this.enableEchoCancellation,
      enableAutomaticGainControl: enableAutomaticGainControl ?? this.enableAutomaticGainControl,
      adaptiveThresholdFactor: adaptiveThresholdFactor ?? this.adaptiveThresholdFactor,
      minimumThreshold: minimumThreshold ?? this.minimumThreshold,
      maximumThreshold: maximumThreshold ?? this.maximumThreshold,
      fftSize: fftSize ?? this.fftSize,
      overlapFactor: overlapFactor ?? this.overlapFactor,
      smoothingWindow: smoothingWindow ?? this.smoothingWindow,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableVisualFeedback: enableVisualFeedback ?? this.enableVisualFeedback,
      debounceTimeMs: debounceTimeMs ?? this.debounceTimeMs,
      enablePowerOptimization: enablePowerOptimization ?? this.enablePowerOptimization,
      powerSavingIntervalMs: powerSavingIntervalMs ?? this.powerSavingIntervalMs,
    );
  }
  
  @override
  String toString() {
    return 'AudioCaptureConfig('
        'sampleRate: $sampleRate, '
        'bufferSize: $bufferSize, '
        'channels: $channels, '
        'enableNoiseReduction: $enableNoiseReduction, '
        'enableEchoCancellation: $enableEchoCancellation, '
        'adaptiveThresholdFactor: $adaptiveThresholdFactor, '
        'fftSize: $fftSize, '
        'latencyMs: ${latencyMs.toStringAsFixed(1)}ms'
        ')';
  }
} 