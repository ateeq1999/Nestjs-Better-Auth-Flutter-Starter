import 'package:dio/dio.dart';

import '../models/auth_response.model.dart';
import '../providers/auth.provider.dart';
import '../../core/errors/app_exception.dart';

class AuthRepository {
  AuthRepository(this._provider);

  final AuthProvider _provider;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _provider.signIn(email: email, password: password);
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
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

  /// Verifies a TOTP two-factor code against the API (BUG-05 fix).
  Future<AuthResponse> verifyTwoFactor({required String code}) async {
    try {
      final response = await _provider.verifyTwoFactor(code: code);
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Returns the TOTP URI (otpauth://...) to render a QR code for 2FA setup.
  Future<String> enableTwoFactor() async {
    try {
      final response = await _provider.enableTwoFactor();
      final data = response.data as Map<String, dynamic>;
      return data['totpUri'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> disableTwoFactor({required String code}) async {
    try {
      await _provider.disableTwoFactor(code: code);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
