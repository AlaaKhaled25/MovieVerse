import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/favourites_provider.dart';
import 'auth_screen.dart';
import 'bottom_nav.dart';
import 'splash_screen.dart';

/// A routing widget that decides what to show at app start:
///
///   Splash (>= minimum duration) -> Auth (Login/Register)  OR  Main app
///
/// The splash is kept on screen until Firebase has resolved the initial
/// auth state AND a short branded delay has elapsed, so we never flash a
/// login screen prematurely.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  /// Whether the splash's minimum display time has elapsed.
  bool _splashElapsed = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Keep showing the splash while Firebase resolves OR until the minimum
    // splash duration has passed.
    if (auth.isLoading || !_splashElapsed) {
      return SplashScreen(
        onFinished: () {
          if (mounted) setState(() => _splashElapsed = true);
        },
      );
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