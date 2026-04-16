import 'package:get/get.dart';
import '../../../data/repositories/auth.repository.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/snackbar_helper.dart';

class VerifyEmailController extends GetxController {
  final isVerified = false.obs;
  final isLoading = false.obs;

  String get token => Get.arguments?['token'] ?? '';

  AuthRepository get _authRepository => Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    if (token.isNotEmpty) {
      verify();
    }
  }

  Future<void> verify() async {
    if (token.isEmpty) return;

    isLoading.value = true;
    try {
      await _authRepository.verifyEmail(token: token);
      isVerified.value = true;
    } catch (e) {
      SnackbarHelper.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignIn() {
    Get.offAllNamed(AppRoutes.signIn);
  }
}
