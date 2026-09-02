import 'package:firebase_auth/firebase_auth.dart';


class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}









class AuthController {
  AuthController() : _auth = FirebaseAuth.instance;

  final FirebaseAuth _auth;

  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  
  
  
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    }
  }

  
  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    }
  }

  
  Future<void> logout() => _auth.signOut();

  
  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}