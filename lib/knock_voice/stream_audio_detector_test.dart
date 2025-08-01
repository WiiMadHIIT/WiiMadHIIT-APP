import 'dart:async';
import 'stream_audio_detector.dart';

/// Test for StreamAudioDetector
/// 演示如何使用 StreamAudioDetector 进行真实的音频录制和播放
void main() async {
  print('🧪 Starting StreamAudioDetector test...');
  
  final detector = StreamAudioDetector();
  
  // Set up callbacks
  detector.onStrikeDetected = () {
    print('✅ Strike detected! Count: ${detector.hitCount}');
  };
  
  detector.onError = (error) {
    print('❌ Error: $error');
  };
  
  detector.onStatusUpdate = (status) {
    print('📝 Status: $status');
  };
  
  try {
    // Test initialization
    print('\n🔧 Testing initialization...');
    final initSuccess = await detector.initialize();
    print('Initialization result: $initSuccess');
    
    if (initSuccess) {
      // Set audio mode (optional)
      detector.setAudioMode(interleaved: false, codec: Codec.pcmFloat32);
      
      // Test start listening
      print('\n🎤 Testing start listening...');
      final startSuccess = await detector.startListening();
      print('Start listening result: $startSuccess');
      
      if (startSuccess) {
        // Let it run for 15 seconds to record audio
        print('\n⏱️ Recording for 15 seconds...');
        print('Make some sounds (clap, tap, etc.) to test detection...');
        await Future.delayed(Duration(seconds: 15));
        
        // Test stop listening
        print('\n🛑 Testing stop listening...');
        await detector.stopListening();
        print('Stop listening completed');
        
        // Show recorded audio info
        print('\n📊 Audio buffer size: ${detector.audioBufferSize}');
        print('Final hit count: ${detector.hitCount}');
        
        // Test audio playback
        if (detector.audioBufferSize > 0) {
          print('\n🎵 Testing audio playback...');
          await detector.playRecordedAudio();
          print('Audio playback completed');
        } else {
          print('\n⚠️ No audio data recorded, skipping playback test');
        }
        
        // Test reset
        print('\n🔄 Testing reset...');
        detector.resetHitCount();
        print('Reset completed. Final count: ${detector.hitCount}');
      }
    }
    
    // Test disposal
    print('\n🧹 Testing disposal...');
    detector.dispose();
    print('Disposal completed');
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
  
  print('\n✅ StreamAudioDetector test completed!');
} 