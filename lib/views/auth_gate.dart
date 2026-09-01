import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/favourites_provider.dart';
import 'auth_screen.dart';
import 'bottom_nav.dart';
import 'splash_screen.dart';

/// A routing widget that decides what to show at app start:
///
///   Splash (>= minimum duration, <= hard cap) -> Auth  OR  Main app
///
/// The splash stays until BOTH Firebase has resolved the initial auth state
/// AND the minimum branded delay has elapsed. A hard cap guarantees the user
/// is never trapped on the splash even if Firebase stalls.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  /// True once the splash's minimum display time has elapsed.
  bool _splashMinElapsed = false;

  /// True once the safety cap has passed (skip splash regardless).
  bool _forceSkipSplash = false;

  Timer? _minTimer;
  Timer? _capTimer;

  @override
  void initState() {
    super.initState();
    // The minimum-splash timer. Time-based (not child-State based), so a
    // widget rebuild or Firebase notification never restarts the splash.
    _minTimer = Timer(SplashScreen.minimumDuration, () {
      if (mounted) setState(() => _splashMinElapsed = true);
    });

    // Hard cap: never block the UI longer than this, even if Firebase is
    // slow to resolve its initial auth state.
    _capTimer = Timer(SplashScreen.maximumDuration, () {
      if (mounted) setState(() => _forceSkipSplash = true);
    });
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _capTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final showSplash =
        (auth.isLoading || !_splashMinElapsed) && !_forceSkipSplash;

    if (showSplash) {
      return const SplashScreen();
    }

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    // On login, load the user's persisted favourites & lists. Fire-and-forget
    // here; the provider will notify when done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouritesProvider>().loadAll();
    });

    return const MainNavScreen();
  }
}