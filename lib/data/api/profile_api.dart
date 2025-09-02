import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/profile_api_model.dart';

class ProfileApi {
  final Dio _dio = DioClient().dio;

  Future<ProfileApiModel> fetchProfile() async {
    final response = await _dio.get(
      '/api/profile/list',
    );
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ProfileApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch profile');
    }
  }

  // 新增：获取激活关联分页列表（不包含 equipmentIds）
  Future<ActivatePageApiModel> fetchActivatePage({int page = 1, int size = 10}) async {
    final response = await _dio.get(
      '/api/profile/activate/list',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ActivatePageApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch activate list');
    }
  }

  // 新增：获取打卡记录分页
  Future<CheckinPageApiModel> fetchCheckinPage({int page = 1, int size = 10}) async {
    final response = await _dio.get(
      '/api/profile/checkin/list',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return CheckinPageApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch checkin list');
    }
  }

  // 新增：获取挑战记录分页
  Future<ChallengePageApiModel> fetchChallengePage({int page = 1, int size = 10}) async {
    final response = await _dio.get(
      '/api/profile/challenge/list',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ChallengePageApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch challenge list');
    }
  }

  // 新增：提交激活码接口
  Future<ActivationResponseApiModel> submitActivationCode(String productId, String activationCode) async {
    final response = await _dio.post(
      '/api/profile/activate',
      data: {
        'productId': productId,
        'activationCode': activationCode,
      },
    );
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ActivationResponseApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to submit activation code');
    }
  }

  // 新增：用户信息更新接口
  Future<ProfileUpdateResponseApiModel> updateProfile({
    String? username,
    String? email,
  }) async {
    final response = await _dio.put(
      '/api/profile/update',
      data: {
        'username': username,
        'email': email,
      },
    );
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ProfileUpdateResponseApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to update profile');
    }
  }

  // 新增：删除用户账号接口
  Future<ProfileDeleteResponseApiModel> deleteAccount() async {
    final response = await _dio.delete('/api/profile/delete');
    
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ProfileDeleteResponseApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to delete account');
    }
  }

  /// 创建荣誉记录
  HonorApiModel _createHonor(String id, String icon, String label, String description, int timestep) {
    return HonorApiModel(
      id: id,
      icon: icon,
      label: label,
      description: description,
      timestep: timestep
    );
  }

  /// 创建挑战记录
  ChallengeRecordApiModel _createChallengeRecord(String id, String challengeId, int index, String name, String status, int timestep, String rank) {
    return ChallengeRecordApiModel(
      id: id,
      challengeId: challengeId,
      index: index,
      name: name,
      status: status,
      timestep: timestep,
      rank: rank
    );
  }

  /// 创建打卡记录
  CheckinRecordApiModel _createCheckinRecord(String id, String productId, int index, String name, String status, int timestep, String rank) {
    return CheckinRecordApiModel(
      id: id,
      productId: productId,
      index: index,
      name: name,
      status: status,
      timestep: timestep,
      rank: rank
    );
  }

  /// 创建激活关联
  ActivateApiModel _createActivate(String challengeId, String challengeName, String productId, String productName) {
    return ActivateApiModel(
      challengeId: challengeId,
      challengeName: challengeName,
      productId: productId,
      productName: productName
    );
  }

  /// 生成随机用户头像URL（男性）
  String _generateMaleAvatar(int id) {
    return "https://randomuser.me/api/portraits/men/$id.jpg";
  }
}
