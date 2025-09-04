import '../api/profile_api.dart';
import '../models/profile_api_model.dart';
import '../../domain/entities/profile.dart';
import 'package:flutter/material.dart';

class ProfileRepository {
  final ProfileApi _profileApi;

  ProfileRepository(this._profileApi);

  Future<Profile> getProfile({Profile? existingProfile}) async {
    final ProfileApiModel apiModel = await _profileApi.fetchProfile();
    return _convertApiModelToProfile(apiModel, existingProfile: existingProfile);
  }

  // 新增：获取激活分页并转换为业务实体列表
  Future<ActivatePage> getActivatePage({int page = 1, int size = 10}) async {
    final ActivatePageApiModel apiModel = await _profileApi.fetchActivatePage(page: page, size: size);
    return ActivatePage(
      activate: apiModel.activate
          .map((e) => Activate(
                challengeId: e.challengeId,
                challengeName: e.challengeName,
                productId: e.productId,
                productName: e.productName,
              ))
          .toList(),
      total: apiModel.total,
      currentPage: apiModel.currentPage,
      pageSize: apiModel.pageSize,
    );
  }

  // 新增：提交激活码
  Future<bool> submitActivationCode(String productId, String activationCode) async {
    try {
      final response = await _profileApi.submitActivationCode(productId, activationCode);
      return response.submitted;
    } catch (e) {
      print('Failed to submit activation code: $e');
      return false;
    }
  }

  // 新增：获取打卡分页并转换为业务实体列表
  Future<CheckinPage> getCheckinPage({int page = 1, int size = 10}) async {
    final CheckinPageApiModel apiModel = await _profileApi.fetchCheckinPage(page: page, size: size);
    return CheckinPage(
      checkinRecords: apiModel.checkinRecords
          .map((e) => CheckinRecord(
                id: e.id,
                productId: e.productId,
                index: e.index,
                name: e.name,
                status: e.status,
                timestep: e.timestep,
                rank: e.rank,
              ))
          .toList(),
      total: apiModel.total,
      currentPage: apiModel.currentPage,
      pageSize: apiModel.pageSize,
    );
  }

  // 新增：获取挑战分页并转换为业务实体列表
  Future<ChallengePage> getChallengePage({int page = 1, int size = 10}) async {
    final ChallengePageApiModel apiModel = await _profileApi.fetchChallengePage(page: page, size: size);
    return ChallengePage(
      challengeRecords: apiModel.challengeRecords
          .map((e) => ChallengeRecord(
                id: e.id,
                challengeId: e.challengeId,
                index: e.index,
                name: e.name,
                status: e.status,
                timestep: e.timestep,
                rank: e.rank,
              ))
          .toList(),
      total: apiModel.total,
      currentPage: apiModel.currentPage,
      pageSize: apiModel.pageSize,
    );
  }

  // 新增：用户信息更新
  Future<bool> updateProfile({
    String? username,
    String? email,
  }) async {
    try {
      final response = await _profileApi.updateProfile(
        username: username,
        email: email,
      );
      return response.updated;
    } catch (e) {
      print('Failed to update profile: $e');
      return false;
    }
  }

  // 新增：删除用户账号
  Future<bool> deleteAccount() async {
    try {
      final response = await _profileApi.deleteAccount();
      return response.deleted;
    } catch (e) {
      print('Failed to delete account: $e');
      return false;
    }
  }

  // 转换API模型为业务实体（仅基础信息）
  Profile _convertApiModelToProfile(ProfileApiModel apiModel, {Profile? existingProfile}) {
    return Profile(
      user: User(
        userId: apiModel.user.userId,
        username: apiModel.user.username,
        email: apiModel.user.email,
        avatarUrl: apiModel.user.avatarUrl,
      ),
      stats: UserStats(
        currentStreak: apiModel.stats.currentStreak,
        daysThisYear: apiModel.stats.daysThisYear,
        daysAllTime: apiModel.stats.daysAllTime,
      ),
      honors: apiModel.honors
          .map((e) => Honor(
                id: e.id,
                icon: _convertIconStringToIconData(e.icon),
                label: e.label,
                description: e.description,
                timestep: e.timestep,
              ))
          .toList(),
      // 保持现有数据，避免清空已加载的分页数据
      challengeRecords: existingProfile?.challengeRecords ?? [],
      checkinRecords: existingProfile?.checkinRecords ?? [],
      activate: existingProfile?.activate ?? [],
    );
  }

  // 将字符串图标转换为 IconData
  IconData _convertIconStringToIconData(String iconString) {
    switch (iconString) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'celebration':
        return Icons.celebration;
      case 'flash_on':
        return Icons.flash_on;
      case 'announcement':
        return Icons.announcement;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'pool':
        return Icons.pool;
      case 'directions_run':
        return Icons.directions_run;
      case 'bike_scooter':
        return Icons.bike_scooter;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.star; // 默认图标
    }
  }
}
