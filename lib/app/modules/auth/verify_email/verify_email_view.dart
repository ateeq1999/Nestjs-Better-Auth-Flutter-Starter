import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'verify_email_controller.dart';

class VerifyEmailView extends GetView<VerifyEmailController> {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isVerified.value
                      ? Icons.check_circle
                      : Icons.mark_email_unread,
                  size: 100,
                  color: controller.isVerified.value
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(height: 32),
                Text(
                  controller.isVerified.value
                      ? 'Email Verified!'
                      : 'Verify Your Email',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.isVerified.value
                      ? 'Your email has been verified successfully.'
                      : 'Please check your email and click the verification link.',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (controller.isLoading.value)
                  const CircularProgressIndicator()
                else if (!controller.isVerified.value)
                  TextButton(
                    onPressed: controller.goToSignIn,
                    child: const Text('Go to Sign In'),
                  )
                else
                  ElevatedButton(
                    onPressed: controller.goToSignIn,
                    child: const Text('Continue'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
