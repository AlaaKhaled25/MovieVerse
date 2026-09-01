import 'package:firebase_auth/firebase_auth.dart';

/// Thrown to surface friendly authentication errors to the UI.
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

/// Controller that owns the Firebase Authentication BUSINESS logic.
///
/// This is the "C" in the MVC layering:
///   View (auth_form/widgets) -> Provider (AuthProvider, reactive state)
///   -> Controller (this class, operations + error translation) -> Firebase SDK
///
/// The controller holds NO UI state; it only performs operations and exposes
/// the auth-state stream. Provider wraps it for reactive state management.
class AuthController {
  AuthController() : _auth = FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Stream of auth-state changes (user, or null when signed out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs the user in with the provided email/password.
  ///
  /// Throws an [AuthException] with a friendly message on failure.
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

  /// Creates a new account with the provided email/password.
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

  /// Signs the current user out.
  Future<void> logout() => _auth.signOut();

  /// Maps a raw [FirebaseAuthException] code to a friendly, user-safe message.
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