import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartpos_mobile_manager/views/products/product_list_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Commented out for Dev Mode
// import '../services/auth_service.dart'; // Commented out for Dev Mode

class AuthController extends GetxController {
  // --- REAL DEPENDENCIES (Commented Out) ---
  // final AuthService _authService = Get.put(AuthService());

  // --- OBSERVABLES ---
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  // final Rxn<User> currentUser = Rxn<User>(); // Firebase user ki zaroorat nahi
  final RxBool isLoggedIn = false.obs; // Simple boolean for Dev Mode

  @override
  void onInit() {
    super.onInit();
    // Real listener off kar diya hai taakay error na aye
  }

  // --- DUMMY LOGIN ---
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Fake Network Delay (1 second) taakay loading spinner check ho sakay
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      // Success Logic
      isLoggedIn.value = true;
      Get.snackbar(
        'Dev Mode',
        'Login Bypassed! Welcome Admin.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to Dashboard
      // AuthController already registered, ProductListScreen will Get.put(ProductController)
      Get.offAll(
        () => ProductListScreen(),
        binding: BindingsBuilder(() {
          // Ensure AuthController stays available for ProductController
          if (!Get.isRegistered<AuthController>()) {
            Get.put(AuthController());
          }
        }),
      );
    } else {
      // Fail Logic
      errorMessage.value = 'Email and Password required';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  // --- DUMMY SIGNUP ---
  Future<void> signUp(
    String email,
    String password, [
    String? name,
    String? phone,
  ]) async {
    isLoading.value = true;
    errorMessage.value = '';

    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      isLoggedIn.value = true;
      Get.snackbar(
        'Dev Mode',
        'Fake Account Created!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/dashboard');
    } else {
      errorMessage.value = 'Invalid Email or Password (min 6 chars)';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  // --- DUMMY LOGOUT ---
  Future<void> logout() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    isLoggedIn.value = false;

    // Navigate back to Login Screen
    // Ensure '/login' route exists or use: Get.offAll(() => LoginScreen());
    Get.offAllNamed('/login');

    isLoading.value = false;
  }

  // --- CRITICAL HELPER FOR PRODUCT CONTROLLER ---
  // ProductController mein humne check lagaya tha:
  // if (await Get.find<AuthController>().isOnline()) ...
  // Iska faida: Products automatically Firebase par sync honge.

  Future<bool> isOnline() async {
    // Now returning TRUE so Firebase sync works
    // In production, you can add actual connectivity check here
    return true;
  }
}
