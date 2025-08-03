import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_processing/flutter_sound_processing.dart';

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
      
      var audio = FlutterSound();
      await audio.openAudioSession();
      
      // 开始播放器来获取音频信号
      var signal = await audio.startPlayer(audioPath);
      
      // 提取 MFCC 特征
      var mfcc = await FlutterSoundProcessing().extractMFCC(
        signal,
        sampleRate: 16000,
        nMfcc: 24,
        hopLength: 160,
        winLength: 400
      );
      
      print('🎵 MFCC shape: ${mfcc.shape}');
      
      // 重塑为模型输入格式 [1, time_steps, 24]
      var inputMfcc = mfcc.reshape([1, mfcc.length, 24]);
      
      // 准备输出张量 [1, 512]
      var output = List.filled(512, 0.0).reshape([1, 512]);
      
      // 设置输入张量
      _interpreter!.setTensor(
        _interpreter!.getInputIndex('serving_default_mfcc:0'), 
        inputMfcc
      );
      
      // 运行推理
      _interpreter!.invoke();
      
      // 获取输出
      output = _interpreter!.getOutputTensor(
        _interpreter!.getOutputIndex('StatefulPartitionedCall:0')
      );
      
      await audio.closeAudioSession();
      
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
      
      // 使用 FlutterSoundProcessing 提取 MFCC
      var mfcc = await FlutterSoundProcessing().extractMFCCFromSamples(
        audioData,
        sampleRate: sampleRate,
        nMfcc: 24,
        hopLength: 160,
        winLength: 400
      );
      
      print('🎵 MFCC shape: ${mfcc.shape}');
      
      // 重塑为模型输入格式 [1, time_steps, 24]
      var inputMfcc = mfcc.reshape([1, mfcc.length, 24]);
      
      // 准备输出张量 [1, 512]
      var output = List.filled(512, 0.0).reshape([1, 512]);
      
      // 设置输入张量
      _interpreter!.setTensor(
        _interpreter!.getInputIndex('serving_default_mfcc:0'), 
        inputMfcc
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