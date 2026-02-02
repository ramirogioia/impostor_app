class AppVersionInfo {
  const AppVersionInfo({
    required this.app,
    required this.version,
    required this.fechaPublicacion,
    required this.ultimaActualizacion,
    required this.requiereActualizacion,
    required this.versionMinima,
    required this.notasActualizacion,
    required this.urlTiendaAndroid,
    required this.urlTiendaIos,
  });

  final String app;
  final String version;
  final String fechaPublicacion;
  final String ultimaActualizacion;
  final bool requiereActualizacion;
  final String versionMinima;
  final List<String> notasActualizacion;
  final String urlTiendaAndroid;
  final String urlTiendaIos;

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      app: json['app'] as String,
      version: json['version'] as String,
      fechaPublicacion: json['fecha_publicacion'] as String,
      ultimaActualizacion: json['ultima_actualizacion'] as String,
      requiereActualizacion: json['requiere_actualizacion'] as bool,
      versionMinima: json['version_minima'] as String,
      notasActualizacion: (json['notas_actualizacion'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      urlTiendaAndroid: json['url_tienda_android'] as String,
      urlTiendaIos: json['url_tienda_ios'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app': app,
      'version': version,
      'fecha_publicacion': fechaPublicacion,
      'ultima_actualizacion': ultimaActualizacion,
      'requiere_actualizacion': requiereActualizacion,
      'version_minima': versionMinima,
      'notas_actualizacion': notasActualizacion,
      'url_tienda_android': urlTiendaAndroid,
      'url_tienda_ios': urlTiendaIos,
    };
  }
}

