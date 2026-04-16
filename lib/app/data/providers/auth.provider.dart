import 'package:dio/dio.dart';

class AuthProvider {
  AuthProvider(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> signIn({
    required String email,
    required String password,
  }) =>
      _dio.post(
        '/api/auth/sign-in/email',
        data: {'email': email, 'password': password},
      );

  Future<Response<dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) =>
      _dio.post(
        '/api/auth/sign-up/email',
        data: {'email': email, 'password': password, 'name': name},
      );

  Future<Response<dynamic>> signOut() => _dio.post('/api/auth/sign-out');

  Future<Response<dynamic>> getSession() => _dio.get('/api/auth/session');

  Future<Response<dynamic>> forgotPassword({required String email}) =>
      _dio.post('/api/auth/forgot-password', data: {'email': email});

  Future<Response<dynamic>> resetPassword({
    required String token,
    required String password,
  }) =>
      _dio.post(
        '/api/auth/reset-password',
        data: {'token': token, 'password': password},
      );

  Future<Response<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _dio.post(
        '/api/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

  Future<Response<dynamic>> verifyEmail({required String token}) =>
      _dio.post('/api/auth/verify-email', data: {'token': token});

  Future<Response<dynamic>> verifyTwoFactor({required String code}) =>
      _dio.post('/api/auth/two-factor/verify', data: {'code': code});

  Future<Response<dynamic>> refreshToken() =>
      _dio.post('/api/auth/token/refresh');

  Future<Response<dynamic>> enableTwoFactor() =>
      _dio.post('/api/auth/two-factor/enable');

  Future<Response<dynamic>> disableTwoFactor({required String code}) =>
      _dio.post('/api/auth/two-factor/disable', data: {'code': code});
}
