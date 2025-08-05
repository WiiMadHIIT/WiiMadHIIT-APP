import 'yamnet_test.dart';

/// 简单的YAMNet测试脚本
/// 用于验证模型加载和基本功能
void main() async {
  print('🎯 开始YAMNet测试...');
  
  final yamnetTest = YamnetTest();
  
  try {
    // 测试模型加载
    print('📦 正在加载模型...');
    await yamnetTest.loadModel();
    print('✅ 模型加载成功');
    
    // 测试标签加载
    print('📋 标签数量: ${yamnetTest._labels?.length ?? 0}');
    
    // 显示前几个标签
    if (yamnetTest._labels != null) {
      print('📋 前10个标签:');
      for (int i = 0; i < 10 && i < yamnetTest._labels!.length; i++) {
        print('  ${i + 1}. ${yamnetTest._labels![i]}');
      }
    }
    
    print('🎉 测试完成！');
    
  } catch (e) {
    print('❌ 测试失败: $e');
  } finally {
    yamnetTest.dispose();
  }
} 