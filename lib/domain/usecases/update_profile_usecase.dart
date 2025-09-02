import '../../data/repository/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<bool> execute({
    String? username,
    String? email,
  }) {
    return repository.updateProfile(
      username: username,
      email: email,
    );
  }
}
