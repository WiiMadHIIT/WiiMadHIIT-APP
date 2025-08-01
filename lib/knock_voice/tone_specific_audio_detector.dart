import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

/// Tone Specific Audio Detector - 特定音色音频检测器
/// 用于实时检测特定音色的击打声音并进行计数
/// 支持音色样本录制、特征提取和实时匹配
class ToneSpecificAudioDetector {
  // State management
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isRecordingSample = false;
  
  // Callbacks
  VoidCallback? onStrikeDetected;
  VoidCallback? onSampleRecorded;
  Function(String)? onError;
  Function(String)? onStatusUpdate;
  
  // Audio processing
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  
  // Stream subscriptions
  StreamSubscription? _amplitudeSubscription;
  StreamSubscription? _audioDataSubscription;
  
  // Audio data buffers
  List<List<Float32List>> _audioBuffer = [];
  List<List<Float32List>> _sampleBuffer = [];
  
  // Stream controllers
  StreamController<List<Float32List>>? _audioDataController;
  
  // Audio configuration
  static const int _sampleRate = 48000;
  static const int _numChannels = 1;
  static const int _bufferSize = 1024;
  static const Duration _subscriptionDuration = Duration(milliseconds: 100);
  
  // Detection parameters
  double _currentDb = 0.0;
  int _hitCount = 0;
  DateTime? _lastStrikeTime;
  static const double _dbThreshold = 50.0;
  static const int _minStrikeInterval = 200;
  
  // Tone matching parameters
  List<double> _sampleFeatures = [];
  double _similarityThreshold = 0.8; // 相似度阈值
  int _fftSize = 512; // FFT 大小
  List<double> _frequencyBands = []; // 频率带特征
  
  // Audio processing mode
  Codec _codecSelected = Codec.pcmFloat32;
  
