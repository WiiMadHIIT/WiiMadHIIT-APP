import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/profile_api_model.dart';

class ProfileApi {
  final Dio _dio = DioClient().dio;

  Future<ProfileApiModel> fetchProfile() async {
    final response = await _dio.get('/api/profile');
    if (response.statusCode == 200 && response.data['code'] == 'A200') {
      return ProfileApiModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Unknown error');
    }
  }
}