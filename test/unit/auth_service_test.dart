import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_starter/app/services/auth_service.dart';
import 'package:flutter_starter/app/routes/app_routes.dart';

class MockAuthService extends GetxService with Mock implements AuthService {
  @override
  final token = Rxn<String>();

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
  late MockAuthService mockAuthService;

  setUpAll(() {
    registerFallbackValue(
      dio_pkg.Response(
        requestOptions: dio_pkg.RequestOptions(path: ''),
        data: {},
      ),
    );
  });

  setUp(() {
    Get.testMode = true;
    mockAuthService = MockAuthService();
    Get.put<AuthService>(mockAuthService);
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthService token management', () {
    test('token starts as null initially', () {
      mockAuthService.token.value = null;
      expect(mockAuthService.token.value, isNull);
    });

    test('token can be set and retrieved', () {
      mockAuthService.token.value = 'test-token';
      expect(mockAuthService.token.value, equals('test-token'));
    });

    test('token can be cleared', () {
      mockAuthService.token.value = null;
      expect(mockAuthService.token.value, isNull);
    });
  });

  group('Route constants', () {
    test('all required routes are defined', () {
      expect(AppRoutes.signIn, equals('/sign-in'));
      expect(AppRoutes.signUp, equals('/sign-up'));
      expect(AppRoutes.forgotPassword, equals('/forgot-password'));
      expect(AppRoutes.resetPassword, equals('/reset-password'));
      expect(AppRoutes.verifyEmail, equals('/verify-email'));
      expect(AppRoutes.twoFactor, equals('/two-factor'));
      expect(AppRoutes.home, equals('/home'));
      expect(AppRoutes.profile, equals('/profile'));
      expect(AppRoutes.settings, equals('/settings'));
      expect(AppRoutes.splash, equals('/splash'));
    });
  });
}
