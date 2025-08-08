import 'checkin_training_api.dart';
import '../models/checkin_training_api_model.dart';

/// 测试用的API类，用于验证模型和接口
class CheckinTrainingApiTest {
  /// 测试训练结果API模型
  static void testTrainingResultApiModel() {
    print('Testing TrainingResultApiModel...');
    
    // 创建测试数据
    final testData = {
      'trainingId': 'training_001',
      'productId': 'product_001',
      'totalRounds': 3,
      'roundDuration': 60,
      'maxCounts': 25,
      'timestamp': 1737367800000,
    };
    
    // 测试 fromJson
    final apiModel = CheckinTrainingResultApiModel.fromJson(testData);
    print('Created API model: $apiModel');
    
    // 测试 toJson
    final jsonData = apiModel.toJson();
    print('JSON data: $jsonData');
    
    // 验证数据一致性
    assert(apiModel.trainingId == testData['trainingId']);
    assert(apiModel.productId == testData['productId']);
    assert(apiModel.totalRounds == testData['totalRounds']);
    assert(apiModel.roundDuration == testData['roundDuration']);
    assert(apiModel.maxCounts == testData['maxCounts']);
    assert(apiModel.timestamp == testData['timestamp']);
    
    print('✅ TrainingResultApiModel test passed!');
  }
  
  /// 测试训练历史API模型
  static void testTrainingHistoryApiModel() {
    print('Testing TrainingHistoryApiModel...');
    
    // 创建测试数据
    final testData = {
      'id': 'history_001',
      'rank': 1,
      'counts': 19,
      'timestamp': 1737367800000,
      'note': 'current',
    };
    
    // 测试 fromJson
    final apiModel = CheckinTrainingHistoryApiModel.fromJson(testData);
    print('Created API model: $apiModel');
    
    // 测试 toJson
    final jsonData = apiModel.toJson();
    print('JSON data: $jsonData');
    
    // 验证数据一致性
    assert(apiModel.id == testData['id']);
    assert(apiModel.rank == testData['rank']);
    assert(apiModel.counts == testData['counts']);
    assert(apiModel.timestamp == testData['timestamp']);
    assert(apiModel.note == testData['note']);
    
    print('✅ TrainingHistoryApiModel test passed!');
  }
  
  /// 测试训练提交响应API模型
  static void testTrainingSubmitResponseApiModel() {
    print('Testing TrainingSubmitResponseApiModel...');
    
    // 创建测试数据
    final testData = {
      'id': 'result_001',
      'rank': 1,
      'totalRounds': 3,
      'roundDuration': 60,
    };
    
    // 测试 fromJson
    final apiModel = CheckinTrainingSubmitResponseApiModel.fromJson(testData);
    print('Created API model: $apiModel');
    
    // 测试 toJson
    final jsonData = apiModel.toJson();
    print('JSON data: $jsonData');
    
    // 验证数据一致性
    assert(apiModel.id == testData['id']);
    assert(apiModel.rank == testData['rank']);
    assert(apiModel.totalRounds == testData['totalRounds']);
    assert(apiModel.roundDuration == testData['roundDuration']);
    
    print('✅ TrainingSubmitResponseApiModel test passed!');
  }
  
  /// 测试视频配置API模型
  static void testVideoConfigApiModel() {
    print('Testing VideoConfigApiModel...');
    
    // 创建测试数据
    final testData = {
      'portraitUrl': 'https://example.com/videos/training_portrait.mp4',
      'landscapeUrl': 'https://example.com/videos/training_landscape.mp4',
    };
    
    // 测试 fromJson
    final apiModel = CheckinTrainingVideoConfigApiModel.fromJson(testData);
    print('Created API model: $apiModel');
    
    // 测试 toJson
    final jsonData = apiModel.toJson();
    print('JSON data: $jsonData');
    
    // 验证数据一致性
    assert(apiModel.portraitUrl == testData['portraitUrl']);
    assert(apiModel.landscapeUrl == testData['landscapeUrl']);
    
    print('✅ VideoConfigApiModel test passed!');
  }
  
  /// 运行所有测试
  static void runAllTests() {
    print('🚀 Starting CheckinTrainingApi tests...\n');
    
    try {
      testTrainingResultApiModel();
      print('');
      
      testTrainingHistoryApiModel();
      print('');
      
      testTrainingSubmitResponseApiModel();
      print('');
      
      testVideoConfigApiModel();
      print('');
      
      print('🎉 All tests passed successfully!');
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }
}

/// 使用示例
void main() {
  CheckinTrainingApiTest.runAllTests();
} 