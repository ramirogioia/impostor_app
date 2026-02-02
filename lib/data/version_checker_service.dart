import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../domain/models/app_version_info.dart';

class VersionCheckerService {
  static const String _versionUrl =
      'https://raw.githubusercontent.com/ramirogioia/dolar_argentina_back/main/versions/impostor.json';

  /// Consulta el JSON de versión desde GitHub
  static Future<AppVersionInfo?> fetchVersionInfo() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return AppVersionInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Compara la versión actual con la disponible
  /// Retorna: null si no hay actualización, 'soft' si es opcional, 'hard' si es forzada
  static Future<String?> checkForUpdate() async {
    final versionInfo = await fetchVersionInfo();
    if (versionInfo == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version.split('+').first; // Remover build number

    final needsUpdate = _compareVersions(currentVersion, versionInfo.version) < 0;
    final requiresUpdate = _compareVersions(
          currentVersion,
          versionInfo.versionMinima,
        ) <
        0;

    if (requiresUpdate) {
      return 'hard';
    } else if (needsUpdate) {
      return 'soft';
    }
    return null;
  }

  /// Obtiene la URL de la tienda según la plataforma
  static Future<String> getStoreUrl() async {
    final versionInfo = await fetchVersionInfo();
    if (versionInfo == null) {
      return '';
    }
    if (Platform.isIOS) {
      return versionInfo.urlTiendaIos;
    } else {
      return versionInfo.urlTiendaAndroid;
    }
  }

  /// Compara dos versiones semver
  /// Retorna: negativo si v1 < v2, 0 si son iguales, positivo si v1 > v2
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Asegurar misma longitud
    while (parts1.length < parts2.length) parts1.add(0);
    while (parts2.length < parts1.length) parts2.add(0);

    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    return 0;
  }

}

