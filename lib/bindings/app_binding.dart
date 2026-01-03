import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services inject karo (line 7)
    Get.lazyPut<AuthService>(() => AuthService());

    // Controllers inject karo (line 10)
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
