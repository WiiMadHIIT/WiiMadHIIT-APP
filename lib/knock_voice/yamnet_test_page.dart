import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'yamnet_test.dart';

/// YAMNet音频分类测试页面
class YamnetTestPage extends StatefulWidget {
  const YamnetTestPage({super.key});

  @override
  State<YamnetTestPage> createState() => _YamnetTestPageState();
}

class _YamnetTestPageState extends State<YamnetTestPage> {
  final YamnetTest _yamnetTest = YamnetTest();
  bool _isModelLoaded = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  List<MapEntry<String, double>> _results = [];
  String _statusMessage = '准备就绪';
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _yamnetTest.dispose();
    super.dispose();
  }

  /// 加载模型
  Future<void> _loadModel() async {
    try {
      setState(() {
        _statusMessage = '正在加载模型...';
      });
      
      await _yamnetTest.loadModel();
      
      setState(() {
        _isModelLoaded = true;
        _statusMessage = '模型加载完成，可以开始录音';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '模型加载失败: $e';
      });
    }
  }

  /// 请求录音权限
  Future<void> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isDenied) {
        setState(() {
          _statusMessage = '需要麦克风权限才能录音';
        });
        return;
      }
    }
  }

  /// 开始录音
  Future<void> _startRecording() async {
    try {
      await _requestPermission();
      
      await _yamnetTest.startRecording();
      
      // 开始录音计时器
      _recordingDuration = 0;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
      });
      
      setState(() {
        _isRecording = true;
        _statusMessage = '正在录音... 请说话';
        _results.clear();
      });
    } catch (e) {
      setState(() {
        _statusMessage = '录音失败: $e';
      });
    }
  }

  /// 停止录音并分类
  Future<void> _stopRecording() async {
    try {
      // 停止录音计时器
      _recordingTimer?.cancel();
      
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _statusMessage = '正在处理音频...';
      });

      // 停止录音
      List<double> audioData = await _yamnetTest.stopRecording();
      
      if (audioData.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '录音数据为空，请重新录音';
        });
        return;
      }
      
      // 分类音频
      List<MapEntry<String, double>> results = await _yamnetTest.classifyAudio(audioData);
      
      setState(() {
        _isProcessing = false;
        _results = results;
        _statusMessage = results.isNotEmpty 
            ? '识别完成，找到 ${results.length} 个类别'
            : '未识别到任何类别';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '处理失败: $e';
      });
      print('❌ Error in _stopRecording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YAMNet 音频分类测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isModelLoaded ? Icons.check_circle : Icons.error,
                      color: _isModelLoaded ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (_isRecording) ...[
                      const SizedBox(height: 8),
                      Text(
                        '录音时长: ${_recordingDuration}秒',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 录音按钮
            ElevatedButton.icon(
              onPressed: _isModelLoaded && !_isProcessing
                  ? (_isRecording ? _stopRecording : _startRecording)
                  : null,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? '停止录音' : '开始录音'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 处理指示器
            if (_isProcessing)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('正在分析音频...'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 结果显示
            if (_results.isNotEmpty) ...[
              const Text(
                '识别结果:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      var result = _results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          result.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: LinearProgressIndicator(
                          value: result.value,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            result.value > 0.5 ? Colors.green : Colors.orange,
                          ),
                        ),
                        trailing: Text(
                          '${(result.value * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ] else if (!_isProcessing && _isModelLoaded) ...[
              const Expanded(
                child: Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '点击"开始录音"按钮开始测试',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 