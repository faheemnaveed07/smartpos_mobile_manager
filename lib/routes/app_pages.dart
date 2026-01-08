import 'package:get/get.dart';
import 'package:smartpos_mobile_manager/bindings/app_binding.dart';
import 'package:smartpos_mobile_manager/views/auth/signup_screen.dart';
import 'package:smartpos_mobile_manager/views/pos/pos_screen.dart';
import 'package:smartpos_mobile_manager/views/products/add_product_screen.dart';
import 'package:smartpos_mobile_manager/views/products/product_list_screen.dart';
import '../views/splash/splash_screen.dart';
import '../views/auth/login_screen.dart';

class AppPages {
  static const INITIAL = '/splash';

  static final routes = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(
      name: '/login',
      page: () => LoginScreen(),
      binding: AppBinding(),
      // binding: AuthBinding(), // Yeh baad mein add karna hai
    ),
    GetPage(name: '/pos', page: () => POSScreen(), binding: AppBinding()),
    GetPage(
      name: '/add-product',
      page: () => AddProductScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: '/edit-product',
      page: () => AddProductScreen(), // Reuse same screen for edit
      binding: AppBinding(),
    ),
    GetPage(name: '/signup', page: () => SignupScreen(), binding: AppBinding()),
    // GetPage(
    //   name: '/dashboard',
    //   page: () => ProductListScreen(),
    //   binding: AppBinding(),
    // ),
  ];
}
