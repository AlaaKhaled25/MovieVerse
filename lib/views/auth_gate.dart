import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/favourites_provider.dart';
import 'auth_screen.dart';
import 'bottom_nav.dart';
import 'splash_screen.dart';








class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  
  bool _splashMinElapsed = false;

  
  bool _forceSkipSplash = false;

  Timer? _minTimer;
  Timer? _capTimer;

  @override
  void initState() {
    super.initState();
    
    
    _minTimer = Timer(SplashScreen.minimumDuration, () {
      if (mounted) setState(() => _splashMinElapsed = true);
    });

    
    
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

    
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouritesProvider>().loadAll();
    });

    return const MainNavScreen();
  }
}