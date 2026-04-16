import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../data/models/user.model.dart';

class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final _tokenKey = 'auth_token';
  final _userKey = 'current_user';

  final token = Rxn<String>();
  final currentUser = Rxn<User>();

  Future<AuthService> init() async {
    token.value = await _storage.read(key: _tokenKey);
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      try {
        currentUser.value = User.fromJson(
          Map<String, dynamic>.from(
            Uri.splitQueryString(
              userData,
            ).map((key, value) => MapEntry(key, value)),
          ),
        );
      } catch (_) {
        currentUser.value = null;
      }
    }
    return this;
  }

  Future<void> saveToken(String newToken) async {
    token.value = newToken;
    await _storage.write(key: _tokenKey, value: newToken);
  }

  Future<void> setCurrentUser(User user) async {
    currentUser.value = user;
    await _storage.write(
      key: _userKey,
      value: Uri(
        queryParameters: user.toJson().map(
          (k, v) => MapEntry(k, v?.toString() ?? ''),
        ),
      ).query,
    );
  }

  Future<String?> getToken() async {
    return token.value;
  }

  Future<void> clearToken() async {
    token.value = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    currentUser.value = null;
  }

  Future<bool> refreshToken() async {
    return false;
  }

  Future<void> signOut() async {
    await clearToken();
    Get.offAllNamed('/sign-in');
  }
}
