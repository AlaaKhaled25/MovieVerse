import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Provider that manages the Firebase Authentication state.
///
/// It exposes the current [FirebaseUser] (or null when logged out) and
/// wraps the async auth operations so the UI can simply call these methods
/// and rebuild reactively via NotifyListeners. All Firebase errors are
/// translated into friendly messages.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    // Listen to auth state changes so login/logout is reflected everywhere
    // without manual wiring.
    _auth.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  /// True only while the app is waiting for Firebase to resolve the
  /// initial auth state (useful to show a splash screen).
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  /// Returns true when a user is currently signed in.
  bool get isAuthenticated => _user != null;

  /// The currently signed-in user (or null).
  User? get user => _user;

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
  Future<void> logout() async {
    await _auth.signOut();
  }

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

/// Simple thrown exception for surfacing friendly auth errors to the UI.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
