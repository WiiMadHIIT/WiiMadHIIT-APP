import '../../entities/auth/auth_entities.dart';
import '../../../data/repository/auth_repository.dart';

/// 发送登录验证码用例
/// - 对外字段英文，注释中文
class SendLoginCodeUseCase {
  /// 认证仓库
  final AuthRepository repository;

  SendLoginCodeUseCase(this.repository);

  /// 执行发送验证码
  Future<VerificationCodeInfo> execute(String email) {
    return repository.sendLoginCode(email);
  }
}