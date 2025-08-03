import 'dart:async';
import 'package:flutter/material.dart';
import 'xvector_audio_detector.dart';

class XVectorAudioDetectorExample extends StatefulWidget {
  const XVectorAudioDetectorExample({super.key});

  @override
  State<XVectorAudioDetectorExample> createState() => _XVectorAudioDetectorExampleState();
}

class _XVectorAudioDetectorExampleState extends State<XVectorAudioDetectorExample> {
  final XVectorAudioDetector _detector = XVectorAudioDetector();
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isRecordingSample = false;
  bool _hasSample = false;
  bool _voiceMatchLoaded = false;
  int _hitCount = 0;
  double _currentDb = 0.0;
  double _currentSimilarity = 0.8;
  double _lastDetectedSimilarity = 0.0;
  int _audioBufferSize = 0;
  String _status = 'Not initialized';
  double _recordingProgress = 0.0;
  Timer? _recordingTimer;
  
  @override
  void initState() {
    super.initState();
    _setupDetector();
  }
  
  void _setupDetector() {
    _detector.onStrikeDetected = () {
      setState(() {
        _hitCount = _detector.hitCount;
        _lastDetectedSimilarity = _currentSimilarity;
      });
      print('🎯 XVector strike detected! Count: $_hitCount');
    };
    
    _detector.onSampleRecorded = () {
      setState(() {
        _hasSample = true;
        _status = 'Voice sample recorded successfully';
      });
      print('🎵 Voice sample recorded successfully');
    };
    
    _detector.onError = (error) {
      setState(() {
        _status = 'Error: $error';
      });
      print('❌ Error: $error');
    };
    
    _detector.onStatusUpdate = (status) {
      setState(() {
        _status = status;
      });
      print('📝 Status: $status');
    };
  }
  
  Future<void> _initializeDetector() async {
    setState(() {
      _status = 'Initializing XVector detector...';
    });
    
    final success = await _detector.initialize();
    setState(() {
      _isInitialized = success;
      _voiceMatchLoaded = _detector.voiceMatchLoaded;
      _status = success ? 'XVector detector initialized' : 'Initialization failed';
    });
    
    if (success) {
      print('✅ XVector detector initialized successfully');
    } else {
      print('❌ XVector detector initialization failed');
    }
  }
  
