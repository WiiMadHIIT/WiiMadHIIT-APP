import 'package:flutter/material.dart';
import 'dart:async';
import '../../knock_voice/audio_test_helper.dart';
import '../../core/theme/app_colors.dart';

class AudioTestPage extends StatefulWidget {
  const AudioTestPage({Key? key}) : super(key: key);

  @override
  State<AudioTestPage> createState() => _AudioTestPageState();
}

class _AudioTestPageState extends State<AudioTestPage> {
  final List<String> _logs = [];
  int _hitCount = 0;
  double _currentDb = 0.0;
  bool _isTestRunning = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    AudioTestHelper.stopAudioTest(onLog: _addLog);
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $message');
      if (_logs.length > 100) {
        _logs.removeAt(0);
      }
    });
    
    // 自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startTest() async {
    setState(() {
      _isTestRunning = true;
      _hitCount = 0;
      _logs.clear();
    });

    final success = await AudioTestHelper.startAudioTest(
      durationSeconds: 30,
      onLog: _addLog,
      onHitCount: (count) {
        setState(() {
          _hitCount = count;
        });
      },
      onDbLevel: (db) {
        setState(() {
          _currentDb = db;
        });
      },
    );

    if (!success) {
      setState(() {
        _isTestRunning = false;
      });
    }
  }

  Future<void> _stopTest() async {
    await AudioTestHelper.stopAudioTest(onLog: _addLog);
    setState(() {
      _isTestRunning = false;
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Detection Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 控制面板
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // 状态显示
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusCard(
                      'Test Status',
                      _isTestRunning ? 'Running' : 'Stopped',
                      _isTestRunning ? Colors.green : Colors.red,
                    ),
                    _buildStatusCard(
                      'Hit Count',
                      '$_hitCount',
                      Colors.blue,
                    ),
                    _buildStatusCard(
                      'Current dB',
                      '${_currentDb.toStringAsFixed(1)}',
                      Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // 控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isTestRunning ? null : _startTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('Start Test'),
                    ),
                    ElevatedButton(
                      onPressed: _isTestRunning ? _stopTest : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('Stop Test'),
                    ),
                    ElevatedButton(
                      onPressed: _clearLogs,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('Clear Logs'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 日志显示
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Test Logs (${_logs.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(8),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color textColor = Colors.black87;
                        
                        if (log.contains('❌')) {
                          textColor = Colors.red;
                        } else if (log.contains('✅')) {
                          textColor = Colors.green;
                        } else if (log.contains('🎯')) {
                          textColor = Colors.blue;
                        } else if (log.contains('⚠️')) {
                          textColor = Colors.orange;
                        }
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 