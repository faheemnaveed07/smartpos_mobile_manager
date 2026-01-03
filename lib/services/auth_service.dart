import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user stream (line 5)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email (line 8)
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      // TODO: Complete this method
      // HINT: Use _auth.signInWithEmailAndPassword()
      return null; // Yahan user return karo
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Signup with email (line 18)
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      // TODO: Implement signup logic
      return null;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  // Logout (line 28)
  Future<void> logout() async {
    // TODO: Implement logout
  }

  // Get current user ID (line 33)
  String? getCurrentUserId() {
    // TODO: Return current user ID
    return null;
  }
}
