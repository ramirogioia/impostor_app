import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:upgrader/upgrader.dart';

import '../../app/settings.dart';
import '../../data/word_pack_repository.dart';
import '../../domain/models/word_pack.dart';
import '../widgets/category_item.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const locales = ['es-AR', 'es-ES', 'es-MX', 'en-US', 'en-GB'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final packAsync = ref.watch(currentWordPackProvider);

    return UpgradeAlert(
      upgrader: Upgrader(
        debugDisplayAlways: true,
        debugLogging: true,
        minAppVersion: '999.0.0',
        durationUntilAlertAgain: const Duration(seconds: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load settings: $e')),
        data: (settings) {
          final List<WordCategory> categories = packAsync.maybeWhen(
            data: (result) => result.pack.categories,
            orElse: () => const <WordCategory>[],
          );
          final recommended = suggestImpostors(
            players: settings.players,
            difficulty: settings.difficulty,
          );
          final invalidImpostors = settings.impostors >= settings.players;
          // Sort categories alphabetically by displayName
          final sortedCategories = List<WordCategory>.from(categories)
            ..sort((a, b) => a.displayName.compareTo(b.displayName));

          final List<DropdownMenuItem<String>> categoryOptions = [
            const DropdownMenuItem<String>(
              value: SettingsState.randomCategory,
              child: Text('Random'),
            ),
            ...sortedCategories.map(
              (c) => DropdownMenuItem<String>(
                value: c.id,
                child: CategoryItem(
                  displayName: c.displayName,
                  categoryId: c.id,
                ),
              ),
            ),
          ];

          final notifier = ref.read(settingsNotifierProvider.notifier);

          // Auto-fix category if locale changed and current category missing.
          final hasCategory = categories.any((c) => c.id == settings.categoryId);
          if (!hasCategory && settings.categoryId != SettingsState.randomCategory) {
            notifier.setCategory(SettingsState.randomCategory);
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _Section(
                  title: 'Locale',
                  child: DropdownButtonFormField<String>(
                    value: settings.locale,
                    items: locales
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text(l),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) notifier.setLocale(value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _Section(
                  title: 'Difficulty',
                  child: SegmentedButton<Difficulty>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: Difficulty.easy,
                        label: Text('Easy'),
                      ),
                      ButtonSegment(
                        value: Difficulty.medium,
                        label: Text('Medium'),
                      ),
                      ButtonSegment(
                        value: Difficulty.hard,
                        label: Text('Hard'),
                      ),
                    ],
                    selected: {settings.difficulty},
                    onSelectionChanged: (selection) =>
                        notifier.setDifficulty(selection.first),
                  ),
                ),
                const SizedBox(height: 12),
                _Section(
                  title: 'Players',
                  child: _StepperRow(
                    value: settings.players,
                    min: SettingsState.minPlayers,
                    max: SettingsState.maxPlayers,
                    onChanged: notifier.setPlayers,
                  ),
                ),
                const SizedBox(height: 12),
                _Section(
                  title: 'Impostors',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepperRow(
                        value: settings.impostors,
                        min: SettingsState.minImpostors,
                        max: SettingsState.maxImpostors,
                        onChanged: notifier.setImpostors,
                      ),
                      const SizedBox(height: 8),
                      Text('Recommended: $recommended'),
                      const SizedBox(height: 4),
                      OutlinedButton(
                        onPressed: settings.impostors == recommended
                            ? null
                            : notifier.useRecommendedImpostors,
                        child: const Text('Use recommended'),
                      ),
                      const SizedBox(height: 4),
                      if (invalidImpostors)
                        Text(
                          'Impostors must be less than players.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Section(
                  title: 'Auto impostors',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.autoImpostors,
                    onChanged: notifier.setAutoImpostors,
                    title: const Text('Auto adjust based on players & difficulty'),
                  ),
                ),
                const SizedBox(height: 12),
                _Section(
                  title: 'Category',
                  child: DropdownButtonFormField<String>(
                    value: hasCategory ? settings.categoryId : SettingsState.randomCategory,
                    items: categoryOptions,
                    onChanged: (value) {
                      if (value != null) notifier.setCategory(value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (packAsync.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  )
                else if (packAsync.hasError)
                  Text(
                    'Failed to load word pack for ${settings.locale}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                // Testing section - siempre visible para probar el diálogo de actualización
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                _Section(
                  title: 'Testing',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Mostrar un diálogo de prueba que simula el diálogo de actualización
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Actualización disponible'),
                                content: const Text(
                                  'Hay una nueva versión disponible en la tienda.\n\n'
                                  '¿Deseas actualizar ahora?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text('Más tarde'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      // En producción, esto abriría la tienda
                                      // upgrader.launchAppStore();
                                    },
                                    child: const Text('Actualizar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.system_update),
                        label: const Text('Test Update Dialog'),
                      ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button above to test the update dialog.\n\nIn production, the dialog will appear automatically when a new version is available.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

