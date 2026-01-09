import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication Service
/// This service handles Firebase-based authentication.
/// Currently using local SQLite auth (see AuthController).
/// This service will be used when Firebase billing is enabled.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login with email and password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Register with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;
}
