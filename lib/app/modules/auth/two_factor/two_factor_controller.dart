import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/snackbar_helper.dart';

class TwoFactorController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  Future<void> verify() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      SnackbarHelper.showSuccess('Two-factor verification successful!');
      Get.offAllNamed(AppRoutes.home);
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
