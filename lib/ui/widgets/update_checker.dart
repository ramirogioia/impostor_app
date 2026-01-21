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
/// **Configuración necesaria cuando publiques:**
/// - iOS: Configurar `appStoreId` en `Upgrader` con tu App ID de App Store Connect
/// - Android: El package name se detecta automáticamente del `applicationId` en `build.gradle`
///
/// **Ejemplo de uso:**
/// ```dart
/// UpdateChecker(
///   child: YourApp(),
/// )
/// ```
///
/// **Para configurar el App Store ID cuando publiques:**
/// Edita este archivo y agrega `appStoreId: 'tu-app-id'` en el constructor de `Upgrader`.
class UpdateChecker extends StatelessWidget {
  const UpdateChecker({
    super.key,
    required this.child,
    this.debugMode = false,
  });

  final Widget child;
  
  /// Modo debug: fuerza que el diálogo aparezca siempre (solo para testing)
  /// En producción, siempre debe ser `false`
  final bool debugMode;

  @override
  Widget build(BuildContext context) {
    if (debugMode) {
      // En modo debug, mostrar logs
      if (kDebugMode) {
        debugPrint('🔍 UpdateChecker: debugMode activado');
        debugPrint('🔍 UpdateChecker: debugDisplayAlways = true');
        debugPrint('🔍 UpdateChecker: El diálogo debería aparecer automáticamente');
      }
    }
    
    return UpgradeAlert(
      // Configuración básica de upgrader
      upgrader: Upgrader(
        // Cuando publiques en iOS, descomenta y agrega tu App Store ID:
        // appStoreId: '1234567890', // Reemplazar con tu App ID real
        
        // Duración antes de mostrar el diálogo nuevamente (opcional)
        durationUntilAlertAgain: debugMode ? const Duration(seconds: 0) : const Duration(days: 3),
        
        // Modo debug: fuerza que el diálogo aparezca siempre (solo para testing)
        // Funciona tanto en debug como en release cuando debugMode es true
        debugDisplayAlways: debugMode,
        debugLogging: debugMode && kDebugMode,
        
        // En modo debug, mostrar inmediatamente sin esperar
        minAppVersion: debugMode ? '999.0.0' : null,
      ),
      child: child,
    );
  }
}

