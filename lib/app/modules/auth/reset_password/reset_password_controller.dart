import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth.repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/snackbar_helper.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  String get token => Get.arguments?['token'] ?? '';

  AuthRepository get _authRepository => Get.find<AuthRepository>();

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> reset() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authRepository.resetPassword(
        token: token,
        password: passwordController.text,
      );
      SnackbarHelper.showSuccess('Password reset successful!');
      Get.offAllNamed(AppRoutes.signIn);
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
