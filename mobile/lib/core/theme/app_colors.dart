import 'package:flutter/material.dart';

/// Single source of truth for every color used in the app.
/// Matches docs/design-system.html — update both together.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2F6FED);
  static const Color primaryLight = Color(0xFFE8F0FE);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color background = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFEF4444);

  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentPink = Color(0xFFEC4899);

  /// Rotating palette for avatars / subject icons where color has no
  /// fixed meaning — pick by index (e.g. name.hashCode % avatarPalette.length).
  static const List<Color> avatarPalette = [
    primary,
    accentPink,
    accentPurple,
    accentTeal,
    accentOrange,
  ];
}
