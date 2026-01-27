# Keystore para release Android

El keystore y las contraseñas se usan para firmar el APK/AAB de release (Play Store y instalación en dispositivos).

## Archivos (no subir a git)

- `android/app/impostor-upload.keystore` – Keystore
- `android/key.properties` – Referencia al keystore y contraseñas
- `android/keystore-passwords.txt` – Copia de las contraseñas (guardala en un lugar seguro y después podés borrarla de acá)

## Contraseñas

Las contraseñas están en `android/keystore-passwords.txt`. **Guardalas en un gestor de contraseñas o lugar seguro.** Las vas a necesitar para:

- Subir builds a Play Store
- Actualizar la app en el futuro

Si perdés el keystore o las contraseñas, no podrás actualizar la app en Play Store con la misma firma.

## Cómo generar un nuevo build de release

```bash
flutter build apk --release
# o para Play Store:
flutter build appbundle --release
```

El APK firmado queda en `build/app/outputs/flutter-apk/app-release.apk`.

## Instalar en un dispositivo físico

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```
