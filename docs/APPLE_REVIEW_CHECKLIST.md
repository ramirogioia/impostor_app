# Lista de Verificación para Revisión de Apple App Store

Esta lista debe revisarse antes de enviar la app a revisión de Apple.

## ✅ Configuración de Update Checker

### 1. Modo Debug
- [x] **Completado**: El modo debug está configurado para activarse solo en `kDebugMode`
- [x] **Completado**: Los botones de test update están ocultos en producción
- [ ] **Pendiente**: Verificar que `debugMode: false` en builds de producción (ya está usando `kDebugMode`)

**Archivos modificados:**
- `lib/app/app.dart`: Usa `kDebugMode` en lugar de `true` hardcodeado
- `lib/ui/screens/setup_screen.dart`: Botón de test solo visible en debug
- `lib/ui/screens/settings_screen.dart`: Sección de testing solo visible en debug

### 2. App Store ID
- [ ] **Pendiente**: Configurar `appStoreId` en `lib/ui/widgets/update_checker.dart`
  - Descomentar la línea: `// appStoreId: '1234567890',`
  - Reemplazar `'1234567890'` con tu App ID real de App Store Connect
  - El App ID se encuentra en App Store Connect → Tu App → Información de la App → ID de la App

**Ubicación del código:**
```dart
// lib/ui/widgets/update_checker.dart
upgrader: Upgrader(
  appStoreId: 'TU_APP_ID_AQUI', // ⚠️ CONFIGURAR ANTES DE PUBLICAR
  // ... resto de configuración
)
```

### 3. Configuración de Upgrader en Settings Screen
- [x] **Completado**: Removido el `UpgradeAlert` hardcodeado de `settings_screen.dart`
- [x] **Completado**: El `UpdateChecker` principal en `app.dart` maneja todas las actualizaciones

## ✅ Funcionalidades de Debug

### Botones de Test
- [x] **Completado**: Botón de test update en `setup_screen.dart` solo visible en `kDebugMode`
- [x] **Completado**: Sección de testing en `settings_screen.dart` solo visible en `kDebugMode`

**Verificación:**
- En modo release, estos elementos NO deben aparecer
- En modo debug, deben aparecer para facilitar las pruebas

## ✅ Localización

### Idioma de la App
- [x] **Completado**: El `MaterialApp` ahora usa el locale de los settings
- [x] **Completado**: El paquete `upgrader` debería mostrar mensajes en el idioma configurado

**Archivo modificado:**
- `lib/app/app.dart`: Aplica el locale de `settingsNotifierProvider` al `MaterialApp`

## 📋 Checklist Pre-Envío

Antes de enviar a Apple App Store Review, verificar:

### Configuración Técnica
- [ ] Build en modo **Release** (`flutter build ios --release`)
- [ ] Verificar que `kDebugMode` sea `false` en release (automático)
- [ ] Configurar `appStoreId` en `update_checker.dart`
- [ ] Probar que el diálogo de actualización funcione correctamente
- [ ] Verificar que los botones de test NO aparezcan en release

### Contenido y Funcionalidad
- [ ] Probar todas las funcionalidades principales de la app
- [ ] Verificar que los textos estén correctamente localizados
- [ ] Probar el flujo completo del juego
- [ ] Verificar que no haya errores de consola en release

### Información de la App Store
- [ ] Descripción de la app completa
- [ ] Screenshots actualizados
- [ ] Icono de la app configurado
- [ ] Categoría correcta seleccionada
- [ ] Edad mínima configurada
- [ ] Política de privacidad (si aplica)

### Requisitos de Apple
- [ ] App funciona sin conexión a internet (si es el caso)
- [ ] No hay enlaces rotos o funcionalidades incompletas
- [ ] La app no crashea en dispositivos de prueba
- [ ] Cumple con las guías de diseño de Apple (Human Interface Guidelines)

## 🔧 Cómo Configurar el App Store ID

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Selecciona tu app
3. Ve a "Información de la App"
4. Busca "ID de la App" (es un número como `1234567890`)
5. Copia ese ID
6. Abre `lib/ui/widgets/update_checker.dart`
7. Descomenta y actualiza la línea:
   ```dart
   appStoreId: 'TU_APP_ID_AQUI',
   ```

## ⚠️ Notas Importantes

- **NO** enviar la app con `debugMode: true` hardcodeado
- **NO** dejar botones de test visibles en producción
- **SÍ** configurar el `appStoreId` antes de publicar
- El `UpdateChecker` en `app.dart` es el único que debe estar activo en producción
- Los botones de test son útiles durante desarrollo pero deben estar ocultos en release

## 📝 Cambios Realizados

### Archivos Modificados:
1. `lib/app/app.dart`
   - Cambiado `debugMode: true` a `debugMode: kDebugMode`
   - Agregado import de `package:flutter/foundation.dart`

2. `lib/ui/screens/setup_screen.dart`
   - Botón de test update envuelto en `if (kDebugMode)`
   - Agregado import de `package:flutter/foundation.dart`

3. `lib/ui/screens/settings_screen.dart`
   - Sección de testing envuelta en `if (kDebugMode)`
   - Removido `UpgradeAlert` hardcodeado (ya está en `app.dart`)
   - Agregado import de `package:flutter/foundation.dart`

### Archivos Creados:
- `docs/APPLE_REVIEW_CHECKLIST.md` (este archivo)

