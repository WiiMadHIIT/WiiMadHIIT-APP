import 'package:flutter/material.dart';
import 'xvector_audio_detector.dart';

/// XVector Audio Detector 使用示例
/// 展示如何在 Flutter 应用中使用基于 x-vector 的音频检测器
class XVectorAudioDetectorExample extends StatefulWidget {
  const XVectorAudioDetectorExample({Key? key}) : super(key: key);

  @override
  State<XVectorAudioDetectorExample> createState() => _XVectorAudioDetectorExampleState();
}

class _XVectorAudioDetectorExampleState extends State<XVectorAudioDetectorExample> {
  final XVectorAudioDetector _detector = XVectorAudioDetector();
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isRecordingSample = false;
  int _hitCount = 0;
  double _currentDb = 0.0;
  double _lastSimilarity = 0.0;
  String _status = '未初始化';

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
      print('🎯 Strike detected! Total: $_hitCount');
    };

    _detector.onSampleRecorded = () {
      setState(() {
        _isRecordingSample = false;
        _status = '样本录制完成';
      });
      print('🎵 Sample recorded successfully');
    };

    _detector.onError = (error) {
      setState(() {
        _status = '错误: $error';
      });
      print('❌ Error: $error');
    };

    _detector.onStatusUpdate = (status) {
      setState(() {
        _status = status;
      });
      print('📊 Status: $status');
    };
  }

  Future<void> _initializeDetector() async {
    setState(() {
      _status = '正在初始化...';
    });

    bool success = await _detector.initialize();
    
    setState(() {
      _isInitialized = success;
      _status = success ? '初始化完成' : '初始化失败';
    });
  }

  Future<void> _recordSample() async {
    if (!_isInitialized) {
      _showSnackBar('请先初始化检测器');
      return;
    }

    setState(() {
      _isRecordingSample = true;
      _status = '正在录制样本...';
    });

    bool success = await _detector.recordToneSample(duration: const Duration(seconds: 5));
    
    if (!success) {
      setState(() {
        _isRecordingSample = false;
        _status = '样本录制失败';
      });
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      _showSnackBar('请先初始化检测器');
      return;
    }

    if (_detector.sampleEmbeddingSize == 0) {
      _showSnackBar('请先录制样本');
      return;
    }

    bool success = await _detector.startListening();
    
    setState(() {
      _isListening = success;
      _status = success ? '正在监听...' : '启动监听失败';
    });

    if (success) {
      _startStatusUpdates();
    }
  }

  Future<void> _stopListening() async {
    await _detector.stopListening();
    
    setState(() {
      _isListening = false;
      _status = '已停止监听';
    });
  }

  void _startStatusUpdates() {
    // 定期更新状态信息
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isListening) {
        setState(() {
          _currentDb = _detector.currentDb;
          _lastSimilarity = _detector.lastDetectedSimilarity;
        });
        _startStatusUpdates();
      }
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
      _status = '样本已清除';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XVector 音频检测器示例'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '状态: $_status',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('初始化: ${_isInitialized ? "是" : "否"}'),
                    Text('监听中: ${_isListening ? "是" : "否"}'),
                    Text('录制样本: ${_isRecordingSample ? "是" : "否"}'),
                    Text('样本特征数: ${_detector.sampleEmbeddingSize}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 实时数据显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '实时数据',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('当前分贝: ${_currentDb.toStringAsFixed(1)} dB'),
                    Text('最后相似度: ${_lastSimilarity.toStringAsFixed(3)}'),
                    Text('检测次数: $_hitCount'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 控制按钮
            ElevatedButton(
              onPressed: _isInitialized ? null : _initializeDetector,
              child: const Text('初始化检测器'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isInitialized && !_isRecordingSample && !_isListening ? _recordSample : null,
              child: Text(_isRecordingSample ? '录制中...' : '录制样本 (5秒)'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isInitialized && !_isListening && _detector.sampleEmbeddingSize > 0 ? _startListening : null,
              child: const Text('开始监听'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isListening ? _stopListening : null,
              child: const Text('停止监听'),
            ),
            
            const SizedBox(height: 16),
            
            // 重置按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetCount,
                    style: ElevatedButton.styleFrom(surfaceTintColor: Colors.orange),
                    child: const Text('重置计数'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearSample,
                    style: ElevatedButton.styleFrom(surfaceTintColor: Colors.red),
                    child: const Text('清除样本'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 使用说明
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使用说明',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. 点击"初始化检测器"'),
                    Text('2. 点击"录制样本"录制目标音色'),
                    Text('3. 点击"开始监听"开始实时检测'),
                    Text('4. 当检测到相似音色时会自动计数'),
                    Text('5. 使用"重置计数"或"清除样本"管理数据'),
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
