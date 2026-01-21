import 'package:flutter/material.dart';

/// Helper para detectar tablets y dispositivos grandes
class ResponsiveHelper {
  /// Detecta si el dispositivo es una tablet basándose en el ancho mínimo
  /// Usa 600dp como umbral (estándar de Material Design)
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    // Consideramos tablet si el lado más corto es >= 600dp
    return shortestSide >= 600;
  }

  /// Obtiene el ancho máximo recomendado para contenido en tablets
  /// Para tablets, usamos más espacio horizontal (hasta 900dp) para aprovechar mejor la pantalla
  static double getMaxContentWidth(BuildContext context) {
    if (isTablet(context)) {
      final width = MediaQuery.of(context).size.width;
      // En tablets, usar hasta 900dp o 85% del ancho, lo que sea menor
      // Esto permite layouts de dos columnas y elementos más grandes
      return width > 900 ? 900 : width * 0.85;
    }
    return double.infinity;
  }

  /// Obtiene padding horizontal adaptativo
  static double getHorizontalPadding(BuildContext context) {
    if (isTablet(context)) {
      return 48.0; // Más padding en tablets
    }
    return 24.0; // Padding normal en móviles
  }

  /// Obtiene padding vertical adaptativo
  static double getVerticalPadding(BuildContext context) {
    if (isTablet(context)) {
      return 32.0; // Más padding vertical en tablets
    }
    return 16.0; // Padding normal en móviles
  }

  /// Obtiene el número de columnas para grids en tablets
  static int getGridColumnCount(BuildContext context, {int mobileColumns = 1}) {
    if (isTablet(context)) {
      final width = MediaQuery.of(context).size.width;
      if (width >= 1200) {
        return 3; // Pantallas muy grandes: 3 columnas
      } else if (width >= 900) {
        return 2; // Tablets grandes: 2 columnas
      }
      return 2; // Tablets estándar: 2 columnas
    }
    return mobileColumns; // Móviles: 1 columna (o el especificado)
  }
}
