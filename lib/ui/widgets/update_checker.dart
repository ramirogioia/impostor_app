import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

/// Widget que verifica automáticamente si hay actualizaciones disponibles
/// y muestra un diálogo cuando es necesario.
///
/// **Cómo funciona:**
/// - Consulta directamente las APIs públicas del App Store (iOS) y Google Play (Android)
/// - NO requiere backend propio
/// - Compara la versión instalada con la disponible en el store
/// - Muestra un diálogo solo cuando hay una nueva versión disponible
///
/// **Configuración:**
/// - iOS: App Store ID configurado (6757995242)
/// - Android: El package name se detecta automáticamente del `applicationId` en `build.gradle`
class UpdateChecker extends StatelessWidget {
  const UpdateChecker({
    super.key,
    required this.child,
    this.debugMode = false,
  });

  final Widget child;
  
  /// Modo debug: solo para desarrollo y testing
  /// En producción, siempre debe ser `false`
  final bool debugMode;

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        // Nota: El App Store ID se detecta automáticamente del Bundle ID (com.rgioia.impostorwords)
        // Apple ID: 6757995242 - Este se usa internamente por el paquete upgrader
        
        // Duración antes de mostrar el diálogo nuevamente
        durationUntilAlertAgain: debugMode ? const Duration(seconds: 0) : const Duration(days: 3),
        
        // Configuración de debug (solo activa cuando debugMode es true)
        debugDisplayAlways: debugMode,
        debugLogging: debugMode && kDebugMode,
        
        // Versión mínima requerida (solo en modo debug para testing)
        minAppVersion: debugMode ? '999.0.0' : null,
      ),
      child: child,
    );
  }
}

