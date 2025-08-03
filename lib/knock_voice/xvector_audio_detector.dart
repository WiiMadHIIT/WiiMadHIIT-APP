import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'voice_match.dart';

/// XVector Audio Detector - X向量音频检测器
/// 使用 x-vector TFLite 模型进行实时语音特征匹配检测
/// 结合振幅检测和语音嵌入向量相似度计算
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

  // Voice matching
  final VoiceMatch _voiceMatch = VoiceMatch();

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
  static const int _sampleRate = 16000; // x-vector 要求 16kHz
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

  // Voice matching parameters
  List<double> _sampleEmbedding = [];
  double _similarityThreshold = 0.8; // 相似度阈值
  bool _voiceMatchLoaded = false;

  // Audio processing mode
  bool _interleaved = false;
  Codec _codecSelected = Codec.pcmFloat32;

  /// Initialize detector
  Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        _updateStatus('XVector audio detector already initialized');
        print('🎯 XVector audio detector already initialized');
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

      // Load x-vector model
      print('🎯 Loading x-vector TFLite model...');
      _voiceMatchLoaded = await _voiceMatch.loadModel();
      if (!_voiceMatchLoaded) {
        throw Exception('Failed to load x-vector model');
      }

      // Set subscription duration
      await _recorder.setSubscriptionDuration(_subscriptionDuration);
      print('🎯 Subscription duration set to ${_subscriptionDuration.inMilliseconds}ms');

      _isInitialized = true;
      _updateStatus('XVector audio detector initialized');
      print('🎯 XVector audio detector initialized successfully');
      return true;
    } catch (e) {
      print('❌ Failed to initialize xvector audio detector: $e');
      _handleError('Failed to initialize xvector audio detector: $e');
      return false;
    }
  }

  /// Record voice sample for matching
  Future<bool> recordVoiceSample({Duration duration = const Duration(seconds: 5)}) async {
    if (!_isInitialized) {
      _handleError('XVector audio detector not initialized');
      return false;
    }

    if (!_voiceMatchLoaded) {
      _handleError('X-vector model not loaded');
      return false;
    }

    if (_isRecordingSample) {
      print('🎯 Already recording voice sample');
      return false;
    }

    try {
      _isRecordingSample = true;
      _sampleBuffer.clear();
      _updateStatus('Recording voice sample...');

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

      print('🎯 Recording voice sample for ${duration.inSeconds} seconds...');

      // Record for specified duration
      await Future.delayed(duration);

      // Stop recording
      await _recorder.stopRecorder();
      await _audioDataController?.close();
      _audioDataController = null;

      // Extract voice embedding from sample
      await _extractSampleEmbedding();

      _isRecordingSample = false;
      _updateStatus('Voice sample recorded and embedding extracted');
      onSampleRecorded?.call();

      print('🎯 Voice sample recorded successfully. Embedding: ${_sampleEmbedding.length} dimensions');
      return true;
    } catch (e) {
      _isRecordingSample = false;
      print('❌ Failed to record voice sample: $e');
      _handleError('Failed to record voice sample: $e');
      return false;
    }
  }

  /// Extract voice embedding from recorded sample
  Future<void> _extractSampleEmbedding() async {
    if (_sampleBuffer.isEmpty) return;

    try {
      // Combine all audio data
      List<double> combinedAudio = [];
      for (var audioData in _sampleBuffer) {
        for (var channel in audioData) {
          combinedAudio.addAll(channel);
        }
      }

      print('🎵 Extracting voice embedding from ${combinedAudio.length} samples...');

      // Extract embedding using x-vector model
      _sampleEmbedding = await _voiceMatch.extractEmbeddingFromAudioData(
          combinedAudio,
          sampleRate: _sampleRate
      );

      print('🎵 Voice embedding extracted: ${_sampleEmbedding.length} dimensions');
    } catch (e) {
      print('⚠️ Error extracting voice embedding: $e');
      rethrow;
    }
  }

  /// Start listening to microphone input with voice matching
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
      _handleError('No voice sample recorded. Please record a sample first.');
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
          _processAudioDataUint8WithVoiceMatching(buf);
        });
      } else {
        _audioDataController = StreamController<List<Float32List>>();
        _audioDataController!.stream.listen((audioData) {
          _audioBuffer.add(audioData);
          _processAudioDataWithVoiceMatching(audioData);
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
      } else if (_codecSelected == Codec.pcmFloat32) {
        await _recorder.startRecorder(
          codec: _codecSelected,
          sampleRate: _sampleRate,
          numChannels: _numChannels,
          audioSource: AudioSource.defaultSource,
          toStreamFloat32: _audioDataController!.sink,
          bufferSize: _bufferSize,
        );
      } else if (_codecSelected == Codec.pcm16) {
        await _recorder.startRecorder(
          codec: _codecSelected,
          sampleRate: _sampleRate,
          numChannels: _numChannels,
          audioSource: AudioSource.defaultSource,
          bufferSize: _bufferSize,
        );
      }

      _isListening = true;
      _updateStatus('Started listening with voice matching');

      // Subscribe to amplitude data
      _amplitudeSubscription = _recorder.onProgress!.listen((e) {
        _processAmplitudeData(e);
      });

      print('🎯 XVector audio detection started successfully');
      return true;
    } catch (e) {
      print('❌ Failed to start xvector audio detection: $e');
      _handleError('Failed to start xvector audio detection: $e');
      return false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      print('🎯 Stopping xvector audio detection...');

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
      _handleError('Failed to stop xvector audio detection: $e');
    }
  }

  /// Process amplitude data - Two-step detection
  void _processAmplitudeData(RecordingDisposition e) {
    try {
      _currentDb = e.decibels ?? 0.0;

      // First step: Check if amplitude is high enough (lower threshold for amplitude)
      if (_currentDb > _dbThreshold) {
        print('🎤 Amplitude threshold passed: ${_currentDb.toStringAsFixed(1)} dB (threshold: $_dbThreshold)');

        // Second step: Check if we have sample embedding for voice matching
        if (_sampleEmbedding.isNotEmpty) {
          // For amplitude detection, we need to get current audio data for voice matching
          if (_audioBuffer.isNotEmpty) {
            // Use the latest audio data for voice matching
            List<Float32List> latestAudioData = _audioBuffer.last;
            _processAmplitudeWithVoiceMatching(_currentDb, latestAudioData);
          } else if (_audioBufferUint8.isNotEmpty) {
            // Use the latest Uint8 audio data for voice matching
            Uint8List latestAudioData = _audioBufferUint8.last;
            _processAmplitudeWithVoiceMatchingUint8(_currentDb, latestAudioData);
          } else {
            // No audio data available, cannot perform voice matching
            print('🎤 Amplitude detected but no audio data available for voice matching - skipping detection');
          }
        } else {
          print('⚠️ Amplitude detected but no sample recorded: Cannot perform voice matching');
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

  /// Process audio data with voice matching - Two-step detection
  void _processAudioDataWithVoiceMatching(List<Float32List> audioData) {
    try {
      // Calculate RMS energy
      double rmsEnergy = _calculateRMSEnergy(audioData);
      double dbFromAudio = _rmsToDecibels(rmsEnergy);

      // First step: Check if audio level is high enough (higher threshold for audio data)
      if (dbFromAudio > _audioDataThreshold) {
        print('🎵 First step passed: Audio level ${dbFromAudio.toStringAsFixed(1)} dB > threshold $_audioDataThreshold');

        // Second step: Check if we have sample embedding for voice matching
        if (_sampleEmbedding.isNotEmpty) {
          // Extract voice embedding from current audio
          _extractAndCompareVoiceEmbedding(audioData, dbFromAudio);
        } else {
          print('⚠️ No sample recorded: Cannot perform voice matching');
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

  /// Extract voice embedding and compare with sample
  Future<void> _extractAndCompareVoiceEmbedding(List<Float32List> audioData, double dbFromAudio) async {
    try {
      // Combine audio data
      List<double> combinedAudio = [];
      for (var channel in audioData) {
        combinedAudio.addAll(channel);
      }

      // Extract voice embedding using x-vector model
      List<double> currentEmbedding = await _voiceMatch.extractEmbeddingFromAudioData(
          combinedAudio,
          sampleRate: _sampleRate
      );

      // Calculate similarity with sample
      double similarity = _voiceMatch.normalizedCosineSimilarity(_sampleEmbedding, currentEmbedding);

      _lastDetectedSimilarity = similarity; // Update for UI display
      print('🎵 Second step: Voice similarity ${similarity.toStringAsFixed(3)} (threshold: $_similarityThreshold)');

      // Final check: Both amplitude and voice matching passed
      if (similarity > _similarityThreshold) {
        _checkStrikeFromVoiceMatching(dbFromAudio, similarity);
      } else {
        print('⚠️ Voice mismatch: similarity ${similarity.toStringAsFixed(3)} < threshold $_similarityThreshold');
      }
    } catch (e) {
      print('⚠️ Voice embedding extraction error: $e');
    }
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

  /// Convert bytes to Float32
  double _bytesToFloat32(Uint8List bytes, int offset) {
    ByteData byteData = ByteData.view(bytes.buffer, offset, 4);
    return byteData.getFloat32(0, Endian.little);
  }

  /// Process Uint8 audio data with voice matching - Two-step detection
  void _processAudioDataUint8WithVoiceMatching(Uint8List audioData) {
    try {
      // Calculate RMS energy from Uint8 data
      Float32List floatData = Float32List(audioData.length ~/ 4);
      for (int i = 0; i < floatData.length; i++) {
        int offset = i * 4;
        floatData[i] = _bytesToFloat32(audioData, offset);
      }

      double rmsEnergy = _calculateRMSEnergyFromList(floatData);
      double dbFromAudio = _rmsToDecibels(rmsEnergy);

      // First step: Check if audio level is high enough (higher threshold for audio data)
      if (dbFromAudio > _audioDataThreshold) {
        print('🎵 Uint8 First step passed: Audio level ${dbFromAudio.toStringAsFixed(1)} dB > threshold $_audioDataThreshold');

        // Second step: Check if we have sample embedding for voice matching
        if (_sampleEmbedding.isNotEmpty) {
          // Convert Uint8 to List<double> for voice matching
          List<double> combinedAudio = floatData.toList();
          _extractAndCompareVoiceEmbeddingUint8(combinedAudio, dbFromAudio);
        } else {
          print('⚠️ Uint8 No sample recorded: Cannot perform voice matching');
        }
      }
    } catch (e) {
      print('⚠️ Uint8 audio data processing error: $e');
    }
  }

  /// Extract voice embedding and compare with sample for Uint8 data
  Future<void> _extractAndCompareVoiceEmbeddingUint8(List<double> audioData, double dbFromAudio) async {
    try {
      // Extract voice embedding using x-vector model
      List<double> currentEmbedding = await _voiceMatch.extractEmbeddingFromAudioData(
          audioData,
          sampleRate: _sampleRate
      );

      // Calculate similarity with sample
      double similarity = _voiceMatch.normalizedCosineSimilarity(_sampleEmbedding, currentEmbedding);

      _lastDetectedSimilarity = similarity; // Update for UI display
      print('🎵 Uint8 Second step: Voice similarity ${similarity.toStringAsFixed(3)} (threshold: $_similarityThreshold)');

      // Final check: Both amplitude and voice matching passed
      if (similarity > _similarityThreshold) {
        _checkStrikeFromVoiceMatching(dbFromAudio, similarity);
      } else {
        print('⚠️ Uint8 Voice mismatch: similarity ${similarity.toStringAsFixed(3)} < threshold $_similarityThreshold');
      }
    } catch (e) {
      print('⚠️ Uint8 Voice embedding extraction error: $e');
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

  /// Process amplitude with voice matching - Two-step detection
  void _processAmplitudeWithVoiceMatching(double amplitudeDb, List<Float32List> audioData) {
    try {
      // First step: Amplitude already passed (amplitudeDb > _dbThreshold)
      print('🎤 Amplitude step passed: ${amplitudeDb.toStringAsFixed(1)} dB > threshold $_dbThreshold');

      // Second step: Extract voice embedding and calculate similarity
      _extractAndCompareVoiceEmbedding(audioData, amplitudeDb);
    } catch (e) {
      print('⚠️ Amplitude with voice matching error: $e');
    }
  }

  /// Process amplitude with voice matching for Uint8 data - Two-step detection
  void _processAmplitudeWithVoiceMatchingUint8(double amplitudeDb, Uint8List audioData) {
    try {
      // First step: Amplitude already passed (amplitudeDb > _dbThreshold)
      print('🎤 Uint8 Amplitude step passed: ${amplitudeDb.toStringAsFixed(1)} dB > threshold $_dbThreshold');

      // Second step: Convert Uint8 to List<double> and extract voice embedding
      Float32List floatData = Float32List(audioData.length ~/ 4);
      for (int i = 0; i < floatData.length; i++) {
        int offset = i * 4;
        floatData[i] = _bytesToFloat32(audioData, offset);
      }

      List<double> combinedAudio = floatData.toList();
      _extractAndCompareVoiceEmbeddingUint8(combinedAudio, amplitudeDb);
    } catch (e) {
      print('⚠️ Uint8 Amplitude with voice matching error: $e');
    }
  }

  /// Check strike from voice matching - Final step
  void _checkStrikeFromVoiceMatching(double db, double similarity) {
    final now = DateTime.now();

    // Final validation: Both amplitude and voice matching must pass
    // Note: db can come from either amplitude (50.0 threshold) or audio data (60.0 threshold)
    if (db > _dbThreshold && similarity > _similarityThreshold) {
      // Determine detection source and use appropriate time interval
      bool isFromAmplitude = (db == _currentDb);
      int requiredInterval = isFromAmplitude ? _minStrikeInterval : _audioDataStrikeInterval;

      if (_lastStrikeTime == null || 
          now.difference(_lastStrikeTime!).inMilliseconds > requiredInterval) {

        _lastStrikeTime = now;
        _hitCount++;

        // Determine detection source for better logging
        String detectionSource = isFromAmplitude ? "Amplitude + Voice Embedding" : "Audio Data + Voice Embedding";
        String intervalInfo = isFromAmplitude ? "200ms" : "300ms";

        print('🎵 ✅ XVECTOR STRIKE DETECTED!');
        print('   Source: $detectionSource (Interval: $intervalInfo)');
        print('   Step 1: Amplitude ✓ (${db.toStringAsFixed(1)} dB > ${isFromAmplitude ? _dbThreshold : _audioDataThreshold})');
        print('   Step 2: Voice Match ✓ (${similarity.toStringAsFixed(3)} > $_similarityThreshold)');
        print('   Count: $_hitCount');

        onStrikeDetected?.call();
      } else {
        final timeSinceLast = now.difference(_lastStrikeTime!).inMilliseconds;
        String intervalInfo = isFromAmplitude ? "200ms" : "300ms";
        print('⚠️ XVector strike ignored (too soon): Time since last: ${timeSinceLast}ms (required: $intervalInfo)');
      }
    } else {
      print('⚠️ XVector validation failed: dB=${db.toStringAsFixed(1)}, similarity=${similarity.toStringAsFixed(3)}');
    }
  }

  /// Set similarity threshold
  void setSimilarityThreshold(double threshold) {
    _similarityThreshold = threshold.clamp(0.0, 1.0);
    print('🎵 Voice similarity threshold set to: $_similarityThreshold');
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

  /// Get sample embedding count
  int get sampleEmbeddingCount => _sampleEmbedding.length;

  /// Get similarity threshold
  double get similarityThreshold => _similarityThreshold;

  /// Get last detected similarity (for UI display)
  double _lastDetectedSimilarity = 0.0;
  double get lastDetectedSimilarity => _lastDetectedSimilarity;

  /// Get voice match model status
  bool get voiceMatchLoaded => _voiceMatchLoaded;

  /// Reset hit count
  void resetHitCount() {
    _hitCount = 0;
    _lastStrikeTime = null;
    print('🎯 XVector hit count reset to 0');
  }

  /// Clear sample embedding
  void clearSampleEmbedding() {
    _sampleEmbedding.clear();
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
      _recorder.closeRecorder();
      _player.closePlayer();
      _voiceMatch.dispose();
      print('🎯 XVector audio detector disposed');
    } catch (e) {
      _handleError('Error disposing xvector audio detector: $e');
    }
  }
}