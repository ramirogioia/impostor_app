import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/strings.dart';

class UpdateDialogs {
  /// Muestra diálogo de actualización soft (opcional)
  static Future<void> showSoftUpdateDialog({
    required BuildContext context,
    required String storeUrl,
    required Strings strings,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(strings.updateAvailableTitle),
          content: Text(strings.updateAvailableMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.updateLater),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final uri = Uri.parse(storeUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(strings.updateButton),
            ),
          ],
        );
      },
    );
  }

  /// Muestra diálogo de actualización hard (forzada)
  static Future<void> showHardUpdateDialog({
    required BuildContext context,
    required String storeUrl,
    required Strings strings,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // No se puede cerrar
      builder: (dialogContext) {
        return PopScope(
          canPop: false, // Previene cerrar con back button
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(strings.updateRequiredTitle),
            content: Text(strings.updateRequiredMessage),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  final uri = Uri.parse(storeUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(strings.updateButton),
              ),
            ],
          ),
        );
      },
    );
  }
}

