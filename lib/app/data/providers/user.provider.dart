import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../services/dio_service.dart';

class UserProvider extends GetxService {
  late final dio.Dio _dio;

  UserProvider() {
    _dio = Get.find<DioService>().dio;
  }

  Future<dio.Response> getMe() async {
    return _dio.get('/api/users/me');
  }

  Future<dio.Response> updateProfile({String? name, String? email}) async {
    return _dio.patch('/api/users/me', data: {'name': name, 'email': email});
  }

  Future<dio.Response> uploadAvatar(String filePath) async {
    final formData = dio.FormData.fromMap({
      'avatar': await dio.MultipartFile.fromFile(filePath),
    });
    return _dio.post(
      '/api/users/me/avatar',
      data: formData,
      options: dio.Options(contentType: 'multipart/form-data'),
    );
  }

  Future<dio.Response> deleteAvatar() async {
    return _dio.delete('/api/users/me/avatar');
  }

  Future<dio.Response> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    return _dio.post(
      '/api/users/me/devices',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<dio.Response> deleteDeviceToken({required String token}) async {
    return _dio.delete('/api/users/me/devices', data: {'token': token});
  }
}
