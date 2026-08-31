import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/auth_form.dart';

/// The main authentication screen containing both Login and Register forms.
///
/// A segmented control lets the user switch between the two modes. This is
/// shown by [AuthGate] whenever the user is not authenticated.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  /// Whether the register form or login form is currently shown.
  bool _isRegister = true;

  void _toggleMode() {
    setState(() => _isRegister = !_isRegister);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // App branding.
              const Icon(Icons.movie, size: 72, color: AppColors.accent),
              const SizedBox(height: 8),
              const Text(
                'MovieVerse',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your personal cinema companion',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Toggle between Login and Register.
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Login'),
                    icon: Icon(Icons.login),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Register'),
                    icon: Icon(Icons.person_add),
                  ),
                ],
                selected: {_isRegister},
                onSelectionChanged: (sel) => setState(() => _isRegister = sel.first),
              ),
              const SizedBox(height: 24),

              AuthForm(isRegister: _isRegister),

              const SizedBox(height: 16),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isRegister
                      ? 'Already have an account? Login'
                      : "Don't have an account? Register",
                  style: const TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
