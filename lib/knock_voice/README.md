# Knock Voice - Apple-Level Sound Detection System

## Overview

Knock Voice is a comprehensive, Apple-level optimized sound detection system designed for real-time strike sound recognition in fitness applications. Built with Flutter/Dart, it provides intelligent audio analysis with adaptive learning, performance optimization, and graceful error handling.

## 🎯 Key Features

### Core Capabilities
- **Real-time Audio Analysis**: Sub-50ms response time for strike detection
- **Adaptive Learning**: User pattern recognition and sensitivity adjustment
- **Performance Optimization**: Intelligent resource management and power saving
- **Error Recovery**: Comprehensive error handling with automatic recovery strategies
- **Cross-Platform**: iOS and Android support with device-specific optimizations

### Apple-Level Optimizations
- **Privacy-First**: All processing done locally, no audio data transmitted
- **Intelligent Calibration**: Automatic ambient noise level detection and adaptation
- **User Experience**: Haptic feedback, visual indicators, and preference management
- **Performance Monitoring**: Real-time metrics and optimization recommendations
- **Graceful Degradation**: Fallback mechanisms for device compatibility

## 📁 Module Structure

```
knock_voice/
├── audio_capture_config.dart      # Audio capture configuration
├── strike_sound_characteristics.dart # Strike sound feature definitions
├── fft.dart                       # Fast Fourier Transform utilities
├── audio_analyzer.dart            # Real-time spectral analysis
├── adaptive_strike_detector.dart  # Intelligent detection with learning
├── strike_audio_detector.dart     # Main orchestrator class
├── user_preferences.dart          # User settings and preferences
├── performance_monitor.dart       # Performance tracking and optimization
├── error_handler.dart             # Error handling and recovery
└── README.md                      # This file
```

## 🚀 Quick Start

### 1. Basic Usage

```dart
import 'package:wiimadhiit/knock_voice/strike_audio_detector.dart';

// Create detector instance
final detector = StrikeAudioDetector(
  strikeType: StrikeType.punchingBag,
);

// Set up callbacks
detector.onStrikeDetected = () {
  print('Strike detected!');
  // Trigger your counting logic here
};

detector.onError = (error) {
  print('Detection error: $error');
};

// Start listening
final success = await detector.startListening();
if (success) {
  print('Audio detection started successfully');
}
```

### 2. Advanced Configuration

```dart
import 'package:wiimadhiit/knock_voice/audio_capture_config.dart';
import 'package:wiimadhiit/knock_voice/strike_audio_detector.dart';

// Create custom configuration
final config = AudioCaptureConfig(
  sampleRate: 48000,
  bufferSize: 512,
  fftSize: 2048,
  enableNoiseReduction: true,
  enableEchoCancellation: true,
  adaptiveThresholdFactor: 3.0,
);

// Create detector with custom config
final detector = StrikeAudioDetector(
  config: config,
  strikeType: StrikeType.boxing,
);

// Set user sensitivity
detector.setUserSensitivity(1.2); // 0.5 to 2.0
```

### 3. User Preferences Management

```dart
import 'package:wiimadhiit/knock_voice/user_preferences.dart';

final preferences = UserPreferences();
await preferences.initialize();

// Save user preferences
await preferences.saveUserSensitivity(1.5);
await preferences.saveAudioDetectionEnabled(true);
await preferences.saveStrikeType('punchingBag');

// Get recommended settings
final recommendations = await preferences.getRecommendedSettings();
await preferences.applyRecommendedSettings();
```

## 🔧 Core Components

### AudioCaptureConfig
Configures audio capture parameters with device-specific optimizations:
- Sample rate and buffer size optimization
- Noise reduction and echo cancellation
- Adaptive threshold management
- Power optimization settings

### StrikeSoundCharacteristics
Defines spectral and temporal characteristics of strike sounds:
- Energy ratio thresholds
- Frequency range specifications
- Temporal feature requirements
- Weighted feature importance

### FFT (Fast Fourier Transform)
Optimized FFT implementation for real-time spectral analysis:
- Pre-computed twiddle factors
- Efficient bit-reversal tables
- Multiple window functions (Hanning, Hamming, Blackman)
- Spectral feature extraction utilities

### AudioAnalyzer
Real-time audio analysis with intelligent feature extraction:
- A-weighting filter for human hearing sensitivity
- Comprehensive spectral feature analysis
- Temporal characteristic detection
- Adaptive threshold management

### AdaptiveStrikeDetector
Intelligent detection with user learning:
- Automatic calibration
- User pattern recognition
- Adaptive sensitivity adjustment
- Performance monitoring

### StrikeAudioDetector
Main orchestrator class providing high-level interface:
- Device compatibility checking
- Audio capture management
- Power optimization
- System metrics tracking

## 📊 Performance Metrics

### Apple Quality Standards
- **Response Time**: < 30ms average latency
- **Accuracy**: > 95% detection rate
- **False Positives**: < 3% misdetection rate
- **Battery Impact**: < 10% additional drain
- **Memory Usage**: < 50MB peak memory
- **CPU Usage**: < 15% average CPU

