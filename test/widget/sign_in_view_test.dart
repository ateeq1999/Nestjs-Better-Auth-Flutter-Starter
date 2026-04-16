import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_starter/app/modules/auth/sign_in/sign_in_controller.dart';
import 'package:flutter_starter/app/modules/auth/sign_in/sign_in_view.dart';

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

  @override
  void togglePasswordVisibility() {}

  @override
  void goToForgotPassword() {}

  @override
  void goToSignUp() {}

  @override
  Future<void> signIn() async {}
}

void main() {
  late MockSignInController mockController;

  setUp(() {
    Get.testMode = true;
    mockController = MockSignInController();
    Get.put<SignInController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestWidget() {
    return GetMaterialApp(home: const SignInView());
  }

  group('SignInView renders form fields', () {
    testWidgets('displays email TextFormField', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('displays password TextFormField', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('displays Sign In button in ElevatedButton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign In'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays Forgot Password link', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('displays Sign Up link', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('displays password visibility toggle icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('displays AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Sign In'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
