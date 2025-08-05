import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'voice_match.dart';

/// XVector Audio Detector - 基于 x-vector 模型的音频检测器
/// 使用 x_vector.tflite 模型进行音色相似度检测
/// 结合 FFT 特征和 x-vector 嵌入向量进行混合相似度计算
class XVectorAudioDetector {
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
  List<Uint8List> _audioBufferUint8 = [];
  List<Uint8List> _sampleBufferUint8 = [];
  
  // Stream controllers
  StreamController<List<Float32List>>? _audioDataController;
  StreamController<Uint8List>? _audioDataControllerUint8;
  
  // Audio configuration
  static const int _sampleRate = 16000; // x-vector 模型要求 16kHz
  static const int _numChannels = 1;
  static const int _bufferSize = 1024;
  static const Duration _subscriptionDuration = Duration(milliseconds: 100);
  
  // Detection parameters
  double _currentDb = 0.0;
  int _hitCount = 0;
  DateTime? _lastStrikeTime;
  static const double _dbThreshold = 50.0; // 振幅检测阈值
  static const double _audioDataThreshold = 60.0; // 音频数据检测阈值
  static const int _minStrikeInterval = 200; // 振幅检测时间间隔
  static const int _audioDataStrikeInterval = 300; // 音频数据检测时间间隔
  
  // XVector matching parameters
  List<double> _sampleEmbedding = [];
  double _similarityThreshold = 0.8; // 相似度阈值
  List<double> _sampleSpectralFeatures = []; // 样本的 FFT 特征
  
  // Audio processing mode
  bool _interleaved = false;
  Codec _codecSelected = Codec.pcmFloat32;
  
  // Voice match instance for FFT features
  final VoiceMatch _voiceMatch = VoiceMatch();
  
