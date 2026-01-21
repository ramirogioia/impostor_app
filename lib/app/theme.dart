import 'package:flutter/material.dart';

const Color _brandBlue = Color(0xFF2A7BFF);
const Color _brandGlow = Color(0xFF0D1A33);
const Color _surfaceDark = Color(0xFF0B0F1A);
const Color _cardDark = Color(0xFF111827);

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandBlue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: _brandBlue,
    brightness: Brightness.dark,
    background: _surfaceDark,
    surface: _surfaceDark,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: _surfaceDark,
    appBarTheme: AppBarTheme(
      backgroundColor: _surfaceDark,
      centerTitle: true,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    cardColor: _cardDark,
    cardTheme: CardThemeData(
      color: _cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      shadowColor: _brandBlue.withOpacity(0.18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F1628),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.16)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brandBlue, width: 1.4),
      ),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.74)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.48)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        elevation: 4,
        shadowColor: _brandBlue.withOpacity(0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.24)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerColor: Colors.white.withOpacity(0.08),
    shadowColor: _brandGlow,
    splashColor: _brandBlue.withOpacity(0.12),
    highlightColor: _brandBlue.withOpacity(0.12),
  );
}

