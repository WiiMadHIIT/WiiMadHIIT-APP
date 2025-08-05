import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart' hide List;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;

/// YAMNet Audio Classifier - 音频分类器
/// 使用 YAMNet TFLite 模型进行音频分类
class YamnetAudioClassifier {
  Interpreter? _interpreter;
  FlutterSoundRecorder? _recorder;
  List<String>? _labels;
  
  // YAMNet 模型配置
  static const int _sampleRate = 16000;
  static const int _frameSize = 400; // 25ms at 16kHz
  static const int _hopSize = 160;   // 10ms at 16kHz
  static const int _numMels = 64;
  static const int _numClasses = 521;

  YamnetAudioClassifier() {
    _recorder = FlutterSoundRecorder();
  }

  /// 加载 TFLite 模型和标签
  Future<void> loadModel() async {
    try {
      // 加载模型
      _interpreter = await Interpreter.fromAsset('assets/model/yamnet.tflite');
      print('🎯 YAMNet model loaded successfully');
      
      // 加载标签
      await _loadLabels();
      
      var inputShape = _interpreter!.getInputTensor(0).shape;
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      print('🎯 Model input shape: $inputShape');
      print('🎯 Model output shape: $outputShape');
      print('🎯 Labels loaded: ${_labels?.length} classes');
    } catch (e) {
      print('❌ Failed to load YAMNet model: $e');
      rethrow;
    }
  }

  /// 加载标签文件
  Future<void> _loadLabels() async {
    try {
      String labelsContent = await rootBundle.loadString('assets/model/labels.text');
      _labels = labelsContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
      print('🎯 Loaded ${_labels!.length} labels');
    } catch (e) {
      print('❌ Failed to load labels: $e');
      rethrow;
    }
  }

  /// 开始录音
  Future<void> startRecording() async {
    try {
      if (_recorder == null) {
        _recorder = FlutterSoundRecorder();
      }
      
      await _recorder!.openRecorder();
      await _recorder!.startRecorder(
        toStream: true,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: _sampleRate,
      );
      print('🎤 Started recording...');
    } catch (e) {
      print('❌ Failed to start recording: $e');
      rethrow;
    }
  }

  /// 停止录音并返回音频数据
  Future<List<double>> stopRecording() async {
    try {
      if (_recorder == null) {
        throw Exception('Recorder not initialized');
      }
      
      String? path = await _recorder!.stopRecorder();
      await _recorder!.closeRecorder();
      
      if (path == null) {
        throw Exception('No recording path returned');
      }
      
      // 读取音频文件
      Uint8List audioBytes = await _recorder!.readAudioFile(path);
      List<double> audioData = _convertBytesToDoubleList(audioBytes);
      
      print('🎤 Recording stopped. Audio length: ${audioData.length} samples');
      return audioData;
    } catch (e) {
      print('❌ Failed to stop recording: $e');
      rethrow;
    }
  }

  /// 将字节数据转换为double列表
  List<double> _convertBytesToDoubleList(Uint8List bytes) {
    List<double> audioData = [];
    for (int i = 0; i < bytes.length; i += 2) {
      if (i + 1 < bytes.length) {
        int sample = (bytes[i + 1] << 8) | bytes[i];
        if (sample >= 32768) {
          sample -= 65536;
        }
        audioData.add(sample / 32768.0);
      }
    }
    return audioData;
  }

  /// 对音频进行分类
  Future<List<MapEntry<String, double>>> classifyAudio(List<double> audioData) async {
    try {
      if (_interpreter == null) {
        throw Exception('Model not loaded. Call loadModel() first.');
      }
      
      if (_labels == null) {
        throw Exception('Labels not loaded.');
      }
      
      print('🎵 Starting audio classification...');
      
      // 预处理音频数据
      var processedAudio = await _preprocessAudio(audioData);
      
      // 计算 mel 频谱图
      var melSpectrogram = await _computeMelSpectrogram(processedAudio);
      
      // 准备模型输入
      var input = _prepareModelInput(melSpectrogram);
      
      // 运行推理
      var output = await _runInference(input);
      
      // 处理输出结果
      var results = _processOutput(output);
      
      return results;
    } catch (e) {
      print('❌ Error classifying audio: $e');
      return [];
    }
  }

  /// 预处理音频数据
  Future<List<double>> _preprocessAudio(List<double> audioData) async {
    try {
      // 确保音频长度足够
      int minLength = 3 * _sampleRate; // 至少3秒
      
      if (audioData.length < minLength) {
        // 如果音频太短，用零填充
        audioData.addAll(List.filled(minLength - audioData.length, 0.0));
      } else if (audioData.length > minLength) {
        // 如果音频太长，取中间部分
        int start = (audioData.length - minLength) ~/ 2;
        audioData = audioData.sublist(start, start + minLength);
      }
      
      return audioData;
    } catch (e) {
      print('❌ Error preprocessing audio: $e');
      rethrow;
    }
  }

  /// 计算 mel 频谱图
  Future<List<List<double>>> _computeMelSpectrogram(List<double> audioData) async {
    try {
      List<List<double>> melSpectrogram = [];
      
      // 计算帧数
      int numFrames = (audioData.length - _frameSize) ~/ _hopSize + 1;
      
      for (int i = 0; i < numFrames; i++) {
        int start = i * _hopSize;
        int end = start + _frameSize;
        
        if (end > audioData.length) break;
        
        List<double> frame = audioData.sublist(start, end);
        List<double> windowedFrame = _applyHanningWindow(frame);
        List<double> fftResult = _computeFFT(windowedFrame);
        List<double> melFeatures = _computeMelFeatures(fftResult);
        
        melSpectrogram.add(melFeatures);
      }
      
      return melSpectrogram;
    } catch (e) {
      print('❌ Error computing mel spectrogram: $e');
      rethrow;
    }
  }

