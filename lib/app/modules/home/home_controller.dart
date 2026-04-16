import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  AuthService get _authService => Get.find<AuthService>();

  String get userName => _authService.currentUser.value?.name ?? 'User';
  String get userEmail => _authService.currentUser.value?.email ?? '';

  void navigateToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  void navigateToSettings() {
    Get.toNamed(AppRoutes.settings);
  }
}
