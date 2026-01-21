# Sistema de Actualizaciones

## 📱 ¿Cómo funciona?

### **Sin Backend Propio** ✅

El sistema de actualizaciones **NO requiere backend propio**. Usa el paquete `upgrader` que:

1. **Consulta directamente las APIs públicas** de:
   - **App Store** (iOS) - API pública de iTunes
   - **Google Play Store** (Android) - API pública de Play Store

2. **Compara automáticamente**:
   - Versión instalada en el dispositivo (`pubspec.yaml`)
   - Versión disponible en el store

3. **Muestra un diálogo** cuando detecta una nueva versión disponible

## 🔧 Configuración Actual

### Ya implementado:
- ✅ Widget `UpdateChecker` que envuelve la app
- ✅ Verificación automática al iniciar la app
- ✅ Diálogo con opción de actualizar o posponer

### Pendiente cuando publiques:

#### **iOS (App Store)**
1. Obtener tu **App Store ID**:
   - Ve a [App Store Connect](https://appstoreconnect.apple.com)
   - Selecciona tu app
   - Ve a **App Information**
   - Copia el **Apple ID** (ej: `1234567890`)

2. Editar `lib/ui/widgets/update_checker.dart`:
   ```dart
   Upgrader(
     appStoreId: '1234567890', // ← Agregar tu App ID aquí
     durationUntilAlertAgain: const Duration(days: 3),
   ),
   ```

#### **Android (Google Play)**
- ✅ **No requiere configuración adicional**
- El package name se detecta automáticamente de `android/app/build.gradle`:
  ```gradle
  applicationId = "com.example.impostor_app"
  ```

## 📋 Flujo de Actualización

### Para el Usuario:
1. Abre la app
2. Si hay una nueva versión disponible, aparece un diálogo
3. Opciones:
   - **"Actualizar"** → Redirige al App Store/Play Store
   - **"Más tarde"** → Cierra el diálogo (se mostrará de nuevo en 3 días)

### Para el Desarrollador:
1. Incrementar versión en `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Versión + Build number
   ```
2. Compilar y publicar en los stores
3. Los usuarios recibirán el diálogo automáticamente

## 🎯 Ventajas de este Sistema

✅ **Sin servidor propio** - Consulta directamente los stores  
✅ **Gratis** - No requiere servicios adicionales  
✅ **Automático** - Funciona sin intervención manual  
✅ **Multiplataforma** - iOS y Android con el mismo código  
✅ **No intrusivo** - Solo muestra cuando hay actualización disponible  

## 🔄 Alternativas (si necesitas más control)

### Firebase Remote Config
Si necesitas:
- Forzar actualizaciones críticas
- Controlar qué usuarios deben actualizar
- Actualizar el comportamiento sin publicar nueva versión

**Cómo funciona:**
1. Crear parámetro `min_version_required` en Firebase
2. La app consulta este valor al iniciar
3. Compara con la versión instalada
4. Muestra diálogo bloqueante si es necesario

### Backend Propio
Solo si necesitas:
- Control total sobre la lógica de actualización
- Requisitos de seguridad específicos
- Integración con otros sistemas

## 📝 Notas Importantes

- El diálogo **no aparece** si la versión instalada es igual o mayor a la del store
- El diálogo se muestra **máximo cada 3 días** (configurable)
- Funciona **solo cuando la app está publicada** en los stores
- Durante desarrollo/testing, no aparecerá el diálogo

## 🐛 Troubleshooting

**El diálogo no aparece:**
- Verifica que la app esté publicada en el store
- Verifica que el `appStoreId` sea correcto (iOS)
- Verifica que el `applicationId` sea correcto (Android)
- Espera unos minutos después de publicar (las APIs pueden tardar)

**El diálogo aparece siempre:**
- Verifica que la versión en `pubspec.yaml` sea menor que la del store
- Incrementa el build number en `pubspec.yaml`