  Future<void> _recordVoiceSample() async {
    if (!_isInitialized) {
      await _initializeDetector();
    }
    
    if (!_isInitialized) return;
    
    if (!_voiceMatchLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('X-vector model not loaded. Please check the model file.')),
      );
      return;
    }
    
    setState(() {
      _isRecordingSample = true;
      _recordingProgress = 0.0;
      _status = 'Recording voice sample...';
    });
    
    _recordingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingProgress += 0.1 / 5.0; // 5 seconds
        if (_recordingProgress >= 1.0) {
          _recordingProgress = 1.0;
          timer.cancel();
        }
      });
    });
    
    final success = await _detector.recordVoiceSample(duration: Duration(seconds: 5));
    
    _recordingTimer?.cancel();
    _recordingTimer = null;
    
    setState(() {
      _isRecordingSample = false;
      _recordingProgress = 0.0;
      if (success) {
        _hasSample = true;
        _status = 'Voice sample recorded successfully';
      } else {
        _status = 'Voice sample recording failed';
      }
    });
  }
  
  Future<void> _startListening() async {
    if (!_isInitialized) {
      await _initializeDetector();
    }
    
    if (!_hasSample) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please record a voice sample first')),
      );
      return;
    }
    
    setState(() {
      _status = 'Starting XVector detection...';
    });
    
    final success = await _detector.startListening();
    setState(() {
      _isListening = success;
      _status = success ? 'Listening for voice match' : 'Failed to start';
    });
    
    if (success) {
      Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (!_isListening) {
          timer.cancel();
          return;
        }
        
        setState(() {
          _currentDb = _detector.currentDb;
          _audioBufferSize = _detector.audioBufferSize;
          _currentSimilarity = _detector.similarityThreshold;
          _lastDetectedSimilarity = _detector.lastDetectedSimilarity;
        });
      });
    }
  }
  
  Future<void> _stopListening() async {
    await _detector.stopListening();
    setState(() {
      _isListening = false;
      _status = 'Stopped';
    });
  }
  
  void _resetCount() {
    _detector.resetHitCount();
    setState(() {
      _hitCount = 0;
    });
  }
  
  void _clearSample() {
    _detector.clearSampleEmbedding();
    setState(() {
      _hasSample = false;
      _status = 'Voice sample cleared';
    });
  }
  
  void _adjustSimilarityThreshold(double value) {
    _detector.setSimilarityThreshold(value);
    setState(() {
      _currentSimilarity = value;
    });
  }
  
  @override
  void dispose() {
    _recordingTimer?.cancel();
    _detector.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XVector Audio Detector'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XVector Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('State: $_status'),
                    Text('Initialized: $_isInitialized'),
                    Text('Voice Match Loaded: $_voiceMatchLoaded'),
                    Text('Has Sample: $_hasSample'),
                    Text('Listening: $_isListening'),
                    Text('Recording Sample: $_isRecordingSample'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Voice Sample Recording Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Sample (X-Vector)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Sample Embedding: ${_detector.sampleEmbeddingCount} dimensions'),
                    Text('Sample Status: ${_hasSample ? 'Recorded ✓' : 'Not Recorded'}'),
                    if (_isRecordingSample) ...[
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: _recordingProgress),
                      SizedBox(height: 4),
                      Text('Recording... ${(_recordingProgress * 100).toStringAsFixed(0)}%'),
                    ],
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isRecordingSample ? null : _recordVoiceSample,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Record Voice Sample'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _hasSample ? _clearSample : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Clear Sample'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Audio Info Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XVector Audio Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Current dB: ${_currentDb.toStringAsFixed(1)}'),
                    Text('Amplitude Threshold: 50.0 dB'),
                    Text('Audio Data Threshold: 60.0 dB'),
                    Text('Amplitude Interval: 200ms'),
                    Text('Audio Data Interval: 300ms'),
                    Text('Hit Count: $_hitCount'),
                    Text('Audio Buffer Size: $_audioBufferSize'),
                    Text('Voice Similarity Threshold: ${_currentSimilarity.toStringAsFixed(2)}'),
                    Text('Detection Mode: ${_hasSample ? 'Two-Step Detection (Dual Threshold + X-Vector)' : 'No Sample'}'),
                    Text('Last Voice Similarity: ${_lastDetectedSimilarity.toStringAsFixed(3)}'),
                    Text('Model: x-vector.tflite (512-dim embeddings)'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Voice Similarity Threshold Slider
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Similarity Threshold',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Adjust how similar the detected voice must be to the sample'),
                    SizedBox(height: 8),
                    Slider(
                      value: _currentSimilarity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: _currentSimilarity.toStringAsFixed(2),
                      onChanged: _adjustSimilarityThreshold,
                    ),
                    Text('Current: ${_currentSimilarity.toStringAsFixed(2)} (${(_currentSimilarity * 100).toStringAsFixed(0)}%)'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Controls
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'XVector Controls',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    ElevatedButton(
                      onPressed: _isInitialized ? null : _initializeDetector,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isInitialized ? Colors.grey : Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isInitialized ? 'Initialized ✓' : 'Initialize XVector'),
                    ),
                    
                    SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: _isListening ? _stopListening : _startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isListening ? 'Stop Detection' : 'Start Detection'),
                    ),
                    
                    SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: _hitCount > 0 ? _resetCount : null,
                      child: Text('Reset Count'),
                    ),
                    
                    SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: _hasSample ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Test: Speak the SAME voice as your sample to see hits!'),
                            backgroundColor: Colors.indigo,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Test Instructions'),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Instructions
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XVector Instructions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Initialize the XVector detector'),
                    Text('2. Record a voice sample (5 seconds)'),
                    Text('3. Adjust voice similarity threshold if needed'),
                    Text('4. Start two-step detection'),
                    Text('5. Speak the same voice as the sample'),
                    Text('6. Watch for XVector strikes'),
                    Text('7. Stop detection when done'),
                    SizedBox(height: 8),
                    Text(
                      '🎯 Important: Two-step detection - Dual threshold (50dB/60dB) + Dual interval (200ms/300ms) + X-Vector voice matching!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '💡 Tip: Record a clear, consistent voice as your sample for best results!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🔬 Technology: Uses x-vector TFLite model for 512-dimensional voice embeddings',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 32), // Extra space at bottom
          ],
        ),
      ),
    );
  }
} 