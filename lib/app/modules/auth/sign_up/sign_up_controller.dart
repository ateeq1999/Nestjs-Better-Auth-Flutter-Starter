import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth.repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/snackbar_helper.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  AuthRepository get _authRepository => Get.find<AuthRepository>();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authRepository.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
      );
      SnackbarHelper.showSuccess('Account created! Please check your email.');
      Get.offAllNamed(AppRoutes.signIn);
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignIn() {
    Get.back();
  }
}
