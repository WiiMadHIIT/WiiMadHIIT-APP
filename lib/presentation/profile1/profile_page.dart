import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/profile.dart';
import '../../domain/services/profile_service.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../data/repository/profile_repository.dart';
import '../../data/api/profile_api.dart';
import '../profile1/profile_viewmodel.dart';

class ProfilePage1 extends StatelessWidget {
  const ProfilePage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        getProfileUseCase: GetProfileUseCase(ProfileRepository(ProfileApi())),
        profileService: ProfileService(),
      )..loadProfile(),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          // 错误处理
          if (vm.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Profile')),
              body: Center(child: Text('Error: ${vm.error}')),
            );
          }
          // 加载中
          if (vm.profile == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Profile')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          final Profile profile = vm.profile!;
          // 展示数据
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: ${profile.userId}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Username: ${profile.username}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Email: ${profile.email}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text(
                    vm.isProfileComplete ? 'Profile is complete' : 'Profile is incomplete',
                    style: TextStyle(
                      color: vm.isProfileComplete ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}