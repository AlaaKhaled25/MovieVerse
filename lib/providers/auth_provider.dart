import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../controllers/auth_controller.dart';

// Re-export so existing consumers (e.g. auth_form.dart) can keep their
// `import 'providers/auth_provider.dart'` and still see AuthException.
export '../controllers/auth_controller.dart' show AuthException;

/// Provider that manages the Firebase Authentication REACTIVE state.
///
/// It exposes the current [User] (or null when logged out) and wraps the async
/// auth operations so the UI can simply call these methods and rebuild
/// reactively via notifyListeners. All actual auth logic (operations + error
/// translation) lives in [AuthController].
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    // Listen to auth state changes so login/logout is reflected everywhere
    // without manual wiring.
    _subscription = _controller.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  final AuthController _controller = AuthController();

  /// Subscription to the auth-state stream, cancelled in dispose() to avoid
  /// leaking the listener when this provider is destroyed.
  late final StreamSubscription<User?> _subscription;

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
  Future<void> login(String email, String password) =>
      _controller.login(email, password);

  /// Creates a new account with the provided email/password.
  Future<void> register(String email, String password) =>
      _controller.register(email, password);

  /// Signs the current user out.
  Future<void> logout() => _controller.logout();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}