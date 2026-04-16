import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth.repository.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/snackbar_helper.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  AuthRepository get _authRepository => Get.find<AuthRepository>();
  AuthService get _authService => Get.find<AuthService>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await _authRepository.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await _authService.saveToken(response.token);
      await _authService.setCurrentUser(response.user);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void goToSignUp() {
    Get.toNamed(AppRoutes.signUp);
  }
}
