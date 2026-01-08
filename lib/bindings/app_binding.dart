import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../services/auth_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services inject karo
    Get.lazyPut<AuthService>(() => AuthService());

    // Controllers inject karo
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }
    
    // ProductController - needed for POS and Products screens
    if (!Get.isRegistered<ProductController>()) {
      Get.put<ProductController>(ProductController());
    }
  }
}
