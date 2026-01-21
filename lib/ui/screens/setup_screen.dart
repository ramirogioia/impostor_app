import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:upgrader/upgrader.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../../data/word_pack_repository.dart';
import '../../domain/models/word_pack.dart';
import '../widgets/category_item.dart';
import '../widgets/logo_mark.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  String? _localCategoryId;
  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    _upgrader = Upgrader(
      debugDisplayAlways: true,
      debugLogging: true,
      minAppVersion: '999.0.0',
      durationUntilAlertAgain: const Duration(seconds: 0),
    );
    // Inicializar el upgrader después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _upgrader.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final packAsync = ref.watch(currentWordPackProvider);
    final tooltipStrings = settingsAsync.valueOrNull == null
        ? Strings.fromLocale('es-AR')
        : Strings.fromLocale(settingsAsync.value!.locale);
    
    // Sync local state with settings when settings change
    settingsAsync.whenData((settings) {
      if (_localCategoryId != settings.categoryId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _localCategoryId = settings.categoryId;
            });
          }
        });
      }
    });

    return UpgradeAlert(
      upgrader: _upgrader,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/select-locale'),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: tooltipStrings.isEs ? 'Probar actualización' : 'Test update',
                      child: IconButton(
                        icon: const Icon(Icons.system_update, color: Colors.white70, size: 20),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (dialogContext) {
                              final strings = Strings.fromLocale(
                                settingsAsync.valueOrNull?.locale ?? 'es-AR',
                              );
                              return AlertDialog(
                                title: Text(strings.updateAvailable),
                                content: Text(strings.updateMessage),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: Text(strings.updateLater),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      // En producción, esto abriría la tienda
                                    },
                                    child: Text(strings.updateButton),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Tooltip(
                      message: tooltipStrings.isEs ? 'Reglas de juego' : 'Game rules',
                      child: IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white),
                        onPressed: () => context.go('/rules'),
                      ),
                    ),
                  ],
                ),
              ),
            settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load settings: $e')),
              data: (settings) {
                final strings = Strings.fromLocale(settings.locale);
                final notifier = ref.read(settingsNotifierProvider.notifier);
                final categories = packAsync.when(
                  data: (result) => result.pack.categories,
                  loading: () => packAsync.value?.pack.categories ?? const <WordCategory>[],
                  error: (_, __) => packAsync.value?.pack.categories ?? const <WordCategory>[],
                );
                final hasRandomCategory =
                    categories.any((c) => c.id == SettingsState.randomCategory);
                final recommended = suggestImpostors(
                  players: settings.players,
                  difficulty: settings.difficulty,
                );
                final invalidImpostors = settings.impostors >= settings.players;

                final categoryOptions = <DropdownMenuItem<String>>[];
                final seen = <String>{};

                if (!hasRandomCategory && seen.add(SettingsState.randomCategory)) {
                  categoryOptions.add(
                    DropdownMenuItem<String>(
                      value: SettingsState.randomCategory,
                      child: Text(strings.randomCategory),
                    ),
                  );
                }

                // Sort categories alphabetically by displayName
                final sortedCategories = List<WordCategory>.from(categories)
                  ..sort((a, b) => a.displayName.compareTo(b.displayName));

                for (final c in sortedCategories) {
                  if (seen.add(c.id)) {
                    categoryOptions.add(
                      DropdownMenuItem<String>(
                        value: c.id,
                        child: CategoryItem(
                          displayName: c.displayName,
                          categoryId: c.id,
                        ),
                      ),
                    );
                  }
                }
                final optionValues = categoryOptions.map((e) => e.value).whereType<String>().toList();
                // Use local state if available, otherwise use settings
                final currentCategoryId = _localCategoryId ?? settings.categoryId;
                final selectedCategory = optionValues.contains(currentCategoryId)
                    ? currentCategoryId
                    : (optionValues.isNotEmpty ? optionValues.first : null);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          height: 120,
                          child: Image.asset(
                            'assets/images/icon_square.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const LogoMark(size: 120),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          strings.setupTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          strings.setupSub,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView(
                          children: [
                            _Section(
                              title: strings.players,
                              child: _StepperRow(
                                value: settings.players,
                                min: SettingsState.minPlayers,
                                max: SettingsState.maxPlayers,
                                onChanged: notifier.setPlayers,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Section(
                              title: strings.impostors,
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
                                  Text(
                                    '${strings.recommended}: $recommended',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 36,
                                    child: OutlinedButton(
                                      onPressed: settings.impostors == recommended
                                          ? null
                                          : notifier.useRecommendedImpostors,
                                      child: Text(strings.useRecommended),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (invalidImpostors)
                                    Text(
                                      strings.impostorInvalid,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                labelText: strings.categoryFieldLabel,
                              ),
                              items: categoryOptions,
                              onChanged: packAsync.isLoading
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        // Update local state immediately to prevent flicker
                                        setState(() {
                                          _localCategoryId = value;
                                        });
                                        // Then update persistent state
                                        notifier.setCategory(value);
                                      }
                                    },
                            ),
                        const SizedBox(height: 16),
                            _Section(
                              title: strings.difficulty,
                              child: SizedBox(
                                width: double.infinity,
                                child: SegmentedButton<Difficulty>(
                                  showSelectedIcon: false,
                                  segments: [
                                    ButtonSegment(
                                      value: Difficulty.easy,
                                      label: Text(strings.easy),
                                    ),
                                    ButtonSegment(
                                      value: Difficulty.medium,
                                      label: Text(strings.medium),
                                    ),
                                    ButtonSegment(
                                      value: Difficulty.hard,
                                      label: Text(strings.hard),
                                    ),
                                  ],
                                  selected: {settings.difficulty},
                                  onSelectionChanged: (selection) =>
                                      notifier.setDifficulty(selection.first),
                                ),
                              ),
                            ),
                            if (packAsync.isLoading && !packAsync.hasValue)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: LinearProgressIndicator(),
                              ),
                            if (packAsync.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${strings.loadingFailed} (${settings.locale})',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                      onPressed: () => context.go('/players'),
                          child: Text(strings.start),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
