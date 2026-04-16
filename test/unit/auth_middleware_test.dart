import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_starter/app/core/middleware/auth_middleware.dart';
import 'package:flutter_starter/app/services/auth_service.dart';
import 'package:flutter_starter/app/data/models/user.model.dart';
import 'package:flutter_starter/app/routes/app_routes.dart';

class TestAuthService extends GetxService implements AuthService {
  @override
  final token = Rxn<String>();

  @override
  final currentUser = Rxn<User>();

  @override
  Future<AuthService> init() async => this;

  @override
  Future<void> saveToken(String newToken) async {}

  @override
  Future<void> setCurrentUser(dynamic user) async {}

  @override
  Future<String?> getToken() async => token.value;

  @override
  Future<void> clearToken() async {}

  @override
  Future<bool> refreshToken() async => false;

  @override
  Future<void> signOut() async {}
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthMiddleware', () {
    test('redirects to sign-in when token is null', () {
      final authService = TestAuthService();
      authService.token.value = null;
      Get.put<AuthService>(authService);

      final middleware = AuthMiddleware();
      final result = middleware.redirect('/home');

      expect(result?.name, equals(AppRoutes.signIn));
    });

    test('does not redirect when token is empty string (treated as valid)', () {
      final authService = TestAuthService();
      authService.token.value = '';
      Get.put<AuthService>(authService);

      final middleware = AuthMiddleware();
      final result = middleware.redirect('/home');

      expect(result, isNull);
    });

    test('returns null (no redirect) when token exists', () {
      final authService = TestAuthService();
      authService.token.value = 'valid-token';
      Get.put<AuthService>(authService);

      final middleware = AuthMiddleware();
      final result = middleware.redirect('/home');

      expect(result, isNull);
    });

    test('has correct priority', () {
      final middleware = AuthMiddleware();
      expect(middleware.priority, equals(1));
    });
  });
}
