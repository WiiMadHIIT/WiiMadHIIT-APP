import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'real_audio_detector.dart';

/// 音频测试辅助类
/// 用于调试和验证音频检测功能
class AudioTestHelper {
  static RealAudioDetector? _testDetector;
  static Timer? _testTimer;
  static int _testHitCount = 0;
  static List<double> _dbHistory = [];
  static bool _isTestRunning = false;
  
  /// 开始音频检测测试
  static Future<bool> startAudioTest({
    int durationSeconds = 30,
    Function(String)? onLog,
    Function(int)? onHitCount,
    Function(double)? onDbLevel,
  }) async {
    if (_isTestRunning) {
      onLog?.call('⚠️ Audio test already running');
      return false;
    }
    
    try {
      _isTestRunning = true;
      _testHitCount = 0;
      _dbHistory.clear();
      
      onLog?.call('🎯 Starting audio detection test...');
      
      // 创建测试检测器
      _testDetector = RealAudioDetector();
      
      // 设置回调
      _testDetector!.onStrikeDetected = () {
        _testHitCount++;
        onLog?.call('🎯 STRIKE DETECTED! Count: $_testHitCount');
        onHitCount?.call(_testHitCount);
      };
      
      _testDetector!.onError = (error) {
        onLog?.call('❌ Audio detection error: $error');
      };
      
      _testDetector!.onStatusUpdate = (status) {
        onLog?.call('📊 Status: $status');
      };
      
      // 初始化检测器
      onLog?.call('🎯 Initializing audio detector...');
      final initSuccess = await _testDetector!.initialize();
      if (!initSuccess) {
        onLog?.call('❌ Failed to initialize audio detector');
        return false;
      }
      
      // 启动监听
      onLog?.call('🎯 Starting audio listening...');
      final listenSuccess = await _testDetector!.startListening();
      if (!listenSuccess) {
        onLog?.call('❌ Failed to start audio listening');
        return false;
      }
      
      onLog?.call('✅ Audio test started successfully');
      onLog?.call('🎯 Test will run for $durationSeconds seconds');
      onLog?.call('🎯 Make some noise to test strike detection!');
      
      // 启动定时器监控分贝值
      _testTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (_testDetector != null) {
          final currentDb = _testDetector!.currentDb;
          _dbHistory.add(currentDb);
          
          // 只保留最近100个数据点
          if (_dbHistory.length > 100) {
            _dbHistory.removeAt(0);
          }
          
          onDbLevel?.call(currentDb);
          
          // 每5秒输出一次统计信息
          if (timer.tick % 10 == 0) {
            _printTestStats(onLog);
          }
        }
      });
      
      // 设置测试结束定时器
      Timer(Duration(seconds: durationSeconds), () {
        stopAudioTest(onLog: onLog);
      });
      
      return true;
      
    } catch (e) {
      onLog?.call('❌ Error starting audio test: $e');
      _isTestRunning = false;
      return false;
    }
  }
  
  /// 停止音频检测测试
  static Future<void> stopAudioTest({Function(String)? onLog}) async {
    try {
      _isTestRunning = false;
      
      // 停止定时器
      _testTimer?.cancel();
      _testTimer = null;
      
      // 停止检测器
      if (_testDetector != null) {
        await _testDetector!.stopListening();
        _testDetector!.dispose();
        _testDetector = null;
      }
      
      // 输出最终统计信息
      _printTestStats(onLog);
      
      onLog?.call('✅ Audio test completed');
      
    } catch (e) {
      onLog?.call('❌ Error stopping audio test: $e');
    }
  }
  
  /// 打印测试统计信息
  static void _printTestStats(Function(String)? onLog) {
    if (_dbHistory.isEmpty) return;
    
    final avgDb = _dbHistory.reduce((a, b) => a + b) / _dbHistory.length;
    final maxDb = _dbHistory.reduce((a, b) => a > b ? a : b);
    final minDb = _dbHistory.reduce((a, b) => a < b ? a : b);
    
    onLog?.call('📊 Test Stats:');
    onLog?.call('  - Hit Count: $_testHitCount');
    onLog?.call('  - Avg dB: ${avgDb.toStringAsFixed(1)}');
    onLog?.call('  - Max dB: ${maxDb.toStringAsFixed(1)}');
    onLog?.call('  - Min dB: ${minDb.toStringAsFixed(1)}');
    onLog?.call('  - Samples: ${_dbHistory.length}');
  }
  
  /// 获取当前测试状态
  static bool get isTestRunning => _isTestRunning;
  
  /// 获取当前击打次数
  static int get testHitCount => _testHitCount;
  
  /// 获取分贝历史数据
  static List<double> get dbHistory => List.from(_dbHistory);
  
  /// 重置测试数据
  static void resetTestData() {
    _testHitCount = 0;
    _dbHistory.clear();
  }
} 