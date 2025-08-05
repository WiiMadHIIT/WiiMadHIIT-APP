import 'dart:math';
import 'voice_match.dart';

/// VoiceMatch 功能测试
/// 用于验证 x-vector 模型和音频处理功能
class VoiceMatchTest {
  static final VoiceMatch _voiceMatch = VoiceMatch();
  
  /// 运行所有测试
  static Future<void> runAllTests() async {
    print('🧪 开始 VoiceMatch 测试...\n');
    
    try {
      await _testModelLoading();
      await _testAudioProcessing();
      await _testSimilarityComputation();
      await _testEmbeddingExtraction();
      
      print('✅ 所有测试通过！');
    } catch (e) {
      print('❌ 测试失败: $e');
    } finally {
      _voiceMatch.dispose();
    }
  }
  
  /// 测试模型加载
  static Future<void> _testModelLoading() async {
    print('📦 测试模型加载...');
    
    try {
      await _voiceMatch.loadModel();
      print('✅ 模型加载成功');
      
      // 获取模型信息
      var modelInfo = _voiceMatch.getModelInfo();
      print('📊 模型信息: $modelInfo');
    } catch (e) {
      print('❌ 模型加载失败: $e');
      rethrow;
    }
  }
  
  /// 测试音频处理
  static Future<void> _testAudioProcessing() async {
    print('\n🎵 测试音频处理...');
    
    try {
      // 生成测试音频数据 (5秒 16kHz)
      List<double> testAudio = _generateTestAudio(5 * 16000);
      print('✅ 测试音频生成成功 (${testAudio.length} 样本)');
      
      // 测试音频预处理
      var processedAudio = await _voiceMatch._preprocessAudio(testAudio);
      print('✅ 音频预处理成功 (${processedAudio.length} 样本)');
      
      // 测试 MFCC 计算
      var mfccFrames = await _voiceMatch._computeMFCC(processedAudio);
      print('✅ MFCC 计算成功 (${mfccFrames.length} 帧, ${mfccFrames.isNotEmpty ? mfccFrames[0].length : 0} 系数)');
      
    } catch (e) {
      print('❌ 音频处理失败: $e');
      rethrow;
    }
  }
  
  /// 测试相似度计算
  static Future<void> _testSimilarityComputation() async {
    print('\n🔍 测试相似度计算...');
    
    try {
      // 创建测试嵌入向量
      List<double> emb1 = List.generate(512, (i) => Random().nextDouble());
      List<double> emb2 = List.generate(512, (i) => Random().nextDouble());
      
      // 测试余弦相似度
      double similarity = _voiceMatch.computeCosineSimilarity(emb1, emb2);
      print('✅ 余弦相似度计算成功: ${similarity.toStringAsFixed(3)}');
      
      // 测试相同向量的相似度
      double selfSimilarity = _voiceMatch.computeCosineSimilarity(emb1, emb1);
      print('✅ 自相似度: ${selfSimilarity.toStringAsFixed(3)} (应该接近 1.0)');
      
      // 测试空向量
      double emptySimilarity = _voiceMatch.computeCosineSimilarity([], []);
      print('✅ 空向量相似度: ${emptySimilarity.toStringAsFixed(3)} (应该为 0.0)');
      
    } catch (e) {
      print('❌ 相似度计算失败: $e');
      rethrow;
    }
  }
  
  /// 测试嵌入向量提取
  static Future<void> _testEmbeddingExtraction() async {
    print('\n🎯 测试嵌入向量提取...');
    
    try {
      // 生成测试音频数据
      List<double> testAudio = _generateTestAudio(8 * 16000); // 8秒
      print('✅ 测试音频生成成功 (${testAudio.length} 样本)');
      
      // 提取嵌入向量
      List<double> embedding = await _voiceMatch.extractEmbedding(testAudio);
      
      if (embedding.isNotEmpty) {
        print('✅ 嵌入向量提取成功 (${embedding.length} 维)');
        print('📊 嵌入向量统计:');
        print('   - 最小值: ${embedding.reduce(min).toStringAsFixed(3)}');
        print('   - 最大值: ${embedding.reduce(max).toStringAsFixed(3)}');
        print('   - 平均值: ${(embedding.reduce((a, b) => a + b) / embedding.length).toStringAsFixed(3)}');
      } else {
        print('❌ 嵌入向量提取失败');
        rethrow;
      }
      
    } catch (e) {
      print('❌ 嵌入向量提取失败: $e');
      rethrow;
    }
  }
  
  /// 生成测试音频数据
  static List<double> _generateTestAudio(int numSamples) {
    List<double> audio = [];
    Random random = Random();
    
    for (int i = 0; i < numSamples; i++) {
      // 生成包含多个频率的正弦波
      double sample = 0.0;
      sample += 0.3 * sin(2 * pi * 440 * i / 16000); // A4 音符
      sample += 0.2 * sin(2 * pi * 880 * i / 16000); // A5 音符
      sample += 0.1 * sin(2 * pi * 220 * i / 16000); // A3 音符
      
      // 添加一些随机噪声
      sample += 0.05 * (random.nextDouble() * 2 - 1);
      
      audio.add(sample);
    }
    
    return audio;
  }
  
  /// 运行性能测试
  static Future<void> runPerformanceTest() async {
    print('\n⚡ 开始性能测试...');
    
    try {
      await _voiceMatch.loadModel();
      
      // 生成测试音频
      List<double> testAudio = _generateTestAudio(8 * 16000);
      
      // 测试多次嵌入向量提取的性能
      int numTests = 5;
      List<double> times = [];
      
      for (int i = 0; i < numTests; i++) {
        print('🔄 运行测试 ${i + 1}/$numTests...');
        
        var stopwatch = Stopwatch()..start();
        await _voiceMatch.extractEmbedding(testAudio);
        stopwatch.stop();
        
        times.add(stopwatch.elapsedMilliseconds.toDouble());
        print('⏱️  耗时: ${stopwatch.elapsedMilliseconds}ms');
      }
      
      // 计算统计信息
      double avgTime = times.reduce((a, b) => a + b) / times.length;
      double minTime = times.reduce(min);
      double maxTime = times.reduce(max);
      
      print('\n📊 性能测试结果:');
      print('   - 平均耗时: ${avgTime.toStringAsFixed(1)}ms');
      print('   - 最短耗时: ${minTime.toStringAsFixed(1)}ms');
      print('   - 最长耗时: ${maxTime.toStringAsFixed(1)}ms');
      print('   - 标准差: ${_calculateStandardDeviation(times, avgTime).toStringAsFixed(1)}ms');
      
    } catch (e) {
      print('❌ 性能测试失败: $e');
    } finally {
      _voiceMatch.dispose();
    }
  }
  
  /// 计算标准差
  static double _calculateStandardDeviation(List<double> values, double mean) {
    double sumSquaredDiff = 0.0;
    for (double value in values) {
      sumSquaredDiff += (value - mean) * (value - mean);
    }
    return sqrt(sumSquaredDiff / values.length);
  }
}

/// 运行测试的主函数
void main() async {
  print('🚀 VoiceMatch 测试程序启动\n');
  
  // 运行功能测试
  await VoiceMatchTest.runAllTests();
  
  print('\n' + '=' * 50);
  
  // 运行性能测试
  await VoiceMatchTest.runPerformanceTest();
  
  print('\n🎉 所有测试完成！');
} 