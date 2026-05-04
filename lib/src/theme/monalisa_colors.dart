import 'package:flutter/material.dart';

class MonalisaColors {
  const MonalisaColors._();

  static const Color primary = Color(0xFFE08E1D);
  static const Color primaryDark = Color(0xFFAF6B04);
  static const Color secondary = Color(0xFF2D404A);
  static const Color secondaryLight = Color(0xFFE6EEF2);
  static const Color danger = Color(0xFFD32F2F);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFC107);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF5F5F5);
  static const Color text = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF616161);
  static const Color border = Color(0xFFBDBDBD);
}

class MonalisaTheme {
  const MonalisaTheme._();

  static ThemeData light({Color primary = MonalisaColors.primary}) {
    final colorScheme = ColorScheme.fromSeed(seedColor: primary);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MonalisaColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MonalisaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
