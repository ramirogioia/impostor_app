import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../../data/word_pack_repository.dart';
import '../../domain/models/word_pack.dart';
import '../../domain/settings/impostor_suggestion.dart';
import '../../domain/validation/word_pack_validation.dart';
import '../widgets/category_item.dart';
import '../widgets/logo_mark.dart';
import '../widgets/responsive_helper.dart';

// GlobalKey para preservar el estado completo del dropdown de categoría y evitar repintados
final _categoryDropdownWidgetKey = GlobalKey();

// Provider para memoizar categoryOptions
final _categoryOptionsProvider = Provider.family<List<DropdownMenuItem<String>>,
    ({String locale, AsyncValue<WordPackLoadResult> packAsync})>((ref, params) {
  final categories = params.packAsync.when(
    data: (result) => result.pack.categories,
    loading: () =>
        params.packAsync.value?.pack.categories ?? const <WordCategory>[],
    error: (_, __) =>
        params.packAsync.value?.pack.categories ?? const <WordCategory>[],
  );

  final strings = Strings.fromLocale(params.locale);
  final hasRandomCategory =
      categories.any((c) => c.id == SettingsState.randomCategory);

  final categoryOptions = <DropdownMenuItem<String>>[];
  final seen = <String>{};

  if (!hasRandomCategory && seen.add(SettingsState.randomCategory)) {
    categoryOptions.add(
      DropdownMenuItem<String>(
        value: SettingsState.randomCategory,
        child: Row(
          children: [
            const Icon(Icons.shuffle, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              strings.randomCategory,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
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

  return categoryOptions;
});

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  String? _localCategoryId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(settingsNotifierProvider.future);
      if (!mounted) return;
      await ref
          .read(settingsNotifierProvider.notifier)
          .clearCachedPlayerNamesIfExpired();
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/select-locale'),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Tooltip(
                message: tooltipStrings.isEs ? 'Configuración' : 'Settings',
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.push('/settings'),
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                // Solo escuchar el estado de loading/error, no el valor completo
                final isLoading = ref.watch(
                  settingsNotifierProvider.select((state) => state.isLoading),
                );
                final hasError = ref.watch(
                  settingsNotifierProvider.select((state) => state.hasError),
                );
                final error = ref.watch(
                  settingsNotifierProvider
                      .select((state) => state.hasError ? state.error : null),
                );

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (hasError) {
                  return Center(child: Text('Failed to load settings: $error'));
                }

                // Obtener el valor inicial una sola vez
                final initialSettings =
                    ref.read(settingsNotifierProvider).valueOrNull ??
                        SettingsState.initial();
                return _SetupContent(
                  initialSettings: initialSettings,
                  packAsync: packAsync,
                  localCategoryId: _localCategoryId,
                  onCategoryChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _localCategoryId = value;
                      });
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setCategory(value);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupContent extends ConsumerStatefulWidget {
  const _SetupContent({
    required this.initialSettings,
    required this.packAsync,
    required this.localCategoryId,
    required this.onCategoryChanged,
  });

  final SettingsState initialSettings;
  final AsyncValue<WordPackLoadResult> packAsync;
  final String? localCategoryId;
  final void Function(String?) onCategoryChanged;

  @override
  ConsumerState<_SetupContent> createState() => _SetupContentState();
}

class _SetupContentState extends ConsumerState<_SetupContent> {
  // Memoizar categoryOptions para evitar recalcular en cada rebuild
  List<DropdownMenuItem<String>>? _cachedCategoryOptions;
  List<String>? _cachedOptionValues;
  String? _lastLocale;
  WordPack? _lastPack;
  // Estado local para el dropdown de categoría, similar a locale_selection_screen
  String? _localCategoryValue;
  // Memoizar InputDecoration para evitar recrearlo en cada rebuild
  InputDecoration? _cachedCategoryDecoration;
  String? _lastDecorationLocale;

  List<DropdownMenuItem<String>> _buildCategoryOptions(
      String locale, List<WordCategory> categories) {
    final strings = Strings.fromLocale(locale);

    final categoryOptions = <DropdownMenuItem<String>>[];
    final seen = <String>{};

    // Siempre agregar la opción "Aleatoria" personalizada con icono y color naranja
    // Esta es nuestra opción especial, no la que viene del JSON
    categoryOptions.add(
      DropdownMenuItem<String>(
        value: SettingsState.randomCategory,
        child: Row(
          key: ValueKey('random_category_row_$locale'),
          children: [
            const Icon(Icons.shuffle, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              strings.randomCategory,
              key: ValueKey('random_category_text_$locale'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
    seen.add(SettingsState.randomCategory);

    // Filtrar categorías que tengan ID "random" para evitar duplicados
    // y usar solo nuestra opción personalizada "Aleatoria"
    final filteredCategories =
        categories.where((c) => c.id != SettingsState.randomCategory).toList();

    // Sort categories alphabetically by displayName
    final sortedCategories = List<WordCategory>.from(filteredCategories)
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

    return categoryOptions;
  }

  @override
  void didUpdateWidget(_SetupContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincronizar _localCategoryValue cuando cambia widget.localCategoryId externamente
    if (oldWidget.localCategoryId != widget.localCategoryId &&
        widget.localCategoryId != null) {
      final optionValues = _cachedOptionValues;
      if (optionValues != null &&
          optionValues.contains(widget.localCategoryId)) {
        _localCategoryValue = widget.localCategoryId;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Solo escuchar locale para recalcular categoryOptions cuando cambie
    final locale = ref.watch(
      settingsNotifierProvider.select(
        (state) => state.valueOrNull?.locale ?? widget.initialSettings.locale,
      ),
    );

    final categories = widget.packAsync.when(
      data: (result) => result.pack.categories,
      loading: () =>
          widget.packAsync.value?.pack.categories ?? const <WordCategory>[],
      error: (_, __) =>
          widget.packAsync.value?.pack.categories ?? const <WordCategory>[],
    );

    // Recalcular categoryOptions solo si cambió el locale o el pack
    final currentPack = widget.packAsync.value?.pack;
    if (_cachedCategoryOptions == null ||
        _lastLocale != locale ||
        _lastPack != currentPack) {
      _lastLocale = locale;
      _lastPack = currentPack;
      _cachedCategoryOptions = _buildCategoryOptions(locale, categories);
      _cachedOptionValues = _cachedCategoryOptions!
          .map((e) => e.value)
          .whereType<String>()
          .toList();
      // Resetear _localCategoryValue cuando cambian las opciones para recalcular
      _localCategoryValue = null;
    }

    final strings = Strings.fromLocale(locale);
    final optionValues = _cachedOptionValues!;

    final notifier = ref.read(settingsNotifierProvider.notifier);
    // Inicializar el valor local del dropdown una sola vez
    if (_localCategoryValue == null) {
      final initialCategoryId =
          ref.read(settingsNotifierProvider).valueOrNull?.categoryId;
      final currentCategoryId = widget.localCategoryId ??
          initialCategoryId ??
          SettingsState.randomCategory;
      // Asegurar que si no hay categoría válida, use randomCategory como default
      _localCategoryValue = optionValues.contains(currentCategoryId)
          ? currentCategoryId
          : (optionValues.contains(SettingsState.randomCategory)
              ? SettingsState.randomCategory
              : (optionValues.isNotEmpty
                  ? optionValues.first
                  : SettingsState.randomCategory));
    }

    // Memoizar InputDecoration solo cuando cambia el locale
    if (_cachedCategoryDecoration == null || _lastDecorationLocale != locale) {
      _lastDecorationLocale = locale;
      _cachedCategoryDecoration = InputDecoration(
        labelText: strings.categoryFieldLabel,
      );
    }

    // Asegurar que siempre tengamos un decoration válido
    final categoryDecoration = _cachedCategoryDecoration!;
    final isTablet = ResponsiveHelper.isTablet(context);
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final verticalPadding = ResponsiveHelper.getVerticalPadding(context);

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
                  child: Theme.of(context).brightness == Brightness.light
                      ? Container(
                          color: Colors.white,
                          child: Image.asset(
                            'assets/images/icon_square_foreground.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => LogoMark(
                              size: isTablet ? 160 : 120,
                              isLight: true,
                            ),
                          ),
                        )
                      : Image.asset(
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: isTablet ? 32 : null,
                      ),
                ),
              ),
              SizedBox(height: isTablet ? 8 : 4),
              Center(
                child: Text(
                  strings.setupSub,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
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
                        settings: widget.initialSettings,
                        notifier: notifier,
                        categoryOptions: _cachedCategoryOptions!,
                        packAsync: widget.packAsync,
                        onCategoryChanged: widget.onCategoryChanged,
                      )
                    : ListView(
                        children: [
                          _PlayersStepper(
                            title: strings.players,
                            strings: strings,
                            notifier: notifier,
                          ),
                          const SizedBox(height: 12),
                          _ImpostorsStepper(
                            title: strings.impostors,
                            strings: strings,
                            notifier: notifier,
                          ),
                          const SizedBox(height: 18),
                          // Widget aislado para el dropdown de categoría para evitar parpadeos
                          // Usar un key que incluya el locale para forzar reconstrucción cuando cambia
                          _IsolatedCategoryDropdownMobile(
                            key: ValueKey('category_dropdown_mobile_$locale'),
                            value: _localCategoryValue,
                            decoration: categoryDecoration,
                            items: _cachedCategoryOptions!,
                            locale: locale,
                            isLoading: widget.packAsync.isLoading,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _localCategoryValue = value;
                                });
                                widget.onCategoryChanged(value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _DifficultySelector(
                            strings: strings,
                            notifier: notifier,
                          ),
                          if (widget.packAsync.isLoading &&
                              !widget.packAsync.hasValue)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: LinearProgressIndicator(),
                            ),
                          if (widget.packAsync.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${strings.loadingFailed} ($locale)',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Consumer(
                            builder: (context, ref, _) {
                              final preventImpostorFirst = ref.watch(
                                settingsNotifierProvider.select(
                                  (state) =>
                                      state.valueOrNull?.preventImpostorFirst ??
                                      widget
                                          .initialSettings.preventImpostorFirst,
                                ),
                              );
                              return CheckboxListTile(
                                title: Text(
                                  strings.preventImpostorFirst,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                value: preventImpostorFirst,
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                        .read(settingsNotifierProvider.notifier)
                                        .setPreventImpostorFirst(value);
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            },
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
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.child, this.isTablet = false});

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

// Widgets optimizados para tablet - definidos antes de _TabletLayout para evitar problemas
class _PlayersStepperTablet extends ConsumerWidget {
  const _PlayersStepperTablet({
    required this.title,
    required this.notifier,
  });

  final String title;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.players ?? SettingsState.initial().players,
      ),
    );
    return _Section(
      title: title,
      isTablet: true,
      child: _StepperRow(
        value: players,
        min: SettingsState.minPlayers,
        max: SettingsState.maxPlayers,
        onChanged: notifier.setPlayers,
        isTablet: true,
      ),
    );
  }
}

class _ImpostorsStepperTablet extends ConsumerWidget {
  const _ImpostorsStepperTablet({
    required this.title,
    required this.strings,
    required this.notifier,
  });

  final String title;
  final Strings strings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impostors = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.impostors ?? SettingsState.initial().impostors,
      ),
    );
    final players = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.players ?? SettingsState.initial().players,
      ),
    );
    final difficulty = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.difficulty ?? SettingsState.initial().difficulty,
      ),
    );
    final recommended = suggestImpostors(
      players: players,
      difficulty: difficulty,
    );
    final invalid = impostors >= players;

    return _Section(
      title: title,
      isTablet: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepperRow(
            value: impostors,
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
              onPressed: impostors == recommended
                  ? null
                  : notifier.useRecommendedImpostors,
              child: Text(
                strings.useRecommended,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (invalid)
            Text(
              strings.impostorInvalid,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryDropdownTablet extends ConsumerWidget {
  const _CategoryDropdownTablet({
    required this.categoryOptions,
    required this.strings,
    required this.packAsync,
    required this.onCategoryChanged,
  });

  final List<DropdownMenuItem<String>> categoryOptions;
  final Strings strings;
  final AsyncValue<WordPackLoadResult> packAsync;
  final void Function(String?) onCategoryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No escuchar el provider - usar estado local como en locale_selection_screen
    // Solo leer el valor inicial una vez
    final optionValues =
        categoryOptions.map((e) => e.value).whereType<String>().toList();

    // Leer el valor actual sin watch para evitar reconstrucciones
    final categoryId =
        ref.read(settingsNotifierProvider).valueOrNull?.categoryId;
    final selectedCategory = optionValues.contains(categoryId)
        ? categoryId
        : (optionValues.isNotEmpty ? optionValues.first : null);

    return RepaintBoundary(
      child: _CategoryDropdownTabletInternal(
        key: const ValueKey('category_dropdown_tablet'),
        selectedCategory: selectedCategory,
        categoryOptions: categoryOptions,
        strings: strings,
        packAsync: packAsync,
        onCategoryChanged: onCategoryChanged,
      ),
    );
  }
}

class _CategoryDropdownTabletInternal extends StatefulWidget {
  const _CategoryDropdownTabletInternal({
    super.key,
    required this.selectedCategory,
    required this.categoryOptions,
    required this.strings,
    required this.packAsync,
    required this.onCategoryChanged,
  });

  final String? selectedCategory;
  final List<DropdownMenuItem<String>> categoryOptions;
  final Strings strings;
  final AsyncValue<WordPackLoadResult> packAsync;
  final void Function(String?) onCategoryChanged;

  @override
  State<_CategoryDropdownTabletInternal> createState() =>
      _CategoryDropdownTabletInternalState();
}

class _CategoryDropdownTabletInternalState
    extends State<_CategoryDropdownTabletInternal> {
  late String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  void didUpdateWidget(_CategoryDropdownTabletInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizar si cambió el valor seleccionado
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _selectedCategory = widget.selectedCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: widget.strings.categoryFieldLabel,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
      menuMaxHeight: 300,
      alignment: AlignmentDirectional.bottomStart,
      items: widget.categoryOptions,
      onChanged: widget.packAsync.isLoading
          ? null
          : (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
                widget.onCategoryChanged(value);
              }
            },
      style: const TextStyle(fontSize: 18),
    );
  }
}

class _DifficultySelectorTablet extends ConsumerWidget {
  const _DifficultySelectorTablet({
    required this.strings,
    required this.notifier,
  });

  final Strings strings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficulty = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.difficulty ?? SettingsState.initial().difficulty,
      ),
    );
    return _Section(
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
          selected: {difficulty},
          onSelectionChanged: (selection) =>
              notifier.setDifficulty(selection.first),
        ),
      ),
    );
  }
}

class _TabletLayout extends ConsumerWidget {
  const _TabletLayout({
    required this.context,
    required this.strings,
    required this.settings,
    required this.notifier,
    required this.categoryOptions,
    required this.packAsync,
    required this.onCategoryChanged,
  });

  final BuildContext context;
  final Strings strings;
  final SettingsState settings;
  final SettingsNotifier notifier;
  final List<DropdownMenuItem<String>> categoryOptions;
  final AsyncValue<WordPackLoadResult> packAsync;
  final void Function(String?) onCategoryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: Players e Impostors
          Expanded(
            child: Column(
              children: [
                _PlayersStepperTablet(
                  title: strings.players,
                  notifier: notifier,
                ),
                const SizedBox(height: 24),
                _ImpostorsStepperTablet(
                  title: strings.impostors,
                  strings: strings,
                  notifier: notifier,
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Columna derecha: Category y Difficulty
          Expanded(
            child: Column(
              children: [
                RepaintBoundary(
                  child: _CategoryDropdownTablet(
                    categoryOptions: categoryOptions,
                    strings: strings,
                    packAsync: packAsync,
                    onCategoryChanged: onCategoryChanged,
                  ),
                ),
                const SizedBox(height: 24),
                _DifficultySelectorTablet(
                  strings: strings,
                  notifier: notifier,
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
                const SizedBox(height: 24),
                Consumer(
                  builder: (context, ref, _) {
                    // Solo escuchar el campo preventImpostorFirst para evitar reconstrucciones innecesarias
                    final preventImpostorFirst = ref.watch(
                      settingsNotifierProvider.select(
                        (state) =>
                            state.valueOrNull?.preventImpostorFirst ??
                            settings.preventImpostorFirst,
                      ),
                    );
                    return CheckboxListTile(
                      title: Text(
                        strings.preventImpostorFirst,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      value: preventImpostorFirst,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .setPreventImpostorFirst(value);
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget completamente aislado que no se reconstruye cuando el padre cambia
class _IsolatedCategoryDropdown extends StatefulWidget {
  const _IsolatedCategoryDropdown({
    super.key,
    required this.categoryOptions,
    required this.optionValues,
    required this.localCategoryId,
    required this.strings,
    required this.packAsync,
    required this.onCategoryChanged,
    required this.initialCategoryId,
  });

  final List<DropdownMenuItem<String>> categoryOptions;
  final List<String> optionValues;
  final String? localCategoryId;
  final Strings strings;
  final AsyncValue<WordPackLoadResult> packAsync;
  final void Function(String?) onCategoryChanged;
  final String? initialCategoryId;

  @override
  State<_IsolatedCategoryDropdown> createState() =>
      _IsolatedCategoryDropdownState();
}

class _IsolatedCategoryDropdownState extends State<_IsolatedCategoryDropdown> {
  late String? _selectedCategory;
  late final InputDecoration _decoration;
  late final String _labelText;

  @override
  void initState() {
    super.initState();
    // Inicializar con el valor inicial pasado como parámetro
    final currentCategoryId =
        widget.localCategoryId ?? widget.initialCategoryId;
    _selectedCategory = widget.optionValues.contains(currentCategoryId)
        ? currentCategoryId
        : (widget.optionValues.isNotEmpty ? widget.optionValues.first : null);
    // Guardar el labelText como string para evitar reconstrucciones
    _labelText = widget.strings.categoryFieldLabel;
    // Crear el InputDecoration una sola vez para evitar reconstrucciones
    _decoration = InputDecoration(
      labelText: _labelText,
    );
  }

  @override
  void didUpdateWidget(_IsolatedCategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizar si cambió localCategoryId, initialCategoryId o si las opciones cambiaron
    // NO actualizar si solo cambió strings u otros parámetros que no afectan el valor
    // Esto evita reconstrucciones innecesarias cuando otros componentes cambian
    if (oldWidget.localCategoryId != widget.localCategoryId ||
        oldWidget.initialCategoryId != widget.initialCategoryId ||
        oldWidget.optionValues != widget.optionValues) {
      final currentCategoryId =
          widget.localCategoryId ?? widget.initialCategoryId;
      final newSelected = widget.optionValues.contains(currentCategoryId)
          ? currentCategoryId
          : (widget.optionValues.isNotEmpty ? widget.optionValues.first : null);
      if (_selectedCategory != newSelected) {
        _selectedCategory = newSelected;
        // No llamar setState aquí para evitar repintados innecesarios
        // Solo actualizar el valor interno
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget completamente aislado - no escucha providers, solo usa estado local
    // El problema es que DropdownButtonFormField puede repintarse cuando el contexto cambia
    // Usar un enfoque diferente: crear el dropdown con todos los valores constantes
    // y evitar que se reconstruya cuando otros widgets cambian
    // Usar una key estable basada solo en el valor seleccionado, no en otros parámetros
    return RepaintBoundary(
      child: DropdownButtonFormField<String>(
        key: ValueKey('category_dropdown_${_selectedCategory}'),
        value: _selectedCategory,
        decoration: _decoration,
        dropdownColor: Theme.of(context).colorScheme.surface,
        menuMaxHeight: 300,
        alignment: AlignmentDirectional.bottomStart,
        items: widget.categoryOptions,
        onChanged: widget.packAsync.isLoading
            ? null
            : (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                  widget.onCategoryChanged(newValue);
                }
              },
      ),
    );
  }
}

// Mantener _CategoryDropdown para compatibilidad con tablet
class _CategoryDropdown extends StatefulWidget {
  const _CategoryDropdown({
    super.key,
    required this.categoryOptions,
    required this.optionValues,
    required this.localCategoryId,
    required this.strings,
    required this.packAsync,
    required this.onCategoryChanged,
    required this.initialCategoryId,
  });

  final List<DropdownMenuItem<String>> categoryOptions;
  final List<String> optionValues;
  final String? localCategoryId;
  final Strings strings;
  final AsyncValue<WordPackLoadResult> packAsync;
  final void Function(String?) onCategoryChanged;
  final String? initialCategoryId;

  @override
  State<_CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<_CategoryDropdown> {
  late String? _selectedCategory;
  late final InputDecoration _decoration;

  @override
  void initState() {
    super.initState();
    // Inicializar con el valor inicial pasado como parámetro
    final currentCategoryId =
        widget.localCategoryId ?? widget.initialCategoryId;
    _selectedCategory = widget.optionValues.contains(currentCategoryId)
        ? currentCategoryId
        : (widget.optionValues.isNotEmpty ? widget.optionValues.first : null);
    // Crear el InputDecoration una sola vez para evitar reconstrucciones
    _decoration = InputDecoration(
      labelText: widget.strings.categoryFieldLabel,
    );
  }

  @override
  void didUpdateWidget(_CategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizar si cambió localCategoryId, initialCategoryId o si las opciones cambiaron
    if (oldWidget.localCategoryId != widget.localCategoryId ||
        oldWidget.initialCategoryId != widget.initialCategoryId ||
        oldWidget.optionValues != widget.optionValues) {
      final currentCategoryId =
          widget.localCategoryId ?? widget.initialCategoryId;
      final newSelected = widget.optionValues.contains(currentCategoryId)
          ? currentCategoryId
          : (widget.optionValues.isNotEmpty ? widget.optionValues.first : null);
      if (_selectedCategory != newSelected) {
        _selectedCategory = newSelected;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget completamente aislado - no escucha providers, solo usa estado local
    // Usar múltiples capas de RepaintBoundary para evitar repintados
    return RepaintBoundary(
      child: RepaintBoundary(
        child: DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: _decoration,
          dropdownColor: Theme.of(context).colorScheme.surface,
          menuMaxHeight: 300,
          alignment: AlignmentDirectional.bottomStart,
          items: widget.categoryOptions,
          onChanged: widget.packAsync.isLoading
              ? null
              : (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                    widget.onCategoryChanged(newValue);
                  }
                },
        ),
      ),
    );
  }
}

class _PlayersStepper extends ConsumerWidget {
  const _PlayersStepper({
    required this.title,
    required this.strings,
    required this.notifier,
  });

  final String title;
  final Strings strings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.players ?? SettingsState.initial().players,
      ),
    );
    return _Section(
      title: title,
      isTablet: false,
      child: _StepperRow(
        value: players,
        min: SettingsState.minPlayers,
        max: SettingsState.maxPlayers,
        onChanged: notifier.setPlayers,
        isTablet: false,
      ),
    );
  }
}

class _ImpostorsStepper extends ConsumerWidget {
  const _ImpostorsStepper({
    required this.title,
    required this.strings,
    required this.notifier,
  });

  final String title;
  final Strings strings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impostors = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.impostors ?? SettingsState.initial().impostors,
      ),
    );
    final players = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.players ?? SettingsState.initial().players,
      ),
    );
    final difficulty = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.difficulty ?? SettingsState.initial().difficulty,
      ),
    );
    final recommended = suggestImpostors(
      players: players,
      difficulty: difficulty,
    );
    final invalid = impostors >= players;

    return _Section(
      title: title,
      isTablet: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepperRow(
            value: impostors,
            min: SettingsState.minImpostors,
            max: SettingsState.maxImpostors,
            onChanged: notifier.setImpostors,
            isTablet: false,
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
              onPressed: impostors == recommended
                  ? null
                  : notifier.useRecommendedImpostors,
              child: Text(strings.useRecommended),
            ),
          ),
          const SizedBox(height: 4),
          if (invalid)
            Text(
              strings.impostorInvalid,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }
}

class _DifficultySelector extends ConsumerWidget {
  const _DifficultySelector({
    required this.strings,
    required this.notifier,
  });

  final Strings strings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficulty = ref.watch(
      settingsNotifierProvider.select(
        (state) =>
            state.valueOrNull?.difficulty ?? SettingsState.initial().difficulty,
      ),
    );
    return _Section(
      title: strings.difficulty,
      isTablet: false,
      child: RepaintBoundary(
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
            selected: {difficulty},
            onSelectionChanged: (selection) =>
                notifier.setDifficulty(selection.first),
          ),
        ),
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
    final canDecrease = value > min;
    final canIncrease = value < max;
    final iconColor = Theme.of(context).colorScheme.onSurface;
    final splashColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.1);
    final highlightColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.05);

    return RepaintBoundary(
      child: Row(
        children: [
          RepaintBoundary(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canDecrease ? () => onChanged(value - 1) : null,
                borderRadius: BorderRadius.circular((isTablet ? 32 : 24) / 2),
                splashColor: splashColor,
                highlightColor: highlightColor,
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 8),
                  child: AnimatedOpacity(
                    opacity: canDecrease ? 1.0 : 0.38,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.remove,
                      size: isTablet ? 32 : 24,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
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
          RepaintBoundary(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canIncrease ? () => onChanged(value + 1) : null,
                borderRadius: BorderRadius.circular((isTablet ? 32 : 24) / 2),
                splashColor: splashColor,
                highlightColor: highlightColor,
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 8),
                  child: AnimatedOpacity(
                    opacity: canIncrease ? 1.0 : 0.38,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.add,
                      size: isTablet ? 32 : 24,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget aislado para el dropdown de categoría en mobile para evitar parpadeos
class _IsolatedCategoryDropdownMobile extends StatefulWidget {
  const _IsolatedCategoryDropdownMobile({
    super.key,
    required this.value,
    required this.decoration,
    required this.items,
    required this.isLoading,
    required this.onChanged,
    required this.locale,
  });

  final String? value;
  final InputDecoration decoration;
  final List<DropdownMenuItem<String>> items;
  final bool isLoading;
  final void Function(String?) onChanged;
  final String locale;

  @override
  State<_IsolatedCategoryDropdownMobile> createState() =>
      _IsolatedCategoryDropdownMobileState();
}

class _IsolatedCategoryDropdownMobileState
    extends State<_IsolatedCategoryDropdownMobile> {
  String? _localValue;
  InputDecoration? _cachedDecoration;
  // No cachear items - usar siempre widget.items directamente para asegurar
  // que siempre se usen los items más recientes con el locale correcto
  List<Widget>? _cachedSelectedItems;
  // GlobalKeys para mantener la identidad de los widgets entre rebuilds
  final _repaintBoundaryKey = GlobalKey();
  final _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
    _cachedDecoration = widget.decoration;
    // No cachear items en initState - usar siempre widget.items directamente
    // Esto asegura que siempre se usen los items más recientes con el locale correcto
    _buildSelectedItems();
  }

  @override
  void didUpdateWidget(_IsolatedCategoryDropdownMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool needsRebuild = false;

    // Solo actualizar si realmente cambió el valor
    if (oldWidget.value != widget.value) {
      _localValue = widget.value;
    }
    // Solo actualizar decoration si cambió
    if (oldWidget.decoration != widget.decoration) {
      _cachedDecoration = widget.decoration;
    }
    // Siempre reconstruir si cambian los items o el locale
    // No cachear items para asegurar que siempre se usen los más recientes
    if (oldWidget.items != widget.items || oldWidget.locale != widget.locale) {
      needsRebuild = true;
    }

    // Solo reconstruir selected items si es necesario
    if (needsRebuild) {
      _buildSelectedItems();
    }
  }

  void _buildSelectedItems() {
    // Construir widgets para selectedItemBuilder
    // Para "Aleatoria", mostrar el Row completo con icono y color naranja
    // Para otras opciones, mostrar solo el texto
    final strings = Strings.fromLocale(widget.locale);
    // Usar siempre widget.items directamente para asegurar que se usen los items más recientes
    final items = widget.items;
    _cachedSelectedItems = items.map((item) {
      if (item.value == SettingsState.randomCategory) {
        // Para "Aleatoria", mostrar el Row completo con icono y color naranja
        return Row(
          key: ValueKey('selected_random_${widget.locale}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shuffle, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              strings.randomCategory,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        );
      } else if (item.child is CategoryItem) {
        // Para categorías normales, mostrar solo el texto
        final categoryItem = item.child as CategoryItem;
        return Text(
          categoryItem.displayName,
          key: ValueKey('selected_${item.value}'),
        );
      } else if (item.child is Text) {
        // Si el child es un Text simple, usarlo directamente
        final textWidget = item.child as Text;
        return Text(
          textWidget.data ?? item.value ?? '',
          key: ValueKey('selected_${item.value}'),
        );
      } else if (item.child is Row) {
        // Si el child es un Row, extraer solo el texto (para otros casos especiales)
        final row = item.child as Row;
        String displayText = item.value ?? '';
        for (final child in row.children) {
          if (child is Text) {
            final textData = (child as Text).data;
            if (textData != null && textData.isNotEmpty) {
              displayText = textData;
              break;
            }
          }
        }
        return Text(displayText, key: ValueKey('selected_${item.value}'));
      }
      // Fallback: mostrar el value como texto
      return Text(item.value ?? '', key: ValueKey('selected_${item.value}'));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Asegurar que tenemos selected items cached
    if (_cachedSelectedItems == null) {
      _buildSelectedItems();
    }

    // Usar GlobalKey para mantener la identidad del RepaintBoundary y del dropdown
    // Esto previene que Flutter recree estos widgets cuando el padre se reconstruye
    // Envolver en un Builder para aislar el contexto
    return Builder(
      builder: (context) => RepaintBoundary(
        key: _repaintBoundaryKey,
        child: DropdownButtonFormField<String>(
          key: _dropdownKey,
          value: _localValue,
          decoration: _cachedDecoration ?? widget.decoration,
          dropdownColor: Theme.of(context).colorScheme.surface,
          menuMaxHeight: 300,
          alignment: AlignmentDirectional.bottomStart,
          // Siempre usar los items del widget directamente, no los cacheados
          // Esto asegura que cuando cambia el locale, los items se actualicen correctamente
          items: widget.items,
          selectedItemBuilder: (context) {
            // Siempre usar los items cacheados - nunca recrear en build
            // Esto previene repaints cuando otros widgets cambian
            return _cachedSelectedItems ?? [];
          },
          onChanged: widget.isLoading
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      _localValue = value;
                    });
                    widget.onChanged(value);
                  }
                },
        ),
      ),
    );
  }
}
