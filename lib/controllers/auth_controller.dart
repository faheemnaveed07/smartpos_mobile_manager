import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/database/database_helper.dart';

/// Authentication Controller
/// Uses Firebase Auth as primary and SQLite as local backup.
class AuthController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Observables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<Map<String, dynamic>?> localUser = Rx<Map<String, dynamic>?>(null);

  // Session keys
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserName = 'userName';
  static const String _keyShopName = 'shopName';

  @override
  void onInit() {
    super.onInit();
    _firebaseAuth.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
      if (user != null) {
        isLoggedIn.value = true;
      }
    });
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      firebaseUser.value = fbUser;
      isLoggedIn.value = true;
      await _loadLocalProfile(fbUser.uid);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final wasLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (wasLoggedIn) {
      final userId = prefs.getString(_keyUserId);
      if (userId != null) {
        final user = await _dbHelper.getCurrentUserLocal(userId);
        if (user != null) {
          localUser.value = user;
          isLoggedIn.value = true;
          return;
        }
      }
    }
    isLoggedIn.value = false;
  }

  Future<void> _loadLocalProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localId = prefs.getString(_keyUserId);
      if (localId != null) {
        localUser.value = await _dbHelper.getCurrentUserLocal(localId);
      }
    } catch (e) {
      debugPrint('Load local profile: $e');
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        firebaseUser.value = fbUser;
        isLoggedIn.value = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserId, fbUser.uid);
        await prefs.setString(_keyUserEmail, fbUser.email ?? email);
        await prefs.setString(_keyUserName, fbUser.displayName ?? 'User');

        await _loadLocalProfile(fbUser.uid);

        Get.snackbar(
          'Welcome Back!',
          'Hello, ${fbUser.displayName ?? 'User'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase login failed: ${e.code}, trying local...');
      await _loginLocal(email, password);
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  Future<void> _loginLocal(String email, String password) async {
    try {
      final user = await _dbHelper.loginUserLocal(
        email: email,
        password: password,
      );

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserId, user['id']);
        await prefs.setString(_keyUserEmail, user['email']);
        await prefs.setString(_keyUserName, user['name']);
        await prefs.setString(_keyShopName, user['shopName'] ?? 'My Shop');

        localUser.value = user;
        isLoggedIn.value = true;

        Get.snackbar(
          'Welcome Back!',
          'Hello, ${user['name']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/dashboard');
      } else {
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
  }

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
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        await fbUser.updateDisplayName(name ?? 'User');

        await _dbHelper.registerUserLocal(
          name: name ?? 'User',
          email: email,
          password: password,
          phone: phone,
          shopName: shopName,
        );

        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/login');
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getFirebaseErrorMessage(e.code);
      Get.snackbar(
        'Signup Failed',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  Future<void> logout() async {
    isLoading.value = true;

    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Firebase signout error: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyShopName);

    firebaseUser.value = null;
    localUser.value = null;
    isLoggedIn.value = false;

    Get.offAllNamed('/login');

    isLoading.value = false;
  }

  String get userName {
    if (firebaseUser.value?.displayName != null) {
      return firebaseUser.value!.displayName!;
    }
    return localUser.value?['name'] ?? 'User';
  }

  String get userEmail {
    return firebaseUser.value?.email ?? localUser.value?['email'] ?? '';
  }

  String get userShop {
    return localUser.value?['shopName'] ?? 'My Shop';
  }

  String get oderId {
    return firebaseUser.value?.uid ?? localUser.value?['id'] ?? '';
  }

  String _getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      return _getFirebaseErrorMessage(e.code);
    }
    return e.toString();
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication failed: $code';
    }
  }

  Future<bool> isOnline() async {
    return true;
  }
}
