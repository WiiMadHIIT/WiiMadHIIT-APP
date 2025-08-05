import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart' hide List;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Voice Match - 音色匹配器
/// 使用 x-vector TFLite 模型和 FFT 特征进行音色相似度检测
class VoiceMatch {
  Interpreter? _interpreter;
  FlutterSoundRecorder? _recorder;
  
  // 模型配置
  static const int _sampleRate = 16000;
  static const int _numMels = 24;
  static const int _embeddingSize = 512;
  static const int _targetFrames = 1089;

  VoiceMatch() {
    _recorder = FlutterSoundRecorder();
  }

  /// 加载 TFLite 模型
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/x_vector.tflite');
      print('🎯 TFLite model loaded successfully');
      
      var inputShape = _interpreter!.getInputTensor(0).shape;
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      print('🎯 Model input shape: $inputShape');
      print('🎯 Model output shape: $outputShape');
    } catch (e) {
      print('❌ Failed to load TFLite model: $e');
      rethrow;
    }
  }

  /// 从音频数据提取 x-vector 嵌入向量
  Future<List<double>> extractEmbedding(List<double> audioData) async {
    try {
      if (_interpreter == null) {
        throw Exception('Model not loaded. Call loadModel() first.');
      }
      
      // 预处理音频数据
      var processedAudio = await _preprocessAudio(audioData);
      
      // 计算 MFCC 特征
      var mfccFrames = await _computeMFCC(processedAudio);
      
      // 准备模型输入
      var input = _prepareModelInput(mfccFrames);
      
      // 运行推理
      var output = await _runInference(input);
      
      return output;
    } catch (e) {
      print('❌ Error extracting embedding: $e');
      return [];
    }
  }

  /// 预处理音频数据
  Future<List<double>> _preprocessAudio(List<double> audioData) async {
    try {
      int targetLength = 8 * _sampleRate; // 8秒
      
      if (audioData.length > targetLength) {
        int start = (audioData.length - targetLength) ~/ 2;
        audioData = audioData.sublist(start, start + targetLength);
      } else if (audioData.length < targetLength) {
        audioData.addAll(List.filled(targetLength - audioData.length, 0.0));
      }
      
      return audioData;
    } catch (e) {
      print('❌ Error preprocessing audio: $e');
      rethrow;
    }
  }

  /// 计算 MFCC 特征
  Future<List<List<double>>> _computeMFCC(List<double> audioData) async {
    try {
      int frameSize = 1024;
      int hopSize = 512;
      int numFrames = (audioData.length - frameSize) ~/ hopSize + 1;
      
      List<List<double>> mfccFrames = [];
      
      for (int i = 0; i < numFrames; i++) {
        int start = i * hopSize;
        int end = start + frameSize;
        
        if (end > audioData.length) break;
        
        List<double> frame = audioData.sublist(start, end);
        List<double> windowedFrame = _applyHanningWindow(frame);
        List<double> fftResult = _computeFFT(windowedFrame);
        List<double> mfcc = _computeMFCCFromFFT(fftResult);
        
        mfccFrames.add(mfcc);
      }
      
      return mfccFrames;
    } catch (e) {
      print('❌ Error computing MFCC: $e');
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

  /// 从 FFT 结果计算 MFCC
  List<double> _computeMFCCFromFFT(List<double> fftResult) {
    List<double> mfcc = List.filled(_numMels, 0.0);
    
    for (int i = 0; i < _numMels; i++) {
      double melEnergy = 0.0;
      
      for (int j = 0; j < fftResult.length; j++) {
        double melFilter = _getMelFilterValue(j, i, fftResult.length);
        melEnergy += fftResult[j] * melFilter;
      }
      
      mfcc[i] = melEnergy > 0 ? log(melEnergy) : -20.0;
    }
    
    return mfcc;
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
  List<List<List<double>>> _prepareModelInput(List<List<double>> mfccFrames) {
    try {
      List<List<double>> paddedFrames = List.from(mfccFrames);
      
      if (paddedFrames.length < _targetFrames) {
        while (paddedFrames.length < _targetFrames) {
          paddedFrames.add(List.filled(_numMels, 0.0));
        }
      } else if (paddedFrames.length > _targetFrames) {
        int start = (paddedFrames.length - _targetFrames) ~/ 2;
        paddedFrames = paddedFrames.sublist(start, start + _targetFrames);
      }
      
      return [paddedFrames];
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
      
      var inputTensor = _reshapeTo3D(input);
      
      // 使用 tflite_flutter 的 reshape 方法
      var outputList = List<double>.filled(1 * _embeddingSize, 0.0);
      var outputTensor = outputList.reshape([1, _embeddingSize]);
      
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

  /// 计算余弦相似度
  double computeCosineSimilarity(List<double> emb1, List<double> emb2) {
    if (emb1.isEmpty || emb2.isEmpty) return 0.0;
    
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;
    
    int minLength = min(emb1.length, emb2.length);
    
    for (int i = 0; i < minLength; i++) {
      dotProduct += emb1[i] * emb2[i];
      norm1 += emb1[i] * emb1[i];
      norm2 += emb2[i] * emb2[i];
    }
    
    norm1 = sqrt(norm1);
    norm2 = sqrt(norm2);
    
    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;
    
    double cosineSimilarity = dotProduct / (norm1 * norm2);
    return (cosineSimilarity + 1.0) / 2.0;
  }

  /// 比较两个音频的音色相似度
  Future<double> compareTimbre(List<double> audioData1, List<double> audioData2) async {
    try {
      print('🎵 Starting timbre comparison...');
      
      var emb1 = await extractEmbedding(audioData1);
      var emb2 = await extractEmbedding(audioData2);
      
      if (emb1.isEmpty || emb2.isEmpty) {
        print('❌ Failed to extract embeddings');
        return 0.0;
      }
      
      double similarity = computeCosineSimilarity(emb1, emb2);
      print('🎵 X-vector similarity: ${similarity.toStringAsFixed(3)}');
      
      return similarity;
    } catch (e) {
      print('❌ Error comparing timbre: $e');
      return 0.0;
    }
  }

  /// 清理资源
  void dispose() {
    try {
      _interpreter?.close();
      _recorder?.closeRecorder();
      print('🎯 Voice match disposed');
    } catch (e) {
      print('❌ Error disposing voice match: $e');
    }
  }
}