### Real-time Monitoring
```dart
// Access performance metrics
final metrics = detector.systemMetrics;
print('Performance Score: ${metrics['performance_score']}');
print('Average Latency: ${metrics['average_latency_ms']}ms');
print('Detection Rate: ${metrics['detections_per_second']}/s');

// Get performance recommendations
final recommendations = performanceMonitor.getPerformanceRecommendations();
```

## 🛠️ Error Handling

### Comprehensive Error Management
```dart
import 'package:wiimadhiit/knock_voice/error_handler.dart';

final errorHandler = ErrorHandler();

// Handle errors with automatic recovery
final recovered = await errorHandler.handleError(
  'Audio capture failed',
  category: 'audio_capture',
  severity: 'medium',
  context: {'device': 'iPhone 12'},
);

// Get error statistics
final stats = errorHandler.getErrorStatistics();
print('Total Errors: ${stats['total_errors']}');
print('Recovery Rate: ${stats['recovery_rate']}');
```

### Error Categories
- **Initialization**: Device compatibility, permissions, configuration
- **Audio Capture**: Microphone access, stream failures, buffer issues
- **Analysis**: FFT computation, feature extraction, pattern matching
- **Performance**: Memory overflow, CPU overload, latency issues
- **User**: Invalid input, preference conflicts, calibration failures
- **System**: Platform errors, network issues, storage problems

## 🎛️ User Preferences

### Persistent Settings
- User sensitivity (0.5 - 2.0)
- Audio detection enabled/disabled
- Auto-calibration preferences
- Haptic and visual feedback settings
- Strike type preferences
- Power optimization settings

### Usage Statistics
- Total sessions and detections
- Average session duration
- Preferred strike types
- Performance trends

## 🔍 Integration Guide

### Integration with CheckinTrainingPage

```dart
class _CheckinTrainingPageState extends State<CheckinTrainingPage> {
  late StrikeAudioDetector _audioDetector;
  bool _audioDetectionEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAudioDetection();
  }
  
  Future<void> _initializeAudioDetection() async {
    _audioDetector = StrikeAudioDetector(
      strikeType: StrikeType.punchingBag,
    );
    
    _audioDetector.onStrikeDetected = () {
      if (isCounting && mounted) {
        _onCountPressed(); // Your existing counting logic
      }
    };
    
    _audioDetector.onError = (error) {
      // Handle detection errors
      print('Audio detection error: $error');
    };
  }
  
  Future<void> _toggleAudioDetection() async {
    if (_audioDetectionEnabled) {
      await _audioDetector.stopListening();
    } else {
      final success = await _audioDetector.startListening();
      if (!success) {
        // Handle initialization failure
        return;
      }
    }
    
    setState(() {
      _audioDetectionEnabled = !_audioDetectionEnabled;
    });
  }
  
  @override
  void dispose() {
    _audioDetector.dispose();
    super.dispose();
  }
}
```

## 🧪 Testing and Validation

### Unit Tests
```dart
// Test audio analysis
final analyzer = AudioAnalyzer(config: config, characteristics: characteristics);
final isStrike = analyzer.analyzeAudioBuffer(testAudioBuffer);
expect(isStrike, isTrue);

// Test FFT computation
final fftResult = FFT.fft(testSignal);
expect(fftResult.length, equals(expectedLength));
```

### Performance Testing
```dart
// Measure detection latency
final stopwatch = Stopwatch()..start();
final detected = detector.processAudioBuffer(audioBuffer);
stopwatch.stop();
expect(stopwatch.elapsedMilliseconds, lessThan(50));
```

## 📈 Future Enhancements

### Planned Features
- **Machine Learning Integration**: Enhanced pattern recognition
- **Multi-Strike Detection**: Simultaneous detection of different strike types
- **Cloud Synchronization**: Cross-device preference sync
- **Advanced Analytics**: Detailed performance insights
- **Custom Strike Types**: User-defined strike sound profiles

### Research Areas
- **Neural Network Integration**: Deep learning for improved accuracy
- **Edge Computing**: On-device AI processing
- **Environmental Adaptation**: Advanced noise cancellation
- **Biometric Integration**: Heart rate and motion sensor fusion

## 🤝 Contributing

### Development Guidelines
1. Follow Apple-level code quality standards
2. Maintain comprehensive error handling
3. Include performance optimizations
4. Add thorough documentation
5. Write unit tests for all components

### Code Style
- Use descriptive variable and function names
- Include detailed comments for complex algorithms
- Follow Dart/Flutter best practices
- Maintain consistent formatting

## 📄 License

This module is part of the Wiimadhiit project and follows the same licensing terms.

## 🆘 Support

For technical support or feature requests:
1. Check the error logs and performance metrics
2. Review the device compatibility requirements
3. Verify audio permissions are granted
4. Test with different strike types and environments

---

**Note**: This module is designed for integration with the Wiimadhiit fitness application. For standalone use, additional setup may be required for audio permissions and platform-specific configurations. 