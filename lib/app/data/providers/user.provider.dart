import 'package:dio/dio.dart';

class UserProvider {
  UserProvider(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getMe() => _dio.get('/api/users/me');

  Future<Response<dynamic>> updateProfile({String? name, String? email}) {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    return _dio.patch('/api/users/me', data: data);
  }

  Future<Response<dynamic>> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    return _dio.post(
      '/api/users/me/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response<dynamic>> deleteAvatar() =>
      _dio.delete('/api/users/me/avatar');

  Future<Response<dynamic>> registerDeviceToken({
    required String token,
    required String platform,
  }) =>
      _dio.post(
        '/api/users/me/devices',
        data: {'token': token, 'platform': platform},
      );

  Future<Response<dynamic>> deleteDeviceToken({required String token}) =>
      _dio.delete('/api/users/me/devices', data: {'token': token});
}
