import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/auth_response.model.dart';
import '../providers/auth.provider.dart';
import '../../core/errors/app_exception.dart';

class AuthRepository extends GetxService {
  late final AuthProvider _provider;

  AuthRepository() {
    _provider = Get.put(AuthProvider());
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _provider.signIn(email: email, password: password);
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _provider.signUp(email: email, password: password, name: name);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _provider.signOut();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _provider.forgotPassword(email: email);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _provider.resetPassword(token: token, password: password);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _provider.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> verifyEmail({required String token}) async {
    try {
      await _provider.verifyEmail(token: token);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AuthResponse> refreshToken() async {
    try {
      final response = await _provider.refreshToken();
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
