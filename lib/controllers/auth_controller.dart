import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  // Dependencies (line 5)
  final AuthService _authService = Get.put(AuthService());

  // Observables (line 8)
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Auth state listen karo (line 16)
    // TODO: Stream ko listen karo aur currentUser update karo
  }

  // Login method (line 20)
  Future<void> login(String email, String password) async {
    // Loading shuru karo
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // TODO: Auth service ko call karo
      // HINT: var user = await _authService.loginWithEmail(...)

      if (user != null) {
        // Success: Dashboard pe jao
        Get.offAllNamed('/dashboard');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Signup method (line 45)
  Future<void> signUp(
    String email,
    String password, [
    String? name,
    String? phone,
  ]) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _authService.signUpWithEmail(email, password);

      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed('/dashboard');
      } else {
        errorMessage.value = 'Signup failed';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method (line 50)
  Future<void> logout() async {
    // TODO: Logout karwao aur login screen pe bhejo
  }
}
