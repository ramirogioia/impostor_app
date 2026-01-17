import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../../data/word_pack_repository.dart';
import '../../domain/models/word_pack.dart';
import '../widgets/logo_mark.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final packAsync = ref.watch(currentWordPackProvider);

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

                for (final c in categories) {
                  if (seen.add(c.id)) {
                    categoryOptions.add(
                      DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.displayName),
                      ),
                    );
                  }
                }
                final optionValues = categoryOptions.map((e) => e.value).whereType<String>().toList();
                final selectedCategory = optionValues.contains(settings.categoryId)
                    ? settings.categoryId
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
                              value: optionValues.contains(selectedCategory)
                                  ? selectedCategory
                                  : (optionValues.isNotEmpty ? optionValues.first : null),
                              decoration: InputDecoration(
                                labelText: strings.categoryFieldLabel,
                              ),
                              items: categoryOptions,
                              onChanged: packAsync.isLoading
                                  ? null
                                  : (value) {
                                      if (value != null) notifier.setCategory(value);
                                    },
                            ),
                        const SizedBox(height: 16),
                            _Section(
                              title: strings.difficulty,
                              child: SizedBox(
                                width: double.infinity,
                                child: SegmentedButton<Difficulty>(
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
