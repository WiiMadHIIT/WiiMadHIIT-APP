import '../../entities/auth/auth_entities.dart';
import '../../../data/repository/auth_repository.dart';

/// 验证注册验证码用例（包含激活码）
/// - 对外字段英文，注释中文
class VerifyRegisterCodeUseCase {
  /// 认证仓库
  final AuthRepository repository;

  VerifyRegisterCodeUseCase(this.repository);

  /// 执行验证
  Future<RegisterResult> execute({
    required String email,
    required String code,
    required String activationCode,
  }) {
    return repository.verifyRegisterCode(
      email: email,
      code: code,
      activationCode: activationCode,
    );
  }
}


