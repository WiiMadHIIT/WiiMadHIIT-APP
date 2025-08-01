 import 'dart:async';
import 'package:flutter/material.dart';
import 'tone_specific_audio_detector.dart';

class ToneSpecificAudioDetectorExample extends StatefulWidget {
  const ToneSpecificAudioDetectorExample({super.key});

  @override
  State<ToneSpecificAudioDetectorExample> createState() => _ToneSpecificAudioDetectorExampleState();
}

class _ToneSpecificAudioDetectorExampleState extends State<ToneSpecificAudioDetectorExample> {
  final ToneSpecificAudioDetector _detector = ToneSpecificAudioDetector();
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isRecordingSample = false;
  bool _hasSample = false;
  int _hitCount = 0;
  double _currentDb = 0.0;
  double _currentSimilarity = 0.8;
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
      });
      print('🎯 Tone specific strike detected! Count: $_hitCount');
    };
    
    _detector.onSampleRecorded = () {
      setState(() {
        _hasSample = true;
        _status = 'Sample recorded successfully';
      });
      print('🎵 Sample recorded successfully');
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
      _status = 'Initializing...';
    });
    
    final success = await _detector.initialize();
    setState(() {
      _isInitialized = success;
      _status = success ? 'Initialized' : 'Initialization failed';
    });
  }
  
  Future<void> _recordToneSample() async {
    if (!_isInitialized) {
      await _initializeDetector();
    }
    
    if (!_isInitialized) return;
    
    setState(() {
      _isRecordingSample = true;
      _recordingProgress = 0.0;
      _status = 'Recording tone sample...';
    });
    
    _recordingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingProgress += 0.1 / 3.0;
        if (_recordingProgress >= 1.0) {
          _recordingProgress = 1.0;
          timer.cancel();
        }
      });
    });
    
    final success = await _detector.recordToneSample(duration: Duration(seconds: 3));
    
    _recordingTimer?.cancel();
    _recordingTimer = null;
    
    setState(() {
      _isRecordingSample = false;
      _recordingProgress = 0.0;
      if (success) {
        _hasSample = true;
        _status = 'Sample recorded successfully';
      } else {
        _status = 'Sample recording failed';
      }
    });
  }
  
  Future<void> _startListening() async {
    if (!_isInitialized) {
      await _initializeDetector();
    }
    
    if (!_hasSample) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please record a tone sample first')),
      );
      return;
    }
    
    setState(() {
      _status = 'Starting tone detection...';
    });
    
    final success = await _detector.startListening();
    setState(() {
      _isListening = success;
      _status = success ? 'Listening for specific tone' : 'Failed to start';
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
    _detector.clearSampleFeatures();
    setState(() {
      _hasSample = false;
      _status = 'Sample cleared';
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
        title: Text('Tone Specific Audio Detector'),
        backgroundColor: Colors.purple,
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
                      'Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('State: $_status'),
                    Text('Initialized: $_isInitialized'),
                    Text('Has Sample: $_hasSample'),
                    Text('Listening: $_isListening'),
                    Text('Recording Sample: $_isRecordingSample'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Sample Recording Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tone Sample',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Sample Features: ${_detector.sampleFeaturesCount}'),
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
                            onPressed: _isRecordingSample ? null : _recordToneSample,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Record Sample'),
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
                      'Audio Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Current dB: ${_currentDb.toStringAsFixed(1)}'),
                    Text('Hit Count: $_hitCount'),
                    Text('Audio Buffer Size: $_audioBufferSize'),
                    Text('Similarity Threshold: ${_currentSimilarity.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Similarity Threshold Slider
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Similarity Threshold',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Adjust how similar the detected sound must be to the sample'),
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
                      'Controls',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    ElevatedButton(
                      onPressed: _isInitialized ? null : _initializeDetector,
                      child: Text('Initialize Detector'),
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
                      'Instructions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Initialize the detector'),
                    Text('2. Record a tone sample (3 seconds)'),
                    Text('3. Adjust similarity threshold if needed'),
                    Text('4. Start tone detection'),
                    Text('5. Make the same sound as the sample'),
                    Text('6. Watch for tone-matched strikes'),
                    Text('7. Stop detection when done'),
                    SizedBox(height: 8),
                    Text(
                      '💡 Tip: Record a clear, consistent sound as your sample for best results!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
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