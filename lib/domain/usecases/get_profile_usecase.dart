import '../../data/repository/profile_repository.dart';
import '../entities/profile.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Profile> execute() {
    return repository.getProfile();
  }
}