import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../knock_voice/real_audio_detector.dart';
import 'dart:async'; // Added for Timer

class AudioTestPage extends StatefulWidget {
  @override
  _AudioTestPageState createState() => _AudioTestPageState();
}

class _AudioTestPageState extends State<AudioTestPage> {
  RealAudioDetector? _audioDetector;
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isReceivingAudio = false;
  int _audioDataCount = 0;
  int _hitCount = 0;
  double _currentDb = 0.0;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAudioDetection();
  }

  @override
  void dispose() {
    _audioDetector?.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioDetection() async {
    try {
      setState(() {
        _status = 'Requesting microphone permission...';
      });

      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        setState(() {
          _status = 'Microphone permission denied';
        });
        return;
      }

      setState(() {
        _status = 'Initializing audio detector...';
      });

      // Initialize audio detector
      _audioDetector = RealAudioDetector();
      
      _audioDetector!.onStrikeDetected = () {
        setState(() {
          _hitCount++;
        });
        print('🎯 Strike detected! Total hits: $_hitCount');
      };

      _audioDetector!.onError = (error) {
        setState(() {
          _status = 'Error: $error';
        });
        print('❌ Audio detection error: $error');
      };

      _audioDetector!.onStatusUpdate = (status) {
        setState(() {
          _status = status;
        });
        print('📊 Status: $status');
      };

      final success = await _audioDetector!.initialize();
      if (success) {
        setState(() {
          _isInitialized = true;
          _status = 'Ready to start listening';
        });
        print('✅ Audio detector initialized successfully');
      } else {
        setState(() {
          _status = 'Failed to initialize audio detector';
        });
        print('❌ Failed to initialize audio detector');
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
      print('❌ Error during initialization: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) return;

    try {
      if (_isListening) {
        await _audioDetector!.stopListening();
        setState(() {
          _isListening = false;
          _status = 'Stopped listening';
        });
      } else {
        final success = await _audioDetector!.startListening();
        if (success) {
          setState(() {
            _isListening = true;
            _status = 'Listening...';
          });
          
          // Start monitoring audio data
          _startAudioMonitoring();
        } else {
          setState(() {
            _status = 'Failed to start listening';
          });
        }
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
      print('❌ Error toggling listening: $e');
    }
  }

  void _startAudioMonitoring() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }
      
      if (_audioDetector != null) {
        setState(() {
          _isReceivingAudio = _audioDetector!.isReceivingAudio;
          _audioDataCount = _audioDetector!.audioDataCount;
          _currentDb = _audioDetector!.currentDb;
        });
      }
    });
  }

  void _resetCount() {
    _audioDetector?.resetHitCount();
    setState(() {
      _hitCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Detection Test'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Audio Data Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Receiving Audio:'),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isReceivingAudio ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isReceivingAudio ? 'YES' : 'NO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Data Packets:'),
                        Text(
                          '$_audioDataCount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current dB:'),
                        Text(
                          '${_currentDb.toStringAsFixed(1)} dB',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Hit Counter Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hit Counter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: _resetCount,
                          tooltip: 'Reset Count',
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        '$_hitCount',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Spacer(),
            
            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isInitialized ? _toggleListening : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isListening ? 'Stop Listening' : 'Start Listening',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Grant microphone permission\n'
                      '2. Press "Start Listening"\n'
                      '3. Make loud sounds (clap, speak loudly)\n'
                      '4. Watch the hit counter increase\n'
                      '5. Check if "Receiving Audio" shows YES',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 