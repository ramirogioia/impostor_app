import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/screens/home_screen.dart';
import '../ui/widgets/update_checker.dart';
import 'router.dart';
import 'theme.dart';

class ImpostorApp extends ConsumerWidget {
  const ImpostorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Impostor',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.dark,
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
          // Modo debug: activar para probar el diálogo de actualización
          // En producción, siempre debe ser false
          debugMode: true, // ✅ ACTIVADO para probar - Cambiar a false antes de publicar
          // Cuando publiques en iOS, descomenta y agrega tu App Store ID:
          // appStoreId: '1234567890', // Reemplazar con tu App ID real
          child: child ?? const HomeScreen(),
        );
      },
    );
  }
}

