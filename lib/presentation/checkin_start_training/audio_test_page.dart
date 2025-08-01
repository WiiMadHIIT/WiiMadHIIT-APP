import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
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

  /// 复制所有日志信息到剪贴板
  Future<void> _copyAllLogs() async {
    try {
      final StringBuffer buffer = StringBuffer();
      
      // 添加系统信息
      buffer.writeln('=== 音频检测测试报告 ===');
      buffer.writeln('生成时间: ${DateTime.now().toString()}');
      buffer.writeln('平台: ${Platform.isIOS ? 'iOS' : 'Android'}');
      buffer.writeln('测试状态: ${_isTestRunning ? '运行中' : '已停止'}');
      buffer.writeln('当前击打次数: $_hitCount');
      buffer.writeln('当前分贝值: ${_currentDb.toStringAsFixed(1)} dB');
      buffer.writeln('分贝阈值: 30.0 dB');
      buffer.writeln('日志条数: ${_logs.length}');
      buffer.writeln('');
      
      // 添加统计信息
      if (_logs.isNotEmpty) {
        buffer.writeln('=== 测试统计 ===');
        final dbValues = AudioTestHelper.dbHistory;
        if (dbValues.isNotEmpty) {
          final avgDb = dbValues.reduce((a, b) => a + b) / dbValues.length;
          final maxDb = dbValues.reduce((a, b) => a > b ? a : b);
          final minDb = dbValues.reduce((a, b) => a < b ? a : b);
          
          buffer.writeln('平均分贝: ${avgDb.toStringAsFixed(1)} dB');
          buffer.writeln('最大分贝: ${maxDb.toStringAsFixed(1)} dB');
          buffer.writeln('最小分贝: ${minDb.toStringAsFixed(1)} dB');
          buffer.writeln('样本数量: ${dbValues.length}');
        }
        buffer.writeln('');
      }
      
      // 添加详细日志
      buffer.writeln('=== 详细日志 ===');
      for (String log in _logs) {
        buffer.writeln(log);
      }
      
      // 添加问题诊断
      buffer.writeln('');
      buffer.writeln('=== 问题诊断 ===');
      if (_currentDb == 0.0 && _hitCount == 0) {
        buffer.writeln('⚠️ 检测到问题:');
        buffer.writeln('  - 分贝值始终为 0.0');
        buffer.writeln('  - 没有检测到任何击打');
        buffer.writeln('可能原因:');
        buffer.writeln('  1. 麦克风权限未授予');
        buffer.writeln('  2. 麦克风硬件问题');
        buffer.writeln('  3. iOS 音频会话配置问题');
        buffer.writeln('  4. 编解码器兼容性问题');
        buffer.writeln('  5. 环境声音太小');
        buffer.writeln('建议:');
        buffer.writeln('  - 检查麦克风权限');
        buffer.writeln('  - 尝试制造更大声音（拍手、说话）');
        buffer.writeln('  - 检查设备麦克风是否正常工作');
      } else if (_hitCount == 0) {
        buffer.writeln('⚠️ 部分问题:');
        buffer.writeln('  - 检测到声音（分贝值: ${_currentDb.toStringAsFixed(1)}）');
        buffer.writeln('  - 但没有检测到击打（阈值: 30.0 dB）');
        buffer.writeln('建议:');
        buffer.writeln('  - 制造更大声音');
        buffer.writeln('  - 或降低检测阈值');
      } else {
        buffer.writeln('✅ 检测正常:');
        buffer.writeln('  - 成功检测到 $_hitCount 次击打');
        buffer.writeln('  - 当前分贝值: ${_currentDb.toStringAsFixed(1)} dB');
      }
      
      final String allLogs = buffer.toString();
      
      // 复制到剪贴板
      await Clipboard.setData(ClipboardData(text: allLogs));
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 所有日志信息已复制到剪贴板'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 复制失败: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Detection Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // 添加复制按钮到AppBar
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: _copyAllLogs,
            tooltip: '复制所有日志',
          ),
        ],
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
                    // 添加复制按钮
                    ElevatedButton.icon(
                      onPressed: _copyAllLogs,
                      icon: Icon(Icons.copy, size: 16),
                      label: Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
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
                        Spacer(),
                        // 在日志标题栏也添加复制按钮
                        IconButton(
                          icon: Icon(Icons.copy, size: 16),
                          onPressed: _copyAllLogs,
                          tooltip: '复制所有日志',
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