  /// Initialize detector
  Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        _updateStatus('Tone specific audio detector already initialized');
        print('🎯 Tone specific audio detector already initialized');
        return true;
      }
      
      // Initialize recorder
      print('🎯 Opening flutter_sound recorder...');
      await _recorder.openRecorder();
      print('🎯 Flutter_sound recorder opened successfully');
      
      // Initialize player
      print('🎯 Opening flutter_sound player...');
      await _player.openPlayer();
      print('🎯 Flutter_sound player opened successfully');
      
      // Set subscription duration
      await _recorder.setSubscriptionDuration(_subscriptionDuration);
      print('🎯 Subscription duration set to ${_subscriptionDuration.inMilliseconds}ms');
      
      _isInitialized = true;
      _updateStatus('Tone specific audio detector initialized');
      print('🎯 Tone specific audio detector initialized successfully');
      return true;
    } catch (e) {
      print('❌ Failed to initialize tone specific audio detector: $e');
      _handleError('Failed to initialize tone specific audio detector: $e');
      return false;
    }
  }
  
  /// Record tone sample for matching
  Future<bool> recordToneSample({Duration duration = const Duration(seconds: 3)}) async {
    if (!_isInitialized) {
      _handleError('Tone specific audio detector not initialized');
      return false;
    }
    
    if (_isRecordingSample) {
      print('🎯 Already recording tone sample');
      return false;
    }
    
    try {
      _isRecordingSample = true;
      _sampleBuffer.clear();
      _updateStatus('Recording tone sample...');
      
      // Create stream controller for sample recording
      _audioDataController = StreamController<List<Float32List>>();
      _audioDataController!.stream.listen((audioData) {
        _sampleBuffer.add(audioData);
      });
      
      // Start recording sample
      await _recorder.startRecorder(
        codec: _codecSelected,
        sampleRate: _sampleRate,
        numChannels: _numChannels,
        audioSource: AudioSource.defaultSource,
        toStreamFloat32: _audioDataController!.sink,
        bufferSize: _bufferSize,
      );
      
      print('🎯 Recording tone sample for ${duration.inSeconds} seconds...');
      
      // Record for specified duration
      await Future.delayed(duration);
      
      // Stop recording
      await _recorder.stopRecorder();
      await _audioDataController?.close();
      _audioDataController = null;
      
      // Extract features from sample
      _extractSampleFeatures();
      
      _isRecordingSample = false;
      _updateStatus('Tone sample recorded and features extracted');
      onSampleRecorded?.call();
      
      print('🎯 Tone sample recorded successfully. Features: ${_sampleFeatures.length}');
      return true;
    } catch (e) {
      _isRecordingSample = false;
      print('❌ Failed to record tone sample: $e');
      _handleError('Failed to record tone sample: $e');
      return false;
    }
  }
  
  /// Extract features from recorded sample
  void _extractSampleFeatures() {
    if (_sampleBuffer.isEmpty) return;
    
    try {
      // Combine all audio data
      List<double> combinedAudio = [];
      for (var audioData in _sampleBuffer) {
        for (var channel in audioData) {
          combinedAudio.addAll(channel);
        }
      }
      
      // Calculate frequency domain features
      _sampleFeatures = _calculateFrequencyFeatures(combinedAudio);
      
      // Calculate frequency bands
      _frequencyBands = _calculateFrequencyBands(combinedAudio);
      
      print('🎵 Sample features extracted: ${_sampleFeatures.length} features');
      print('🎵 Frequency bands: ${_frequencyBands.length} bands');
    } catch (e) {
      print('⚠️ Error extracting sample features: $e');
    }
  }
  
  /// Calculate frequency domain features using FFT
  List<double> _calculateFrequencyFeatures(List<double> audioData) {
    if (audioData.isEmpty) return [];
    
    // Simple frequency analysis (simplified FFT)
    List<double> features = [];
    
    // Calculate RMS energy
    double rms = _calculateRMSFromList(audioData);
    features.add(rms);
    
    // Calculate spectral centroid (simplified)
    double spectralCentroid = _calculateSpectralCentroid(audioData);
    features.add(spectralCentroid);
    
    // Calculate zero crossing rate
    double zeroCrossingRate = _calculateZeroCrossingRate(audioData);
    features.add(zeroCrossingRate);
    
    // Calculate spectral rolloff (simplified)
    double spectralRolloff = _calculateSpectralRolloff(audioData);
    features.add(spectralRolloff);
    
    return features;
  }
  
  /// Calculate frequency bands
  List<double> _calculateFrequencyBands(List<double> audioData) {
    if (audioData.isEmpty) return [];
    
    // Divide audio into frequency bands (simplified)
    List<double> bands = [];
    int bandSize = audioData.length ~/ 8; // 8 frequency bands
    
    for (int i = 0; i < 8; i++) {
      int start = i * bandSize;
      int end = (i + 1) * bandSize;
      if (end > audioData.length) end = audioData.length;
      
      double bandEnergy = 0.0;
      for (int j = start; j < end; j++) {
        bandEnergy += audioData[j] * audioData[j];
      }
      bands.add(sqrt(bandEnergy / (end - start)));
    }
    
    return bands;
  }
  
  /// Calculate RMS from list
  double _calculateRMSFromList(List<double> data) {
    if (data.isEmpty) return 0.0;
    double sum = 0.0;
    for (var sample in data) {
      sum += sample * sample;
    }
    return sqrt(sum / data.length);
  }
  
  /// Calculate spectral centroid (simplified)
  double _calculateSpectralCentroid(List<double> audioData) {
    if (audioData.isEmpty) return 0.0;
    
    double weightedSum = 0.0;
    double sum = 0.0;
    
    for (int i = 0; i < audioData.length; i++) {
      double magnitude = audioData[i].abs();
      weightedSum += magnitude * i;
      sum += magnitude;
    }
    
    return sum > 0 ? weightedSum / sum : 0.0;
  }
  
  /// Calculate zero crossing rate
  double _calculateZeroCrossingRate(List<double> audioData) {
    if (audioData.length < 2) return 0.0;
    
    int crossings = 0;
    for (int i = 1; i < audioData.length; i++) {
      if ((audioData[i] >= 0) != (audioData[i - 1] >= 0)) {
        crossings++;
      }
    }
    
    return crossings / (audioData.length - 1);
  }
  
  /// Calculate spectral rolloff (simplified)
  double _calculateSpectralRolloff(List<double> audioData) {
    if (audioData.isEmpty) return 0.0;
    
    // Sort magnitudes
    List<double> magnitudes = audioData.map((e) => e.abs()).toList();
    magnitudes.sort();
    
    // Find 85th percentile
    int index = (magnitudes.length * 0.85).round();
    if (index >= magnitudes.length) index = magnitudes.length - 1;
    
    return magnitudes[index];
  }
  
  /// Start listening to microphone input with tone matching
  Future<bool> startListening() async {
    if (!_isInitialized) {
      _handleError('Tone specific audio detector not initialized');
      return false;
    }
    
    if (_isListening) {
      print('🎯 Tone specific audio detection already listening');
      return true;
    }
    
    if (_sampleFeatures.isEmpty) {
      _handleError('No tone sample recorded. Please record a sample first.');
      return false;
    }
    
    try {
      // Check if recorder is already recording
      if (_recorder.isRecording) {
        print('🎯 Recorder already recording, stopping first');
        await _recorder.stopRecorder();
      }
      
      // Clear previous data
      _audioBuffer.clear();
      _hitCount = 0;
      _lastStrikeTime = null;
      _currentDb = 0.0;
      
      // Create stream controller for real-time detection
      _audioDataController = StreamController<List<Float32List>>();
      _audioDataController!.stream.listen((audioData) {
        _audioBuffer.add(audioData);
        _processAudioDataWithToneMatching(audioData);
      });
      
      // Start recording
      await _recorder.startRecorder(
        codec: _codecSelected,
        sampleRate: _sampleRate,
        numChannels: _numChannels,
        audioSource: AudioSource.defaultSource,
        toStreamFloat32: _audioDataController!.sink,
        bufferSize: _bufferSize,
      );
      
      _isListening = true;
      _updateStatus('Started listening with tone matching');
      
      // Subscribe to amplitude data
      _amplitudeSubscription = _recorder.onProgress!.listen((e) {
        _processAmplitudeData(e);
      });
      
      print('🎯 Tone specific audio detection started successfully');
      return true;
    } catch (e) {
      print('❌ Failed to start tone specific audio detection: $e');
      _handleError('Failed to start tone specific audio detection: $e');
      return false;
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      print('🎯 Stopping tone specific audio detection...');
      
      // Cancel subscriptions
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      
      await _audioDataSubscription?.cancel();
      _audioDataSubscription = null;
      
      // Close stream controllers
      await _audioDataController?.close();
      _audioDataController = null;
      
      // Stop recording
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
        print('🎯 Recording stopped');
      }
      
      _isListening = false;
      _updateStatus('Stopped listening to microphone');
      
      print('🎯 Tone specific audio detection stopped');
    } catch (e) {
      _handleError('Failed to stop tone specific audio detection: $e');
    }
  }
  
  /// Process amplitude data
  void _processAmplitudeData(RecordingDisposition e) {
    try {
      _currentDb = e.decibels ?? 0.0;
      
      // Only check amplitude if we have sample features
      if (_sampleFeatures.isNotEmpty) {
        _checkStrikeFromAmplitude(_currentDb);
      }
      
      // Debug logging
      if (_hitCount % 3 == 0 || _currentDb > _dbThreshold * 0.8) {
        print('🎤 Current dB: ${_currentDb.toStringAsFixed(1)} dB (threshold: $_dbThreshold)');
      }
    } catch (e) {
      print('⚠️ Amplitude processing error: $e');
    }
  }
  
  /// Process audio data with tone matching
  void _processAudioDataWithToneMatching(List<Float32List> audioData) {
    try {
      // Calculate RMS energy
      double rmsEnergy = _calculateRMSEnergy(audioData);
      double dbFromAudio = _rmsToDecibels(rmsEnergy);
      
      // Check if audio level is high enough
      if (dbFromAudio > _dbThreshold * 1.2) {
        // Extract features from current audio
        List<double> currentFeatures = _extractCurrentFeatures(audioData);
        
        // Calculate similarity with sample
        double similarity = _calculateSimilarity(currentFeatures);
        
        print('🎵 Audio detected: ${dbFromAudio.toStringAsFixed(1)} dB, Similarity: ${similarity.toStringAsFixed(3)}');
        
        // Check if similarity is high enough
        if (similarity > _similarityThreshold) {
          _checkStrikeFromToneMatching(dbFromAudio, similarity);
        }
      }
    } catch (e) {
      print('⚠️ Audio data processing error: $e');
    }
  }
  
  /// Extract features from current audio data
  List<double> _extractCurrentFeatures(List<Float32List> audioData) {
    // Combine audio data
    List<double> combinedAudio = [];
    for (var channel in audioData) {
      combinedAudio.addAll(channel);
    }
    
    // Calculate same features as sample
    return _calculateFrequencyFeatures(combinedAudio);
  }
  
  /// Calculate similarity between current features and sample features
  double _calculateSimilarity(List<double> currentFeatures) {
    if (_sampleFeatures.isEmpty || currentFeatures.isEmpty) return 0.0;
    
    // Cosine similarity
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    int minLength = min(_sampleFeatures.length, currentFeatures.length);
    
    for (int i = 0; i < minLength; i++) {
      dotProduct += _sampleFeatures[i] * currentFeatures[i];
      normA += _sampleFeatures[i] * _sampleFeatures[i];
      normB += currentFeatures[i] * currentFeatures[i];
    }
    
    normA = sqrt(normA);
    normB = sqrt(normB);
    
    if (normA == 0.0 || normB == 0.0) return 0.0;
    
    return dotProduct / (normA * normB);
  }
  
  /// Calculate RMS energy from Float32List
  double _calculateRMSEnergy(List<Float32List> audioData) {
    if (audioData.isEmpty) return 0.0;
    
    double sum = 0.0;
    int count = 0;
    
    for (var channel in audioData) {
      for (var sample in channel) {
        sum += sample * sample;
        count++;
      }
    }
    
    if (count == 0) return 0.0;
    return sqrt(sum / count);
  }
  
  /// Convert RMS to decibels
  double _rmsToDecibels(double rms) {
    if (rms <= 0.0) return -60.0;
    return 20.0 * log(rms) / ln10;
  }
  
  /// Check strike from amplitude (basic detection)
  void _checkStrikeFromAmplitude(double db) {
    final now = DateTime.now();
    
    if (db > _dbThreshold) {
      if (_lastStrikeTime == null || 
          now.difference(_lastStrikeTime!).inMilliseconds > _minStrikeInterval) {
        
        _lastStrikeTime = now;
        _hitCount++;
        
        print('🎯 AMPLITUDE STRIKE DETECTED! dB: ${db.toStringAsFixed(1)} (threshold: $_dbThreshold), Count: $_hitCount');
        
        onStrikeDetected?.call();
      } else {
        final timeSinceLast = now.difference(_lastStrikeTime!).inMilliseconds;
        print('⚠️ Amplitude strike ignored (too soon): dB ${db.toStringAsFixed(1)}, Time since last: ${timeSinceLast}ms');
      }
    }
  }
  
  /// Check strike from tone matching
  void _checkStrikeFromToneMatching(double db, double similarity) {
    final now = DateTime.now();
    
    if (db > _dbThreshold * 1.2 && similarity > _similarityThreshold) {
      if (_lastStrikeTime == null || 
          now.difference(_lastStrikeTime!).inMilliseconds > _minStrikeInterval * 1.5) {
        
        _lastStrikeTime = now;
        _hitCount++;
        
        print('🎵 TONE MATCHED STRIKE DETECTED! dB: ${db.toStringAsFixed(1)}, Similarity: ${similarity.toStringAsFixed(3)}, Count: $_hitCount');
        
        onStrikeDetected?.call();
      }
    }
  }
  
  /// Set similarity threshold
  void setSimilarityThreshold(double threshold) {
    _similarityThreshold = threshold.clamp(0.0, 1.0);
    print('🎵 Similarity threshold set to: $_similarityThreshold');
  }
  
  /// Get listening status
  bool get isListening => _isListening;
  
  /// Get initialization status
  bool get isInitialized => _isInitialized;
  
  /// Get sample recording status
  bool get isRecordingSample => _isRecordingSample;
  
  /// Get current decibel level
  double get currentDb => _currentDb;
  
  /// Get hit count
  int get hitCount => _hitCount;
  
  /// Get audio buffer size
  int get audioBufferSize => _audioBuffer.length;
  
  /// Get sample features count
  int get sampleFeaturesCount => _sampleFeatures.length;
  
  /// Get similarity threshold
  double get similarityThreshold => _similarityThreshold;
  
  /// Reset hit count
  void resetHitCount() {
    _hitCount = 0;
    _lastStrikeTime = null;
    print('🎯 Tone specific hit count reset to 0');
  }
  
  /// Clear sample features
  void clearSampleFeatures() {
    _sampleFeatures.clear();
    _frequencyBands.clear();
    print('🎵 Sample features cleared');
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
      _amplitudeSubscription?.cancel();
      _audioDataSubscription?.cancel();
      _audioDataController?.close();
      _recorder.closeRecorder();
      _player.closePlayer();
      print('🎯 Tone specific audio detector disposed');
    } catch (e) {
      _handleError('Error disposing tone specific audio detector: $e');
    }
  }
} 