  /// Initialize detector with TFLite model
  Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        _updateStatus('XVector audio detector already initialized');
        print('🎯 XVector audio detector already initialized');
        return true;
      }
      
      // Initialize voice match (which loads the TFLite model)
      await _voiceMatch.loadModel();
      print('🎯 Voice match model loaded');
      
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
      _updateStatus('XVector audio detector initialized');
      print('🎯 XVector audio detector initialized successfully');
      return true;
    } catch (e) {
      print('❌ Failed to initialize XVector audio detector: $e');
      _handleError('Failed to initialize XVector audio detector: $e');
      return false;
    }
  }
  
  /// Record tone sample for x-vector matching
  Future<bool> recordToneSample({Duration duration = const Duration(seconds: 5)}) async {
    if (!_isInitialized) {
      _handleError('XVector audio detector not initialized');
      return false;
    }
    
    if (_isRecordingSample) {
      print('🎯 Already recording tone sample');
      return false;
    }
    
    try {
      _isRecordingSample = true;
      _sampleBuffer.clear();
      _updateStatus('Recording tone sample for x-vector...');
      
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
      
      // Extract x-vector embedding and FFT features from sample
      await _extractSampleFeatures();
      
      _isRecordingSample = false;
      _updateStatus('Tone sample recorded and x-vector features extracted');
      onSampleRecorded?.call();
      
      print('🎯 Tone sample recorded successfully. Embedding size: ${_sampleEmbedding.length}');
      return true;
    } catch (e) {
      _isRecordingSample = false;
      print('❌ Failed to record tone sample: $e');
      _handleError('Failed to record tone sample: $e');
      return false;
    }
  }
  
  /// Extract x-vector embedding and FFT features from recorded sample
  Future<void> _extractSampleFeatures() async {
    if (_sampleBuffer.isEmpty) return;
    
    try {
      // Combine all audio data
      List<double> combinedAudio = [];
      for (var audioData in _sampleBuffer) {
        for (var channel in audioData) {
          combinedAudio.addAll(channel);
        }
      }
      
      // Extract x-vector embedding
      _sampleEmbedding = await _extractXVectorEmbedding(combinedAudio);
      
      // Extract FFT features
      _sampleSpectralFeatures = _calculateFFTFeatures(combinedAudio);
      
      print('🎵 Sample x-vector embedding extracted: ${_sampleEmbedding.length} dimensions');
      print('🎵 Sample FFT features extracted: ${_sampleSpectralFeatures.length} features');
    } catch (e) {
      print('⚠️ Error extracting sample features: $e');
    }
  }
  
  /// Extract x-vector embedding using TFLite model
  Future<List<double>> _extractXVectorEmbedding(List<double> audioData) async {
    try {
      // Use VoiceMatch to extract embedding
      return await _voiceMatch.extractEmbedding(audioData);
    } catch (e) {
      print('⚠️ Error extracting x-vector embedding: $e');
      return [];
    }
  }
  

  
  /// Calculate FFT features from audio data
  List<double> _calculateFFTFeatures(List<double> audioData) {
    if (audioData.isEmpty) return [];
    
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
  
  /// Start listening to microphone input with x-vector matching
  Future<bool> startListening() async {
    if (!_isInitialized) {
      _handleError('XVector audio detector not initialized');
      return false;
    }
    
    if (_isListening) {
      print('🎯 XVector audio detection already listening');
      return true;
    }
    
    if (_sampleEmbedding.isEmpty) {
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
      
      // Create stream controllers for real-time detection
      if (_interleaved) {
        _audioDataControllerUint8 = StreamController<Uint8List>();
        _audioDataControllerUint8!.stream.listen((Uint8List buf) {
          _audioBufferUint8.add(buf);
          _processAudioDataUint8WithXVector(buf);
        });
      } else {
        _audioDataController = StreamController<List<Float32List>>();
        _audioDataController!.stream.listen((audioData) {
          _audioBuffer.add(audioData);
          _processAudioDataWithXVector(audioData);
        });
      }
      
      // Start recording
      if (_interleaved) {
        await _recorder.startRecorder(
          codec: _codecSelected,
          sampleRate: _sampleRate,
          numChannels: _numChannels,
          audioSource: AudioSource.defaultSource,
          toStream: _audioDataControllerUint8!.sink,
          bufferSize: _bufferSize,
        );
      } else {
        await _recorder.startRecorder(
          codec: _codecSelected,
          sampleRate: _sampleRate,
          numChannels: _numChannels,
          audioSource: AudioSource.defaultSource,
          toStreamFloat32: _audioDataController!.sink,
          bufferSize: _bufferSize,
        );
      }
      
      _isListening = true;
      _updateStatus('Started listening with x-vector matching');
      
      // Subscribe to amplitude data
      _amplitudeSubscription = _recorder.onProgress!.listen((e) {
        _processAmplitudeData(e);
      });
      
      print('🎯 XVector audio detection started successfully');
      return true;
    } catch (e) {
      print('❌ Failed to start XVector audio detection: $e');
      _handleError('Failed to start XVector audio detection: $e');
      return false;
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      print('🎯 Stopping XVector audio detection...');
      
      // Cancel subscriptions
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      
      await _audioDataSubscription?.cancel();
      _audioDataSubscription = null;
      
      // Close stream controllers
      await _audioDataController?.close();
      _audioDataController = null;
      
      await _audioDataControllerUint8?.close();
      _audioDataControllerUint8 = null;
      
      // Stop recording
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
        print('🎯 Recording stopped');
      }
      
      _isListening = false;
      _updateStatus('Stopped listening to microphone');
      
      print('🎯 XVector audio detection stopped');
    } catch (e) {
      _handleError('Failed to stop XVector audio detection: $e');
    }
  }
  
  /// Process amplitude data with x-vector matching
  void _processAmplitudeData(RecordingDisposition e) {
    try {
      _currentDb = e.decibels ?? 0.0;
      
      // First step: Check if amplitude is high enough
      if (_currentDb > _dbThreshold) {
        print('🎤 Amplitude threshold passed: ${_currentDb.toStringAsFixed(1)} dB (threshold: $_dbThreshold)');
        
        // Second step: Check if we have sample embedding for x-vector matching
        if (_sampleEmbedding.isNotEmpty) {
          // Use the latest audio data for x-vector matching
          if (_audioBuffer.isNotEmpty) {
            List<Float32List> latestAudioData = _audioBuffer.last;
            _processAmplitudeWithXVector(_currentDb, latestAudioData);
          } else if (_audioBufferUint8.isNotEmpty) {
            Uint8List latestAudioData = _audioBufferUint8.last;
            _processAmplitudeWithXVectorUint8(_currentDb, latestAudioData);
          } else {
            print('🎤 Amplitude detected but no audio data available for x-vector matching - skipping detection');
          }
        } else {
          print('⚠️ Amplitude detected but no sample recorded: Cannot perform x-vector matching');
        }
      }
      
      // Debug logging
      if (_hitCount % 3 == 0 || _currentDb > _dbThreshold * 0.8) {
        print('🎤 Current dB: ${_currentDb.toStringAsFixed(1)} dB (threshold: $_dbThreshold)');
      }
    } catch (e) {
      print('⚠️ Amplitude processing error: $e');
    }
  }
  
  /// Process audio data with x-vector matching
  void _processAudioDataWithXVector(List<Float32List> audioData) {
    try {
      // Calculate RMS energy
      double rmsEnergy = _calculateRMSEnergy(audioData);
      double dbFromAudio = _rmsToDecibels(rmsEnergy);
      
      // First step: Check if audio level is high enough
      if (dbFromAudio > _audioDataThreshold) {
        print('🎵 First step passed: Audio level ${dbFromAudio.toStringAsFixed(1)} dB > threshold $_audioDataThreshold');
        
        // Second step: Check if we have sample embedding for x-vector matching
        if (_sampleEmbedding.isNotEmpty) {
          // Extract x-vector embedding from current audio
          _extractCurrentEmbedding(audioData).then((currentEmbedding) {
            if (currentEmbedding.isNotEmpty) {
              // Calculate similarity with sample
              double similarity = _calculateXVectorSimilarity(currentEmbedding);
              
              _lastDetectedSimilarity = similarity; // Update for UI display
              print('🎵 Second step: X-vector similarity ${similarity.toStringAsFixed(3)} (threshold: $_similarityThreshold)');
              
              // Final check: Both amplitude and x-vector matching passed
              if (similarity > _similarityThreshold) {
                _checkStrikeFromXVector(dbFromAudio, similarity);
              } else {
                print('⚠️ X-vector mismatch: similarity ${similarity.toStringAsFixed(3)} < threshold $_similarityThreshold');
              }
            }
          });
        } else {
          print('⚠️ No sample recorded: Cannot perform x-vector matching');
        }
      } else {
        // Debug: Show when audio level is too low
        if (dbFromAudio > _audioDataThreshold * 0.7) {
          print('🎵 Audio level too low: ${dbFromAudio.toStringAsFixed(1)} dB < threshold $_audioDataThreshold');
        }
      }
    } catch (e) {
      print('⚠️ Audio data processing error: $e');
    }
  }
  
  /// Extract x-vector embedding from current audio data
  Future<List<double>> _extractCurrentEmbedding(List<Float32List> audioData) async {
    try {
      // Combine audio data
      List<double> combinedAudio = [];
      for (var channel in audioData) {
        combinedAudio.addAll(channel);
      }
      
      // Extract x-vector embedding
      return await _extractXVectorEmbedding(combinedAudio);
    } catch (e) {
      print('⚠️ Error extracting current embedding: $e');
      return [];
    }
  }
  
  /// Calculate x-vector similarity using cosine similarity
  double _calculateXVectorSimilarity(List<double> currentEmbedding) {
    if (_sampleEmbedding.isEmpty || currentEmbedding.isEmpty) return 0.0;
    
    // Cosine similarity
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    int minLength = min(_sampleEmbedding.length, currentEmbedding.length);
    
    for (int i = 0; i < minLength; i++) {
      dotProduct += _sampleEmbedding[i] * currentEmbedding[i];
      normA += _sampleEmbedding[i] * _sampleEmbedding[i];
      normB += currentEmbedding[i] * currentEmbedding[i];
    }
    
    normA = sqrt(normA);
    normB = sqrt(normB);
    
    if (normA == 0.0 || normB == 0.0) return 0.0;
    
    double cosineSimilarity = dotProduct / (normA * normB);
    
    // Normalize to 0-1 range
    double normalizedSimilarity = (cosineSimilarity + 1.0) / 2.0;
    
    return normalizedSimilarity.clamp(0.0, 1.0);
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
  
  /// Process Uint8 audio data with x-vector matching
  void _processAudioDataUint8WithXVector(Uint8List audioData) {
    try {
      // Convert Uint8 to Float32 for processing
      Float32List floatData = Float32List(audioData.length ~/ 4);
      for (int i = 0; i < floatData.length; i++) {
        int offset = i * 4;
        floatData[i] = _bytesToFloat32(audioData, offset);
      }
      
      double rmsEnergy = _calculateRMSEnergyFromList(floatData);
      double dbFromAudio = _rmsToDecibels(rmsEnergy);
      
      // First step: Check if audio level is high enough
      if (dbFromAudio > _audioDataThreshold) {
        print('🎵 Uint8 First step passed: Audio level ${dbFromAudio.toStringAsFixed(1)} dB > threshold $_audioDataThreshold');
        
        // Second step: Check if we have sample embedding for x-vector matching
        if (_sampleEmbedding.isNotEmpty) {
          // Extract x-vector embedding from current audio
          _extractCurrentEmbeddingFromUint8(audioData).then((currentEmbedding) {
            if (currentEmbedding.isNotEmpty) {
              // Calculate similarity with sample
              double similarity = _calculateXVectorSimilarity(currentEmbedding);
              
              _lastDetectedSimilarity = similarity; // Update for UI display
              print('🎵 Uint8 Second step: X-vector similarity ${similarity.toStringAsFixed(3)} (threshold: $_similarityThreshold)');
              
              // Final check: Both amplitude and x-vector matching passed
              if (similarity > _similarityThreshold) {
                _checkStrikeFromXVector(dbFromAudio, similarity);
              } else {
                print('⚠️ Uint8 X-vector mismatch: similarity ${similarity.toStringAsFixed(3)} < threshold $_similarityThreshold');
              }
            }
          });
        } else {
          print('⚠️ Uint8 No sample recorded: Cannot perform x-vector matching');
        }
      }
    } catch (e) {
      print('⚠️ Uint8 audio data processing error: $e');
    }
  }
  
  /// Extract x-vector embedding from Uint8 audio data
  Future<List<double>> _extractCurrentEmbeddingFromUint8(Uint8List audioData) async {
    try {
      // Convert Uint8 to Float32
      Float32List floatData = Float32List(audioData.length ~/ 4);
      for (int i = 0; i < floatData.length; i++) {
        int offset = i * 4;
        floatData[i] = _bytesToFloat32(audioData, offset);
      }
      
      // Convert to List<double> and extract embedding
      List<double> combinedAudio = floatData.toList();
      return await _extractXVectorEmbedding(combinedAudio);
    } catch (e) {
      print('⚠️ Error extracting current embedding from Uint8: $e');
      return [];
    }
  }
  
  /// Calculate RMS energy from single Float32List
  double _calculateRMSEnergyFromList(Float32List audioData) {
    if (audioData.isEmpty) return 0.0;
    
    double sum = 0.0;
    for (var sample in audioData) {
      sum += sample * sample;
    }
    
    return sqrt(sum / audioData.length);
  }
  
  /// Convert bytes to Float32
  double _bytesToFloat32(Uint8List bytes, int offset) {
    ByteData byteData = ByteData.view(bytes.buffer, offset, 4);
    return byteData.getFloat32(0, Endian.little);
  }
  
  /// Process amplitude with x-vector matching
  void _processAmplitudeWithXVector(double amplitudeDb, List<Float32List> audioData) {
    try {
      // First step: Amplitude already passed (amplitudeDb > _dbThreshold)
      print('🎤 Amplitude step passed: ${amplitudeDb.toStringAsFixed(1)} dB > threshold $_dbThreshold');
      
      // Second step: Extract x-vector embedding and calculate similarity
      _extractCurrentEmbedding(audioData).then((currentEmbedding) {
        if (currentEmbedding.isNotEmpty) {
          double similarity = _calculateXVectorSimilarity(currentEmbedding);
          
          _lastDetectedSimilarity = similarity; // Update for UI display
          print('🎤 Amplitude + X-vector step: Similarity ${similarity.toStringAsFixed(3)} (threshold: $_similarityThreshold)');
          
          // Final check: Both amplitude and x-vector matching passed
          if (similarity > _similarityThreshold) {
            _checkStrikeFromXVector(amplitudeDb, similarity);
          } else {
            print('⚠️ Amplitude + X-vector mismatch: similarity ${similarity.toStringAsFixed(3)} < threshold $_similarityThreshold');
          }
        }
      });
    } catch (e) {
      print('⚠️ Amplitude with x-vector matching error: $e');
    }
  }
  
  /// Process amplitude with x-vector matching for Uint8 data
  void _processAmplitudeWithXVectorUint8(double amplitudeDb, Uint8List audioData) {
    try {
      // First step: Amplitude already passed (amplitudeDb > _dbThreshold)
      print('🎤 Uint8 Amplitude step passed: ${amplitudeDb.toStringAsFixed(1)} dB > threshold $_dbThreshold');
      
      // Second step: Extract x-vector embedding and calculate similarity
      _extractCurrentEmbeddingFromUint8(audioData).then((currentEmbedding) {
        if (currentEmbedding.isNotEmpty) {
          double similarity = _calculateXVectorSimilarity(currentEmbedding);
          
          _lastDetectedSimilarity = similarity; // Update for UI display
          print('🎤 Uint8 Amplitude + X-vector step: Similarity ${similarity.toStringAsFixed(3)} (threshold: $_similarityThreshold)');
          
          // Final check: Both amplitude and x-vector matching passed
          if (similarity > _similarityThreshold) {
            _checkStrikeFromXVector(amplitudeDb, similarity);
          } else {
            print('⚠️ Uint8 Amplitude + X-vector mismatch: similarity ${similarity.toStringAsFixed(3)} < threshold $_similarityThreshold');
          }
        }
      });
    } catch (e) {
      print('⚠️ Uint8 Amplitude with x-vector matching error: $e');
    }
  }
  
  /// Check strike from x-vector matching - Final step
  void _checkStrikeFromXVector(double db, double similarity) {
    final now = DateTime.now();
    
    // Final validation: Both amplitude and x-vector matching must pass
    if (db > _dbThreshold && similarity > _similarityThreshold) {
      // Determine detection source and use appropriate time interval
      bool isFromAmplitude = (db == _currentDb);
      int requiredInterval = isFromAmplitude ? _minStrikeInterval : _audioDataStrikeInterval;
      
      if (_lastStrikeTime == null || 
          now.difference(_lastStrikeTime!).inMilliseconds > requiredInterval) {
        
        _lastStrikeTime = now;
        _hitCount++;
        
        // Determine detection source for better logging
        String detectionSource = isFromAmplitude ? "Amplitude + X-vector" : "Audio Data + X-vector";
        String intervalInfo = isFromAmplitude ? "200ms" : "300ms";
        
        print('🎵 ✅ XVECTOR STRIKE DETECTED!');
        print('   Source: $detectionSource (Interval: $intervalInfo)');
        print('   Step 1: Amplitude ✓ (${db.toStringAsFixed(1)} dB > ${isFromAmplitude ? _dbThreshold : _audioDataThreshold})');
        print('   Step 2: X-vector Match ✓ (${similarity.toStringAsFixed(3)} > $_similarityThreshold)');
        print('   Count: $_hitCount');
        
        onStrikeDetected?.call();
      } else {
        final timeSinceLast = now.difference(_lastStrikeTime!).inMilliseconds;
        String intervalInfo = isFromAmplitude ? "200ms" : "300ms";
        print('⚠️ X-vector strike ignored (too soon): Time since last: ${timeSinceLast}ms (required: $intervalInfo)');
      }
    } else {
      print('⚠️ X-vector validation failed: dB=${db.toStringAsFixed(1)}, similarity=${similarity.toStringAsFixed(3)}');
    }
  }
  
  /// Set similarity threshold
  void setSimilarityThreshold(double threshold) {
    _similarityThreshold = threshold.clamp(0.0, 1.0);
    print('🎵 X-vector similarity threshold set to: $_similarityThreshold');
  }
  
  /// Set audio processing mode
  void setAudioMode({bool interleaved = false, Codec codec = Codec.pcmFloat32}) {
    _interleaved = interleaved;
    _codecSelected = codec;
    print('🎵 XVector audio mode set: interleaved=$interleaved, codec=$codec');
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
  int get audioBufferSize => _interleaved ? _audioBufferUint8.length : _audioBuffer.length;
  
  /// Get sample embedding size
  int get sampleEmbeddingSize => _sampleEmbedding.length;
  
  /// Get similarity threshold
  double get similarityThreshold => _similarityThreshold;
  
  /// Get last detected similarity (for UI display)
  double _lastDetectedSimilarity = 0.0;
  double get lastDetectedSimilarity => _lastDetectedSimilarity;
  
  /// Reset hit count
  void resetHitCount() {
    _hitCount = 0;
    _lastStrikeTime = null;
    print('🎯 XVector hit count reset to 0');
  }
  
  /// Clear sample embedding
  void clearSampleEmbedding() {
    _sampleEmbedding.clear();
    _sampleSpectralFeatures.clear();
    print('🎵 Sample embedding cleared');
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
      _audioDataControllerUint8?.close();
      _voiceMatch.dispose();
      _recorder.closeRecorder();
      _player.closePlayer();
      print('🎯 XVector audio detector disposed');
    } catch (e) {
      _handleError('Error disposing XVector audio detector: $e');
    }
  }
}