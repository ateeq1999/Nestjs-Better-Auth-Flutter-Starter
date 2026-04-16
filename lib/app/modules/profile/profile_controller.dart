import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../data/repositories/user.repository.dart';
import '../../core/utils/snackbar_helper.dart';

class ProfileController extends GetxController {
  AuthService get _authService => Get.find<AuthService>();
  UserRepository get _userRepository => Get.find<UserRepository>();

  final isLoading = false.obs;
  final imagePicker = ImagePicker();

  String get userName => _authService.currentUser.value?.name ?? '';
  String get userEmail => _authService.currentUser.value?.email ?? '';

  Future<void> pickAndUploadAvatar() async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        isLoading.value = true;
        final user = await _userRepository.uploadAvatar(pickedFile.path);
        await _authService.setCurrentUser(user);
        SnackbarHelper.showSuccess('Avatar updated successfully');
      }
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateName(String name) async {
    if (name.isEmpty) return;
    isLoading.value = true;
    try {
      final user = await _userRepository.updateProfile(name: name);
      await _authService.setCurrentUser(user);
      SnackbarHelper.showSuccess('Name updated successfully');
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void showEditNameDialog() {
    final textController = TextEditingController(text: userName);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              updateName(textController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
