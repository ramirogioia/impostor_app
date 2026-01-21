import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../../data/word_pack_repository.dart';
import '../../domain/models/word_pack.dart';
import '../../domain/validation/word_pack_validation.dart';
import '../widgets/category_item.dart';
import '../widgets/logo_mark.dart';
import '../widgets/responsive_helper.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  String? _localCategoryId;

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

    return Scaffold(
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
                  // Botón de test update solo visible en modo debug
                  if (kDebugMode)
                    Tooltip(
                      message: tooltipStrings.isEs
                          ? 'Probar actualización'
                          : 'Test update',
                      child: IconButton(
                        icon: const Icon(Icons.system_update,
                            color: Colors.white70, size: 20),
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
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
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
                    message:
                        tooltipStrings.isEs ? 'Reglas de juego' : 'Game rules',
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
              error: (e, _) =>
                  Center(child: Text('Failed to load settings: $e')),
              data: (settings) {
                final strings = Strings.fromLocale(settings.locale);
                final notifier = ref.read(settingsNotifierProvider.notifier);
                final categories = packAsync.when(
                  data: (result) => result.pack.categories,
                  loading: () =>
                      packAsync.value?.pack.categories ??
                      const <WordCategory>[],
                  error: (_, __) =>
                      packAsync.value?.pack.categories ??
                      const <WordCategory>[],
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

                if (!hasRandomCategory &&
                    seen.add(SettingsState.randomCategory)) {
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
                final optionValues = categoryOptions
                    .map((e) => e.value)
                    .whereType<String>()
                    .toList();
                // Use local state if available, otherwise use settings
                final currentCategoryId =
                    _localCategoryId ?? settings.categoryId;
                final selectedCategory =
                    optionValues.contains(currentCategoryId)
                        ? currentCategoryId
                        : (optionValues.isNotEmpty ? optionValues.first : null);

                final isTablet = ResponsiveHelper.isTablet(context);
                final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
                final horizontalPadding =
                    ResponsiveHelper.getHorizontalPadding(context);
                final verticalPadding =
                    ResponsiveHelper.getVerticalPadding(context);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: isTablet ? 16 : 8),
                          Center(
                            child: SizedBox(
                              height: isTablet ? 160 : 120,
                              child: Image.asset(
                                'assets/images/icon_square.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => LogoMark(
                                  size: isTablet ? 160 : 120,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 16 : 8),
                          Center(
                            child: Text(
                              strings.setupTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: isTablet ? 32 : null,
                                  ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 8 : 4),
                          Center(
                            child: Text(
                              strings.setupSub,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white70,
                                    fontSize: isTablet ? 18 : null,
                                  ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 32 : 18),
                          Expanded(
                            child: isTablet
                                ? _TabletLayout(
                                    context: context,
                                    strings: strings,
                                    settings: settings,
                                    notifier: notifier,
                                    recommended: recommended,
                                    invalidImpostors: invalidImpostors,
                                    selectedCategory: selectedCategory,
                                    categoryOptions: categoryOptions,
                                    packAsync: packAsync,
                                    onCategoryChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _localCategoryId = value;
                                        });
                                        notifier.setCategory(value);
                                      }
                                    },
                                  )
                                : ListView(
                                    children: [
                                _Section(
                                  title: strings.players,
                                  isTablet: false,
                                  child: _StepperRow(
                                    value: settings.players,
                                    min: SettingsState.minPlayers,
                                    max: SettingsState.maxPlayers,
                                    onChanged: notifier.setPlayers,
                                    isTablet: false,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _Section(
                                  title: strings.impostors,
                                  isTablet: false,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _StepperRow(
                                        value: settings.impostors,
                                        min: SettingsState.minImpostors,
                                        max: SettingsState.maxImpostors,
                                        onChanged: notifier.setImpostors,
                                        isTablet: false,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${strings.recommended}: $recommended',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: 36,
                                        child: OutlinedButton(
                                          onPressed:
                                              settings.impostors == recommended
                                                  ? null
                                                  : notifier
                                                      .useRecommendedImpostors,
                                          child: Text(strings.useRecommended),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (invalidImpostors)
                                        Text(
                                          strings.impostorInvalid,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
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
                                  isTablet: false,
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
                                          notifier
                                              .setDifficulty(selection.first),
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
                                        color:
                                            Theme.of(context).colorScheme.error,
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
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 24 : 16,
                                ),
                                minimumSize: Size(0, isTablet ? 56 : 48),
                              ),
                              child: Text(
                                strings.start,
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : null,
                                  fontWeight: isTablet ? FontWeight.w600 : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.isTablet = false});

  final String title;
  final Widget child;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 22 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        child,
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.context,
    required this.strings,
    required this.settings,
    required this.notifier,
    required this.recommended,
    required this.invalidImpostors,
    required this.selectedCategory,
    required this.categoryOptions,
    required this.packAsync,
    required this.onCategoryChanged,
  });

  final BuildContext context;
  final Strings strings;
  final SettingsState settings;
  final SettingsNotifier notifier;
  final int recommended;
  final bool invalidImpostors;
  final String? selectedCategory;
  final List<DropdownMenuItem<String>> categoryOptions;
  final AsyncValue<WordPackLoadResult> packAsync;
  final void Function(String?) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: Players e Impostors
          Expanded(
            child: Column(
              children: [
                _Section(
                  title: strings.players,
                  isTablet: true,
                  child: _StepperRow(
                    value: settings.players,
                    min: SettingsState.minPlayers,
                    max: SettingsState.maxPlayers,
                    onChanged: notifier.setPlayers,
                    isTablet: true,
                  ),
                ),
                const SizedBox(height: 24),
                _Section(
                  title: strings.impostors,
                  isTablet: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepperRow(
                        value: settings.impostors,
                        min: SettingsState.minImpostors,
                        max: SettingsState.maxImpostors,
                        onChanged: notifier.setImpostors,
                        isTablet: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${strings.recommended}: $recommended',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: settings.impostors == recommended
                              ? null
                              : notifier.useRecommendedImpostors,
                          child: Text(
                            strings.useRecommended,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (invalidImpostors)
                        Text(
                          strings.impostorInvalid,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Columna derecha: Category y Difficulty
          Expanded(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: strings.categoryFieldLabel,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                  items: categoryOptions,
                  onChanged: packAsync.isLoading ? null : onCategoryChanged,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                _Section(
                  title: strings.difficulty,
                  isTablet: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<Difficulty>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: Difficulty.easy,
                          label: Text(
                            strings.easy,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ButtonSegment(
                          value: Difficulty.medium,
                          label: Text(
                            strings.medium,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ButtonSegment(
                          value: Difficulty.hard,
                          label: Text(
                            strings.hard,
                            style: const TextStyle(fontSize: 16),
                          ),
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
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
                if (packAsync.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '${strings.loadingFailed} (${settings.locale})',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.isTablet = false,
  });

  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: Icon(Icons.remove, size: isTablet ? 32 : 24),
          iconSize: isTablet ? 32 : 24,
          padding: EdgeInsets.all(isTablet ? 16 : 8),
        ),
        Expanded(
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: isTablet ? 32 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: Icon(Icons.add, size: isTablet ? 32 : 24),
          iconSize: isTablet ? 32 : 24,
          padding: EdgeInsets.all(isTablet ? 16 : 8),
        ),
      ],
    );
  }
}
