import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/version_checker_service.dart';
import '../ui/widgets/update_dialogs.dart';
import 'strings.dart';

class VersionCheckerNotifier extends StateNotifier<AsyncValue<void>> {
  VersionCheckerNotifier() : super(const AsyncValue.data(null));
  static bool _softShownThisSession = false;

  /// Verifica actualizaciones y muestra el diálogo correspondiente
  Future<void> checkForUpdates({
    required BuildContext context,
    required Strings strings,
    bool showNoUpdateMessage = false,
    bool skipIfSoftShown = false,
  }) async {
    if (skipIfSoftShown && _softShownThisSession) {
      return;
    }
    state = const AsyncValue.loading();
    try {
      final updateType = await VersionCheckerService.checkForUpdate();
      if (updateType != null) {
        final storeUrl = await VersionCheckerService.getStoreUrl();
        if (updateType == 'hard') {
          await UpdateDialogs.showHardUpdateDialog(
            context: context,
            storeUrl: storeUrl,
            strings: strings,
          );
        } else if (updateType == 'soft') {
          await UpdateDialogs.showSoftUpdateDialog(
            context: context,
            storeUrl: storeUrl,
            strings: strings,
          );
          _softShownThisSession = true;
        }
        state = const AsyncValue.data(null);
      } else {
        state = const AsyncValue.data(null);
        if (showNoUpdateMessage && context.mounted) {
          // Mostrar mensaje de que no hay actualizaciones
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.checkUpdatesNoUpdates),
            ),
          );
        }
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final versionCheckerNotifierProvider =
    StateNotifierProvider<VersionCheckerNotifier, AsyncValue<void>>((ref) {
  return VersionCheckerNotifier();
});

