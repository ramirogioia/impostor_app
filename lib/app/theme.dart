import 'package:flutter/material.dart';

const Color _brandBlue = Color(0xFF2A7BFF);
const Color _brandGlow = Color(0xFF0D1A33);
const Color _surfaceDark = Color(0xFF0B0F1A);
const Color _cardDark = Color(0xFF111827);

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: _brandBlue,
    brightness: Brightness.light,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.background,
      foregroundColor: scheme.onBackground,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      shadowColor: _brandBlue.withOpacity(0.12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brandBlue, width: 1.4),
      ),
      labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
      hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.55)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        elevation: 2,
        shadowColor: _brandBlue.withOpacity(0.25),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline.withOpacity(0.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    dividerColor: scheme.outline.withOpacity(0.2),
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
    cardTheme: CardTheme(
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

