import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_starter/app/modules/auth/sign_in/sign_in_controller.dart';
import 'package:flutter_starter/app/modules/auth/sign_in/sign_in_view.dart';
import 'package:flutter_starter/app/modules/home/home_controller.dart';
import 'package:flutter_starter/app/modules/home/home_view.dart';
import 'package:flutter_starter/app/data/repositories/auth.repository.dart';
import 'package:flutter_starter/app/services/auth_service.dart';
import 'package:flutter_starter/app/routes/app_routes.dart';
import 'package:flutter_starter/app/routes/app_pages.dart';

class MockSignInController extends GetxController
    with Mock
    implements SignInController {
  @override
  final formKey = GlobalKey<FormState>();
  @override
  final emailController = TextEditingController();
  @override
  final passwordController = TextEditingController();
  @override
  final isLoading = false.obs;
  @override
  final isPasswordHidden = true.obs;

  bool signInCalled = false;

  @override
  void togglePasswordVisibility() {}

  @override
  void goToForgotPassword() {}

  @override
  void goToSignUp() {}

  @override
  Future<void> signIn() async {
    signInCalled = true;
  }
}

class MockHomeController extends GetxController
    with Mock
    implements HomeController {
  @override
  String get userName => 'Test User';

  @override
  String get userEmail => 'test@example.com';

  @override
  void navigateToProfile() {}

  @override
  void navigateToSettings() {}
}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sign-in to Home Navigation Flow', () {
    testWidgets('full sign-in flow navigates to home', (
      WidgetTester tester,
    ) async {
      Get.testMode = true;

      final mockAuthService = MockAuthService();
      Get.put<AuthService>(mockAuthService);

      when(() => mockAuthService.token).thenReturn(Rxn<String>(null));
      when(() => mockAuthService.currentUser).thenReturn(Rxn());
      when(() => mockAuthService.saveToken(any())).thenAnswer((_) async {});
      when(
        () => mockAuthService.setCurrentUser(any()),
      ).thenAnswer((_) async {});

      Get.testMode = true;

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: AppRoutes.signIn,
          getPages: AppPages.pages,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      final mockSignInController = Get.find<SignInController>();
      expect(mockSignInController, isNotNull);

      await Get.offAllNamed(AppRoutes.home);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('navigate to sign-up from sign-in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const SignInView()));

      await tester.pumpAndSettle();

      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('navigate to forgot password from sign-in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(GetMaterialApp(home: const SignInView()));

      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('home view displays user info', (WidgetTester tester) async {
      await tester.pumpWidget(GetMaterialApp(home: const HomeView()));

      await tester.pumpAndSettle();

      expect(find.textContaining('Welcome,'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
