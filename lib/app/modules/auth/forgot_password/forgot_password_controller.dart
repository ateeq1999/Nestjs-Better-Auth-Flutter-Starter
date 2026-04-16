import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth.repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/snackbar_helper.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final isLoading = false.obs;

  AuthRepository get _authRepository => Get.find<AuthRepository>();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authRepository.forgotPassword(email: emailController.text.trim());
      SnackbarHelper.showSuccess('Password reset link sent to your email.');
      Get.offAllNamed(AppRoutes.signIn);
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }
}
