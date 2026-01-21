import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/screens/home_screen.dart';
import '../ui/widgets/update_checker.dart';
import 'router.dart';
import 'settings_notifier.dart';
import 'theme.dart';

class ImpostorApp extends ConsumerWidget {
  const ImpostorApp({super.key});

  /// Convierte un string de locale (ej: "es-AR") a un objeto Locale de Flutter
  static Locale _parseLocale(String localeString) {
    final parts = localeString.split('-');
    if (parts.length >= 2) {
      return Locale(parts[0].toLowerCase(), parts[1].toUpperCase());
    } else if (parts.isNotEmpty) {
      return Locale(parts[0].toLowerCase());
    }
    return const Locale('es', 'AR'); // Fallback
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    
    // Obtener el locale de los settings, con fallback a es-AR
    final localeString = settingsAsync.valueOrNull?.locale ?? 'es-AR';
    final locale = _parseLocale(localeString);
    
    return MaterialApp.router(
      title: 'Impostor',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.dark,
      locale: locale, // ✅ Aplicar el locale de los settings
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('es', 'AR'),
        Locale('es', 'ES'),
        Locale('es', 'MX'),
      ],
      builder: (context, child) {
        // UpgradeAlert debe estar dentro del builder para tener acceso al contexto
        return UpdateChecker(
          // Modo debug: solo activo en modo debug de Flutter
          // En producción (release), siempre será false automáticamente
          debugMode: kDebugMode,
          child: child ?? const HomeScreen(),
        );
      },
    );
  }
}

