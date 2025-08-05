import 'package:flutter/material.dart';
import 'yamnet_test_page.dart';

/// YAMNet 使用示例
/// 
/// 这个示例展示了如何使用 YAMNet 模型进行音频分类：
/// 1. 加载 YAMNet TFLite 模型
/// 2. 使用 flutter_sound 录制音频
/// 3. 对音频进行分类识别
/// 4. 显示识别结果
/// 
/// 使用方法：
/// 1. 确保 assets/model/yamnet.tflite 文件存在
/// 2. 确保 assets/model/labels.text 文件存在
/// 3. 运行此示例页面
/// 4. 点击"开始录音"按钮开始录音
/// 5. 说话或发出声音
/// 6. 点击"停止录音"按钮停止录音并查看结果
/// 
/// 支持的音频类别包括：
/// - 语音 (Speech, Conversation, Shout, Whispering)
/// - 笑声 (Laughter, Giggle, Chuckle)
/// - 哭声 (Crying, Baby cry, Whimper)
/// - 歌声 (Singing, Choir, Rapping)
/// - 动物声音 (Dog, Cat, Horse, Bird)
/// - 环境声音 (Footsteps, Clapping, Applause)
/// - 等等...
class YamnetExample extends StatelessWidget {
  const YamnetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YAMNet 音频分类示例',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const YamnetTestPage(),
    );
  }
}

/// 快速启动函数
void main() {
  runApp(const YamnetExample());
} 