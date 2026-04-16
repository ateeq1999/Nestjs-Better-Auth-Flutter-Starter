import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../services/dio_service.dart';

class AuthProvider extends GetxService {
  late final dio.Dio _dio;

  AuthProvider() {
    _dio = Get.find<DioService>().dio;
  }

  Future<dio.Response> signIn({
    required String email,
    required String password,
  }) async {
    return _dio.post(
      '/api/auth/sign-in/email',
      data: {'email': email, 'password': password},
    );
  }

  Future<dio.Response> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return _dio.post(
      '/api/auth/sign-up/email',
      data: {'email': email, 'password': password, 'name': name},
    );
  }

  Future<dio.Response> signOut() async {
    return _dio.post('/api/auth/sign-out');
  }

  Future<dio.Response> getSession() async {
    return _dio.get('/api/auth/session');
  }

  Future<dio.Response> forgotPassword({required String email}) async {
    return _dio.post('/api/auth/forgot-password', data: {'email': email});
  }

  Future<dio.Response> resetPassword({
    required String token,
    required String password,
  }) async {
    return _dio.post(
      '/api/auth/reset-password',
      data: {'token': token, 'password': password},
    );
  }

  Future<dio.Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _dio.post(
      '/api/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<dio.Response> verifyEmail({required String token}) async {
    return _dio.post('/api/auth/verify-email', data: {'token': token});
  }

  Future<dio.Response> refreshToken() async {
    return _dio.post('/api/auth/token/refresh');
  }
}
