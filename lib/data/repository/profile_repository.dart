import '../api/profile_api.dart';
import '../models/profile_api_model.dart';
import '../../domain/entities/profile.dart';

class ProfileRepository {
  final ProfileApi _profileApi;

  ProfileRepository(this._profileApi);

  Future<Profile> getProfile() async {
    final ProfileApiModel apiModel = await _profileApi.fetchProfile();
    // 转换为业务实体
    return Profile(
      userId: apiModel.userId,
      username: apiModel.username,
      email: apiModel.email,
    );
  }
}