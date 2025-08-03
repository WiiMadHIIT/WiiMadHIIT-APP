import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';

/// VoiceMatch - 语音匹配器
/// 使用 x-vector TFLite 模型进行语音特征提取和相似度计算
/// 基于 SpeechBrain x-vector 模型转换而来
class VoiceMatch {
  Interpreter? _interpreter;
  bool _isLoaded = false;
  
  /// 模型是否已加载
  bool get isLoaded => _isLoaded;
  
  /// 加载 x-vector TFLite 模型
  Future<bool> loadModel() async {
    try {
      print('🎵 Loading x-vector TFLite model...');
      _interpreter = await Interpreter.fromAsset('assets/model/x_vector.tflite');
      
      // 获取输入详情
      var inputDetails = _interpreter!.getInputDetails();
      print('🎵 Input details: ${inputDetails.length} inputs');
      
      // 设置动态输入形状 [1, -1, 24] (batch_size, time_steps, mfcc_features)
      _interpreter!.resizeInputTensor(inputDetails[0]['index'], [1, -1, 24]);
      _interpreter!.allocateTensors();
      
      _isLoaded = true;
      print('🎵 x-vector TFLite model loaded successfully');
      return true;
    } catch (e) {
      print('❌ Failed to load x-vector TFLite model: $e');
      _isLoaded = false;
      return false;
    }
  }
  
  /// 从音频文件提取语音嵌入向量
  Future<List<double>> extractEmbeddingFromFile(String audioPath) async {
    if (!_isLoaded) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }
    
