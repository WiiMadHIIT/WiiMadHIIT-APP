import '../entities/activation_request.dart';
import '../../data/repository/profile_repository.dart';

class SubmitActivationUseCase {
  final ProfileRepository _profileRepository;

  SubmitActivationUseCase(this._profileRepository);

  /// 执行激活码提交
  /// 
  /// [productId] 产品ID
  /// [activationCode] 激活码
  /// 
  /// 返回提交是否成功
  Future<bool> execute(String productId, String activationCode) async {
    print('🔍 SubmitActivationUseCase: 开始执行激活码提交');
    print('🔍 SubmitActivationUseCase: 产品ID: $productId');
    
    try {
      // 创建激活请求实体
      final request = ActivationRequest(
        productId: productId,
        activationCode: activationCode,
      );

      // 验证请求参数
      if (!request.isValid) {
        print('🔍 SubmitActivationUseCase: 请求参数验证失败');
        throw ArgumentError('Invalid activation request parameters');
      }

      // 验证激活码格式
      if (!request.isCodeFormatValid) {
        print('🔍 SubmitActivationUseCase: 激活码格式验证失败');
        throw ArgumentError('Invalid activation code format');
      }

      print('🔍 SubmitActivationUseCase: 参数验证通过，调用Repository');
      
      // 调用 Repository 提交激活码
      final result = await _profileRepository.submitActivationCode(
        productId,
        activationCode,
      );

      print('🔍 SubmitActivationUseCase: Repository返回结果: $result');
      return result;
    } catch (e) {
      print('🔍 SubmitActivationUseCase error: $e');
      rethrow;
    }
  }

  /// 执行激活码提交（使用 ActivationRequest 实体）
  /// 
  /// [request] 激活请求实体
  /// 
  /// 返回提交是否成功
  Future<bool> executeWithRequest(ActivationRequest request) async {
    try {
      // 验证请求参数
      if (!request.isValid) {
        throw ArgumentError('Invalid activation request parameters');
      }

      // 验证激活码格式
      if (!request.isCodeFormatValid) {
        throw ArgumentError('Invalid activation code format');
      }

      // 调用 Repository 提交激活码
      final result = await _profileRepository.submitActivationCode(
        request.productId,
        request.activationCode,
      );

      return result;
    } catch (e) {
      print('SubmitActivationUseCase error: $e');
      rethrow;
    }
  }
}
