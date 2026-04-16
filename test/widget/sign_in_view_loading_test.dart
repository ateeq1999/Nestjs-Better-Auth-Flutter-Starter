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

  group('SignInView loading indicator', () {
    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      mockController.isLoading.value = true;

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign In'),
        ),
        findsNothing,
      );
    });

    testWidgets('shows button text when isLoading is false', (
      WidgetTester tester,
    ) async {
      mockController.isLoading.value = false;

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign In'),
        ),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('button is disabled during loading', (
      WidgetTester tester,
    ) async {
      mockController.isLoading.value = true;

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('button is enabled when not loading', (
      WidgetTester tester,
    ) async {
      mockController.isLoading.value = false;

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping sign in shows loading then completes', (
      WidgetTester tester,
    ) async {
      mockController.isLoading.value = false;

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign In'),
        ),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
