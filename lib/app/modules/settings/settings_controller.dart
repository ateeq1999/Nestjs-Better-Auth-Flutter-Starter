import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/auth.repository.dart';
import '../../core/utils/snackbar_helper.dart';

class SettingsController extends GetxController {
  AuthService get _authService => Get.find<AuthService>();
  AuthRepository get _authRepository => Get.find<AuthRepository>();
  final _storage = GetStorage();

  final isLoading = false.obs;
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read('isDarkMode') ?? false;
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    isLoading.value = true;
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      SnackbarHelper.showSuccess('Password changed successfully');
      Get.back();
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              changePassword(
                currentPassController.text,
                newPassController.text,
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