  /// 应用汉宁窗
  List<double> _applyHanningWindow(List<double> frame) {
    List<double> windowed = List.filled(frame.length, 0.0);
    
    for (int i = 0; i < frame.length; i++) {
      double windowValue = 0.5 * (1 - cos(2 * pi * i / (frame.length - 1)));
      windowed[i] = frame[i] * windowValue;
    }
    
    return windowed;
  }

  /// 计算 FFT
  List<double> _computeFFT(List<double> frame) {
    int n = frame.length;
    List<double> real = List.filled(n, 0.0);
    List<double> imag = List.filled(n, 0.0);
    
    for (int i = 0; i < n; i++) {
      real[i] = frame[i];
    }
    
    for (int k = 0; k < n; k++) {
      double sumReal = 0.0;
      double sumImag = 0.0;
      
      for (int j = 0; j < n; j++) {
        double angle = -2 * pi * k * j / n;
        sumReal += real[j] * cos(angle);
        sumImag += real[j] * sin(angle);
      }
      
      real[k] = sumReal;
      imag[k] = sumImag;
    }
    
    List<double> magnitude = List.filled(n ~/ 2, 0.0);
    for (int i = 0; i < n ~/ 2; i++) {
      magnitude[i] = sqrt(real[i] * real[i] + imag[i] * imag[i]);
    }
    
    return magnitude;
  }

  /// 计算 mel 特征
  List<double> _computeMelFeatures(List<double> fftResult) {
    List<double> melFeatures = List.filled(_numMels, 0.0);
    
    for (int i = 0; i < _numMels; i++) {
      double melEnergy = 0.0;
      
      for (int j = 0; j < fftResult.length; j++) {
        double melFilter = _getMelFilterValue(j, i, fftResult.length);
        melEnergy += fftResult[j] * melFilter;
      }
      
      melFeatures[i] = melEnergy > 0 ? log(melEnergy) : -20.0;
    }
    
    return melFeatures;
  }

  /// 获取 mel 滤波器值
  double _getMelFilterValue(int freqBin, int melBin, int numBins) {
    double centerFreq = melBin * _sampleRate / (2 * _numMels);
    double binFreq = freqBin * _sampleRate / (2 * numBins);
    
    double distance = (binFreq - centerFreq).abs();
    double bandwidth = _sampleRate / (4 * _numMels);
    
    if (distance < bandwidth) {
      return 1.0 - distance / bandwidth;
    }
    
    return 0.0;
  }

  /// 准备模型输入
  List<List<List<double>>> _prepareModelInput(List<List<double>> melSpectrogram) {
    try {
      // YAMNet 期望的输入形状通常是 [1, frames, mel_bins]
      return [melSpectrogram];
    } catch (e) {
      print('❌ Error preparing model input: $e');
      rethrow;
    }
  }

  /// 运行模型推理
  Future<List<double>> _runInference(List<List<List<double>>> input) async {
    try {
      if (_interpreter == null) {
        throw Exception('Model not loaded');
      }
      
      // 准备输入张量
      var inputTensor = _reshapeTo3D(input);
      
      // 准备输出张量
      var outputList = List<double>.filled(1 * _numClasses, 0.0);
      var outputTensor = outputList.reshape([1, _numClasses]);
      
      // 运行推理
      _interpreter!.run(inputTensor, outputTensor);
      
      return outputTensor[0].cast<double>();
    } catch (e) {
      print('❌ Error running inference: $e');
      rethrow;
    }
  }

  /// 重塑为 3D 张量
  List<List<List<double>>> _reshapeTo3D(List<List<List<double>>> input) {
    if (input.isEmpty || input[0].isEmpty) {
      throw Exception('Empty input data');
    }
    
    int batchSize = 1;
    int frames = input[0].length;
    int features = input[0][0].length;
    
    List<List<List<double>>> reshaped = [];
    
    for (int b = 0; b < batchSize; b++) {
      List<List<double>> batch = [];
      for (int f = 0; f < frames; f++) {
        List<double> frame = [];
        for (int c = 0; c < features; c++) {
          frame.add(input[b][f][c]);
        }
        batch.add(frame);
      }
      reshaped.add(batch);
    }
    
    return reshaped;
  }

  /// 处理模型输出
  List<MapEntry<String, double>> _processOutput(List<double> output) {
    try {
      List<MapEntry<String, double>> results = [];
      
      for (int i = 0; i < output.length && i < _labels!.length; i++) {
        double confidence = output[i];
        String label = _labels![i];
        
        if (confidence > 0.1) { // 只显示置信度大于0.1的结果
          results.add(MapEntry(label, confidence));
        }
      }
      
      // 按置信度排序
      results.sort((a, b) => b.value.compareTo(a.value));
      
      // 只返回前10个结果
      return results.take(10).toList();
    } catch (e) {
      print('❌ Error processing output: $e');
      return [];
    }
  }

  /// 清理资源
  void dispose() {
    try {
      _interpreter?.close();
      _recorder?.closeRecorder();
      print('🎯 YAMNet classifier disposed');
    } catch (e) {
      print('❌ Error disposing YAMNet classifier: $e');
    }
  }
} 