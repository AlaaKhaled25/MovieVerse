import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../controllers/auth_controller.dart';



export '../controllers/auth_controller.dart' show AuthException;







class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    
    
    _subscription = _controller.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  final AuthController _controller = AuthController();

  
  
  late final StreamSubscription<User?> _subscription;

  User? _user;

  
  
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  
  bool get isAuthenticated => _user != null;

  
  User? get user => _user;

  
  
  
  Future<void> login(String email, String password) =>
      _controller.login(email, password);

  
  Future<void> register(String email, String password) =>
      _controller.register(email, password);

  
  Future<void> logout() => _controller.logout();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}