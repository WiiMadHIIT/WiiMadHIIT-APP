import '../../entities/auth/auth_entities.dart';
import '../../../data/repository/auth_repository.dart';

/// 发送注册验证码用例
/// - 对外字段英文，注释中文
class SendRegisterCodeUseCase {
  /// 认证仓库
  final AuthRepository repository;

  SendRegisterCodeUseCase(this.repository);

  /// 执行发送验证码
  Future<VerificationCodeInfo> execute(String email) {
    return repository.sendRegisterCode(email);
  }
}


