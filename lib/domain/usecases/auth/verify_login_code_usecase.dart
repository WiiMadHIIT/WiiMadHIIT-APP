import '../../entities/auth/auth_entities.dart';
import '../../../data/repository/auth_repository.dart';

/// 验证登录验证码用例
/// - 对外字段英文，注释中文
class VerifyLoginCodeUseCase {
  /// 认证仓库
  final AuthRepository repository;

  VerifyLoginCodeUseCase(this.repository);

  /// 执行验证
  Future<LoginResult> execute({
    required String email,
    required String code,
  }) {
    return repository.verifyLoginCode(email, code);
  }
}