import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/favourites_provider.dart';
import 'auth_screen.dart';
import 'bottom_nav.dart';

/// A routing widget that shows the Login/Register screen when the user is
/// logged out, or the main app (bottom navigation) when they are logged in.
///
/// This is the heart of the authentication flow:
///   Splash -> Auth (Login/Register) -> Home
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // While firebase is resolving the initial auth state, show a splash.
    if (auth.isLoading) {
      return const _SplashScreen();
    }

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    // On login, load the user's persisted favourites & lists from SQLite.
    // We fire-and-forget here; the provider will notify when done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouritesProvider>().loadAll();
    });

    return const MainNavScreen();
  }
}

/// Simple splash shown while Firebase determines the auth state.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
