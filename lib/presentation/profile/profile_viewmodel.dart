import 'package:flutter/material.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/entities/profile.dart';
import '../../domain/services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final ProfileService profileService;

  Profile? profile;
  String? error;
  bool get isProfileComplete => profile != null && profileService.isProfileComplete(profile!);

  ProfileViewModel({
    required this.getProfileUseCase,
    required this.profileService,
  });

  Future<void> loadProfile() async {
    try {
      profile = await getProfileUseCase.execute();
      error = null;
    } catch (e) {
      error = e.toString();
      profile = null;
    }
    notifyListeners();
  }
}