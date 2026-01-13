import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: Colors.deepPurple,
      secondary: Colors.orangeAccent,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: Colors.deepPurple.shade200,
      secondary: Colors.orangeAccent,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
}

