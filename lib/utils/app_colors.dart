import 'package:flutter/material.dart';

/// Centralised place for the application's visual style (colors, gradients,
/// spacing) so that the UI stays consistent and easy to tweak from one place.
class AppColors {
  AppColors._();

  /// Primary brand colour used across the app (a deep cinema-like blue).
  static const Color primary = Color(0xFF0F1B2B);

  /// Slightly lighter shade used for cards / surfaces.
  static const Color surface = Color(0xFF1B2A3F);

  /// Accent colour for buttons and highlights (amber/gold).
  static const Color accent = Color(0xFFF5C518);

  /// Deep navy for the top of the splash gradient.
  static const Color navyStart = Color(0xFF0B1424);

  /// Richer blue towards the bottom of the splash gradient.
  static const Color navyEnd = Color(0xFF1E3A5F);

  /// Standard text colour.
  static const Color textPrimary = Color(0xFFF5F5F5);

  /// Muted text colour for secondary information.
  static const Color textSecondary = Color(0xFFB0BEC5);
}

/// Shared spacing values so the layout stays consistent.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
