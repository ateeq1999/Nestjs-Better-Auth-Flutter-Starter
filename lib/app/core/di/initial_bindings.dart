import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../../services/dio_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(DioService(), permanent: true);
    Get.put(AuthService(), permanent: true);
  }
}
