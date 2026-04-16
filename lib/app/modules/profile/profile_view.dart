import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: controller.pickAndUploadAvatar,
                      child: const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: controller.pickAndUploadAvatar,
                      child: const Text('Change Avatar'),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      title: const Text('Name'),
                      subtitle: Text(controller.userName),
                      trailing: const Icon(Icons.edit),
                      onTap: controller.showEditNameDialog,
                    ),
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(controller.userEmail),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