    try {
      print('🎵 Extracting embedding from file: $audioPath');
      
      // 简化的文件处理（暂时返回模拟数据）
      // 在实际应用中，你需要实现音频文件的读取和特征提取
      List<double> mockFeatures = List.filled(24, 0.1);
      
      // 重塑为模型输入格式 [1, 1, 24]
      var inputFeatures = _reshapeFeatures(mockFeatures);
      
      // 准备输出张量 [1, 512]
      var output = List.filled(512, 0.0).reshape([1, 512]);
      
      // 设置输入张量
      _interpreter!.setTensor(
        _interpreter!.getInputIndex('serving_default_mfcc:0'), 
        inputFeatures
      );
      
      // 运行推理
      _interpreter!.invoke();
      
      // 获取输出
      output = _interpreter!.getOutputTensor(
        _interpreter!.getOutputIndex('StatefulPartitionedCall:0')
      );
      
      print('🎵 Embedding extracted successfully: ${output[0].length} dimensions');
      return output[0];
    } catch (e) {
      print('❌ Failed to extract embedding from file: $e');
      rethrow;
    }
  }
  
  /// 从音频数据提取语音嵌入向量
  Future<List<double>> extractEmbeddingFromAudioData(List<double> audioData, {int sampleRate = 16000}) async {
    if (!_isLoaded) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }
    
    try {
      print('🎵 Extracting embedding from audio data: ${audioData.length} samples');
      
      // 简化的音频特征提取（替代 MFCC）
      var features = _extractSimpleAudioFeatures(audioData, sampleRate);
      
      print('🎵 Features shape: ${features.length}');
      
      // 重塑为模型输入格式 [1, time_steps, 24]
      var inputFeatures = _reshapeFeatures(features);
      
      // 准备输出张量 [1, 512]
      var output = List.filled(512, 0.0).reshape([1, 512]);
      
      // 设置输入张量
      _interpreter!.setTensor(
        _interpreter!.getInputIndex('serving_default_mfcc:0'), 
        inputFeatures
      );
      
      // 运行推理
      _interpreter!.invoke();
      
      // 获取输出
      output = _interpreter!.getOutputTensor(
        _interpreter!.getOutputIndex('StatefulPartitionedCall:0')
      );
      
      print('🎵 Embedding extracted successfully: ${output[0].length} dimensions');
      return output[0];
    } catch (e) {
      print('❌ Failed to extract embedding from audio data: $e');
      rethrow;
    }
  }
  
  /// 简化的音频特征提取
  List<double> _extractSimpleAudioFeatures(List<double> audioData, int sampleRate) {
    if (audioData.isEmpty) return List.filled(24, 0.0);
    
    // 计算基本音频特征
    List<double> features = [];
    
    // 1. RMS 能量
    double rms = _calculateRMS(audioData);
    features.add(rms);
    
    // 2. 频谱质心（简化版）
    double spectralCentroid = _calculateSpectralCentroid(audioData);
    features.add(spectralCentroid);
    
    // 3. 过零率
    double zeroCrossingRate = _calculateZeroCrossingRate(audioData);
    features.add(zeroCrossingRate);
    
    // 4. 频谱滚降（简化版）
    double spectralRolloff = _calculateSpectralRolloff(audioData);
    features.add(spectralRolloff);
    
    // 5. 填充到 24 维（模拟 MFCC）
    while (features.length < 24) {
      features.add(0.0);
    }
    
    return features.take(24).toList();
  }
  
  /// 重塑特征为模型输入格式
  List<List<List<double>>> _reshapeFeatures(List<double> features) {
    // 创建 [1, 1, 24] 的形状
    return [[features]];
  }
  
  /// 计算 RMS
  double _calculateRMS(List<double> data) {
    if (data.isEmpty) return 0.0;
    double sum = 0.0;
    for (var sample in data) {
      sum += sample * sample;
    }
    return sqrt(sum / data.length);
  }
  
  /// 计算频谱质心（简化版）
  double _calculateSpectralCentroid(List<double> audioData) {
    if (audioData.isEmpty) return 0.0;
    
    double weightedSum = 0.0;
    double sum = 0.0;
    
    for (int i = 0; i < audioData.length; i++) {
      double magnitude = audioData[i].abs();
      weightedSum += magnitude * i;
      sum += magnitude;
    }
    
    return sum > 0 ? weightedSum / sum : 0.0;
  }
  
  /// 计算过零率
  double _calculateZeroCrossingRate(List<double> audioData) {
    if (audioData.length < 2) return 0.0;
    
    int crossings = 0;
    for (int i = 1; i < audioData.length; i++) {
      if ((audioData[i] >= 0) != (audioData[i - 1] >= 0)) {
        crossings++;
      }
    }
    
    return crossings / (audioData.length - 1);
  }
  
  /// 计算频谱滚降（简化版）
  double _calculateSpectralRolloff(List<double> audioData) {
    if (audioData.isEmpty) return 0.0;
    
    // 排序幅度
    List<double> magnitudes = audioData.map((e) => e.abs()).toList();
    magnitudes.sort();
    
    // 找到 85% 分位数
    int index = (magnitudes.length * 0.85).round();
    if (index >= magnitudes.length) index = magnitudes.length - 1;
    
    return magnitudes[index];
  }
  
  /// 计算两个嵌入向量的余弦相似度
  double cosineSimilarity(List<double> emb1, List<double> emb2) {
    if (emb1.length != emb2.length) {
      throw Exception('Embedding dimensions must match: ${emb1.length} vs ${emb2.length}');
    }
    
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;
    
    for (int i = 0; i < emb1.length; i++) {
      dotProduct += emb1[i] * emb2[i];
      norm1 += emb1[i] * emb1[i];
      norm2 += emb2[i] * emb2[i];
    }
    
    double similarity = dotProduct / (sqrt(norm1) * sqrt(norm2));
    
    // 确保结果在 [-1, 1] 范围内
    return similarity.clamp(-1.0, 1.0);
  }
  
  /// 计算归一化的余弦相似度 (0-1 范围)
  double normalizedCosineSimilarity(List<double> emb1, List<double> emb2) {
    double similarity = cosineSimilarity(emb1, emb2);
    // 将 [-1, 1] 转换为 [0, 1]
    return (similarity + 1.0) / 2.0;
  }
  
  /// 释放资源
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
    print('🎵 VoiceMatch disposed');
  }
} 