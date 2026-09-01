import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Animated, branded splash screen shown on app launch.
///
/// It plays a short fade-in + scale animation. The AuthGate decides for how
/// long it stays visible (minimum duration + cap), so this widget owns only
/// the visuals and holds no timer logic.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the splash should stay visible at minimum.
  static const Duration minimumDuration = Duration(milliseconds: 2000);

  /// Safety cap: never let the splash block the UI longer than this.
  static const Duration maximumDuration = Duration(seconds: 6);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut).drive(
      Tween<double>(begin: 0, end: 1),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
    ).drive(Tween<double>(begin: 0.6, end: 1));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Animated logo + name.
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rounded app icon with the movie glyph.
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.movie_filter,
                        size: 64,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'MovieVerse',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your personal cinema companion',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),
            // Bottom progress indicator.
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}