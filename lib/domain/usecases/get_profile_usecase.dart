import '../../data/repository/profile_repository.dart';
import '../entities/profile.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Profile> execute({Profile? existingProfile}) {
    return repository.getProfile(existingProfile: existingProfile);
  }

  // 新增：获取激活分页
  Future<ActivatePage> executeFetchActivate({int page = 1, int size = 10}) {
    return repository.getActivatePage(page: page, size: size);
  }

  // 新增：获取打卡分页
  Future<CheckinPage> executeFetchCheckins({int page = 1, int size = 10}) {
    return repository.getCheckinPage(page: page, size: size);
  }

  // 新增：获取挑战分页
  Future<ChallengePage> executeFetchChallenges({int page = 1, int size = 10}) {
    return repository.getChallengePage(page: page, size: size);
  }

  // 新增：删除用户账号
  Future<bool> executeDeleteAccount() {
    return repository.deleteAccount();
  }
}
