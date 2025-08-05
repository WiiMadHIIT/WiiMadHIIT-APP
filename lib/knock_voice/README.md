# Knock Voice 模块

这个模块提供了基于音频检测的击打声音识别功能，支持两种检测方法：

## 文件结构

```
knock_voice/
├── tone_specific_audio_detector.dart    # 基于音色特征的音频检测器
├── xvector_audio_detector.dart          # 基于 x-vector 模型的音频检测器
├── voice_match.dart                     # x-vector 模型和 FFT 特征处理
├── xvector_audio_detector_example.dart  # 使用示例
└── README.md                           # 本文件
```

## 功能特性

### 1. Tone Specific Audio Detector (音色特定音频检测器)
- 基于 FFT 特征和音色匹配的音频检测
- 支持实时音频流处理
- 两步检测机制：振幅检测 + 音色匹配
- 可调节的相似度阈值

### 2. XVector Audio Detector (X-Vector 音频检测器)
- 基于 x-vector TFLite 模型的音频检测
- 使用 512 维嵌入向量进行音色相似度计算
- 支持实时音频流处理
- 两步检测机制：振幅检测 + x-vector 匹配

### 3. Voice Match (音色匹配器)
- 加载和运行 x-vector TFLite 模型
- 音频预处理和 MFCC 特征提取
- 余弦相似度计算
- 支持实时音频相似度检测

## 依赖项

确保在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  tflite_flutter: ^0.11.0
  flutter_sound: ^9.2.13
  permission_handler: ^11.3.1
```

## 模型文件

将 `x_vector.tflite` 模型文件放置在 `assets/model/` 目录下，并在 `pubspec.yaml` 中声明：

```yaml
assets:
  - assets/model/x_vector.tflite
```

## 使用方法

### 基本使用

```dart
import 'package:wiimadhiit/knock_voice/xvector_audio_detector.dart';

// 创建检测器实例
final detector = XVectorAudioDetector();

// 设置回调函数
detector.onStrikeDetected = () {
  print('检测到击打声音！');
};

detector.onError = (error) {
  print('错误: $error');
};

// 初始化
await detector.initialize();

// 录制样本
await detector.recordToneSample(duration: Duration(seconds: 5));

// 开始监听
await detector.startListening();

// 停止监听
await detector.stopListening();

// 清理资源
detector.dispose();
```

### 高级配置

```dart
// 设置相似度阈值
detector.setSimilarityThreshold(0.8);

// 设置音频处理模式
detector.setAudioMode(
  interleaved: false,
  codec: Codec.pcmFloat32,
);

// 获取状态信息
print('监听状态: ${detector.isListening}');
print('检测次数: ${detector.hitCount}');
print('当前分贝: ${detector.currentDb}');
print('最后相似度: ${detector.lastDetectedSimilarity}');
```

### 完整示例

参考 `xvector_audio_detector_example.dart` 文件，其中包含了一个完整的 Flutter 页面示例，展示了如何：

- 初始化检测器
- 录制音频样本
- 开始/停止监听
- 显示实时数据
- 管理检测结果

## 技术细节

### X-Vector 模型

- **输入**: MFCC 特征矩阵 [1, 1089, 24]
- **输出**: 512 维嵌入向量 [1, 512]
- **采样率**: 16kHz
- **音频长度**: 建议 5-10 秒

### 检测流程

1. **音频预处理**: 重采样到 16kHz，转换为单声道
2. **MFCC 提取**: 计算 24 维 MFCC 特征
3. **模型推理**: 使用 x-vector 模型生成嵌入向量
4. **相似度计算**: 使用余弦相似度比较嵌入向量
5. **阈值判断**: 根据相似度阈值判断是否为目标音色

### 性能优化

- 使用 `IsolateInterpreter` 在后台线程运行推理
- 音频数据缓冲和批处理
- 相似度阈值动态调整
- 内存管理和资源清理

## 故障排除

### 常见问题

1. **模型加载失败**
   - 检查模型文件路径是否正确
   - 确保模型文件已添加到 assets 中
   - 验证模型文件完整性

2. **音频权限问题**
   - 确保已请求麦克风权限
   - 检查设备权限设置

3. **检测不准确**
   - 调整相似度阈值
   - 重新录制音频样本
   - 检查环境噪音

4. **性能问题**
   - 使用 `IsolateInterpreter` 进行异步推理
   - 调整音频缓冲区大小
   - 优化音频处理参数

### 调试信息

启用详细日志输出：

```dart
// 在初始化时查看模型信息
print('Model info: ${_voiceMatch.getModelInfo()}');

// 查看音频处理状态
print('Audio buffer size: ${detector.audioBufferSize}');
print('Sample embedding size: ${detector.sampleEmbeddingSize}');
```

## 许可证

本项目遵循 Apache 2.0 许可证。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个模块。 