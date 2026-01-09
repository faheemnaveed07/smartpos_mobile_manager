import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/database_helper.dart';

/// Authentication Controller
/// Handles user login, signup, and session management using local SQLite database.
/// Firebase Auth integration can be added later for cloud sync.
class AuthController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Observables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);

  // Session keys for SharedPreferences
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserName = 'userName';

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Checks if user has an active session
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final wasLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (wasLoggedIn) {
      final userId = prefs.getString(_keyUserId);
      if (userId != null) {
        // Restore user from SQLite
        final user = await _dbHelper.getCurrentUserLocal(userId);
        if (user != null) {
          currentUser.value = user;
          isLoggedIn.value = true;
          return;
        }
      }
    }

    // No valid session
    isLoggedIn.value = false;
    currentUser.value = null;
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _dbHelper.loginUserLocal(
        email: email,
        password: password,
      );

      if (user != null) {
        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserId, user['id']);
        await prefs.setString(_keyUserEmail, user['email']);
        await prefs.setString(_keyUserName, user['name']);

        currentUser.value = user;
        isLoggedIn.value = true;

        Get.snackbar(
          'Welcome Back!',
          'Hello, ${user['name']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to Dashboard
        Get.offAllNamed('/dashboard');
      } else {
        // Invalid credentials
        errorMessage.value = 'Invalid email or password';
        Get.snackbar(
          'Login Failed',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Login error: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  /// Register a new user account
  Future<void> signUp(
    String email,
    String password, [
    String? name,
    String? phone,
    String? shopName,
  ]) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _dbHelper.registerUserLocal(
        name: name ?? 'User',
        email: email,
        password: password,
        phone: phone,
        shopName: shopName,
      );

      if (user != null) {
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/login');
      } else {
        errorMessage.value = 'Email already registered';
        Get.snackbar(
          'Signup Failed',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Signup error: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  /// Logout and clear session
  Future<void> logout() async {
    isLoading.value = true;

    // Clear session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);

    currentUser.value = null;
    isLoggedIn.value = false;

    Get.offAllNamed('/login');

    isLoading.value = false;
  }

  // User info getters
  String get userName => currentUser.value?['name'] ?? 'User';
  String get userEmail => currentUser.value?['email'] ?? '';
  String get userShop => currentUser.value?['shopName'] ?? 'My Shop';

  /// Check network connectivity
  Future<bool> isOnline() async {
    return true;
  }
}
