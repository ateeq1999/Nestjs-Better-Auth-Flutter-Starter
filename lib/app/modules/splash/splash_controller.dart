import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  AuthService get _authService => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (_authService.token.value != null) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.signIn);
    }
  }
}
