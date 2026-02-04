import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../../data/word_pack_repository.dart';
import '../../domain/models/word_pack.dart';
import '../../domain/settings/settings_state.dart';
import '../widgets/category_item.dart';
import '../widgets/category_pill.dart';
import '../widgets/logo_mark.dart';
import '../widgets/responsive_helper.dart';
import 'player_reveal_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, this.playerNames = const []});

  final List<String> playerNames;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  _GameSession? _session;
  final Map<int, bool> _revealed = {};
  String? _overrideCategoryId;
  Difficulty? _overrideDifficulty;

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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/players'),
              ),
            ),
            settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Failed to load settings: $e')),
              data: (settings) {
                final strings = Strings.fromLocale(settings.locale);
                return packAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('${strings.loadingFailed}: $e')),
                  data: (result) {
                    _ensureSession(settings, result.pack);
                    final session = _session!;
                    final names = _normalizeNames(session.players);

                    final gridItems = List.generate(session.players, (i) => i);
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
                          SizedBox(height: isTablet ? 24 : 8),
                          Center(
                            child: SizedBox(
                              height: isTablet ? 180 : 120,
                              child: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Container(
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/images/icon_square_foreground.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            LogoMark(
                                              size: isTablet ? 180 : 120,
                                              isLight: true,
                                            ),
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/icon_square.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          LogoMark(size: isTablet ? 180 : 120),
                                    ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 16 : 8),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black87,
                                      ),
                                  children: [
                                    TextSpan(text: '${strings.startsLabel} '),
                                    TextSpan(
                                      text: names[session.startingIndex],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        decoration: TextDecoration.underline,
                                        color: Color(
                                            0xFF1E88E5), // darker visible blue
                                      ),
                                    ),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Icon(
                                          Icons.notifications_active_outlined,
                                          size: 18,
                                          color: const Color(
                                              0xFF1E88E5), // match name color
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              strings.tapCardsToReveal.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: CategoryPill(
                              categoryName: session.categoryName,
                              categoryId: session.categoryId,
                              locale: settings.locale,
                              isRandomCategory: _overrideCategoryId == SettingsState.randomCategory,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                // Mejor distribución para tablets
                                int crossAxisCount;
                                if (isTablet) {
                                  if (width > 900) {
                                    crossAxisCount = 5;
                                  } else if (width > 700) {
                                    crossAxisCount = 4;
                                  } else {
                                    crossAxisCount = 3;
                                  }
                                } else {
                                  crossAxisCount = width > 600 ? 3 : 2;
                                }
                                return GridView.builder(
                                  itemCount: gridItems.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: isTablet ? 16 : 12,
                                    mainAxisSpacing: isTablet ? 16 : 12,
                                    childAspectRatio: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final isRevealed =
                                        _revealed[index] ?? false;
                                    final isImpostor =
                                        session.impostors.contains(index);
                                    final title = names[index];
                                    return _PlayerCard(
                                      title: title,
                                      revealed: isRevealed,
                                      isImpostor: isImpostor,
                                      revealLabel: strings.revealCardLabel,
                                      revealedLabel: strings.revealDone,
                                      onTap: () {
                                        _openReveal(
                                          index,
                                          title,
                                          session.categoryName,
                                          session.categoryId,
                                          session.word,
                                          isImpostor,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                              SizedBox(height: isTablet ? 20 : 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showNewRoundOptions(
                                          context, settings, result.pack, strings),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: isTablet ? 24 : 16,
                                        ),
                                        minimumSize: Size(0, isTablet ? 56 : 48),
                                      ),
                                      child: Text(
                                        strings.newWord,
                                        style: TextStyle(
                                          fontSize: isTablet ? 20 : null,
                                          fontWeight: isTablet ? FontWeight.w600 : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isTablet ? 20 : 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _revealed.clear();
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: isTablet ? 24 : 16,
                                        ),
                                        minimumSize: Size(0, isTablet ? 56 : 48),
                                      ),
                                      child: Text(
                                        strings.hideAll,
                                        style: TextStyle(
                                          fontSize: isTablet ? 20 : null,
                                          fontWeight: isTablet ? FontWeight.w600 : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _ensureSession(SettingsState settings, WordPack pack) {
    if (_session != null) return;
    _overrideCategoryId ??= settings.categoryId;
    _session = _createSession(settings, pack);
  }

  void _resetSession() {
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    final pack = ref.read(currentWordPackProvider).value?.pack;
    if (settings == null || pack == null) return;
    setState(() {
      _session = _createSession(settings, pack);
      _revealed.clear();
    });
  }

  Future<void> _showNewRoundOptions(
    BuildContext context,
    SettingsState settings,
    WordPack pack,
    Strings strings,
  ) async {
    final isTablet = ResponsiveHelper.isTablet(context);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        ),
        title: Text(
          strings.newRoundTitle,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NewRoundOption(
              icon: Icons.refresh,
              title: strings.sameCategory,
              subtitle: _overrideCategoryId == SettingsState.randomCategory
                  ? strings.randomCategory
                  : (_session?.categoryName ?? ''),
              onTap: () => Navigator.of(dialogContext).pop('same'),
              isTablet: isTablet,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            _NewRoundOption(
              icon: Icons.swap_horiz,
              title: strings.changeCategory,
              subtitle: strings.selectCategoryForNewRound,
              onTap: () => Navigator.of(dialogContext).pop('change'),
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (result == 'same') {
      // Misma intención: si era Random, volver a sortear; si era categoría fija, repetirla
      _startNewRound(settings, pack, _overrideCategoryId ?? settings.categoryId);
    } else if (result == 'change') {
      // Mostrar selector de categoría
      await _showCategorySelector(context, settings, pack, strings);
    }
  }

  Future<void> _showCategorySelector(
    BuildContext context,
    SettingsState settings,
    WordPack pack,
    Strings strings,
  ) async {
    final isTablet = ResponsiveHelper.isTablet(context);
    final categories = pack.categories;
    final sortedCategories = List<WordCategory>.from(categories)
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    // Obtener los IDs válidos de las categorías (excluyendo "random" si existe como categoría)
    final validCategoryIds = sortedCategories.map((c) => c.id).toSet();
    
    // Construir la lista de items primero, asegurándonos de que no haya duplicados
    final categoryItems = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: SettingsState.randomCategory,
        child: Row(
          key: ValueKey('random_category_row_${strings.randomCategory}'),
          children: [
            const Icon(Icons.shuffle, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              strings.randomCategory,
              key: ValueKey('random_category_text_${strings.randomCategory}'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
      // Filtrar cualquier categoría que tenga el ID "random" para evitar duplicados
      ...sortedCategories
          .where((c) => c.id != SettingsState.randomCategory)
          .map(
            (c) => DropdownMenuItem<String>(
              value: c.id,
              child: CategoryItem(
                displayName: c.displayName,
                categoryId: c.id,
              ),
            ),
          ),
    ];

    // Determinar el valor inicial: debe estar en la lista de items
    String initialCategoryId;
    final currentCategoryId = _session?.categoryId;
    if (currentCategoryId != null && 
        (currentCategoryId == SettingsState.randomCategory || 
         validCategoryIds.contains(currentCategoryId))) {
      initialCategoryId = currentCategoryId;
    } else {
      initialCategoryId = SettingsState.randomCategory;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        // Usar una variable local dentro del builder para mantener el estado
        String selectedCategoryId = initialCategoryId;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1F2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              ),
              title: Text(
                strings.selectCategoryForNewRound,
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              content: SizedBox(
                width: isTablet ? 400 : double.maxFinite,
                child: DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: strings.categoryFieldLabel,
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  menuMaxHeight: 300,
                  alignment: AlignmentDirectional.bottomStart,
                  style: TextStyle(color: Colors.white),
                  items: categoryItems,
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategoryId = value;
                      });
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    strings.cancel,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(selectedCategoryId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 20,
                      vertical: isTablet ? 12 : 10,
                    ),
                  ),
                  child: Text(
                    strings.confirm,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;

    // Crear nueva ronda con la categoría seleccionada
    _startNewRound(settings, pack, result);
  }

  void _startNewRound(SettingsState settings, WordPack pack, String? categoryId) {
    setState(() {
      if (categoryId == null || categoryId == SettingsState.randomCategory) {
        _overrideCategoryId = SettingsState.randomCategory;
      } else {
        _overrideCategoryId = categoryId;
      }
      _overrideDifficulty = null; // keep current difficulty from settings
      _session = _createSession(settings, pack);
      _revealed.clear();
    });
  }

  void _startNewRandomRound(SettingsState settings, WordPack pack) {
    _startNewRound(settings, pack, SettingsState.randomCategory);
  }

  _GameSession _createSession(SettingsState settings, WordPack pack) {
    final rand = Random.secure();
    final categories = pack.categories;

    final effectiveCategoryId = _overrideCategoryId ?? settings.categoryId;
    final effectiveDifficulty = _overrideDifficulty ?? settings.difficulty;
    
    WordEntry entry;
    String categoryName;
    String categoryId;
    
    if (effectiveCategoryId == SettingsState.randomCategory) {
      // Aleatoria: elegir palabra de categorías reales (excluir la categoría "random" del pack) y mostrar la que salió sorteada
      final wordWithCategory = <({WordEntry entry, WordCategory category})>[];
      for (final category in categories) {
        if (category.id == SettingsState.randomCategory) continue;
        final filtered = category.words
            .where((w) => w.difficulty == effectiveDifficulty)
            .toList();
        final pool = filtered.isNotEmpty ? filtered : category.words;
        for (final w in pool) {
          wordWithCategory.add((entry: w, category: category));
        }
      }
      if (wordWithCategory.isEmpty) {
        for (final category in categories) {
          if (category.id == SettingsState.randomCategory) continue;
          for (final w in category.words) {
            wordWithCategory.add((entry: w, category: category));
          }
        }
      }
      if (wordWithCategory.isEmpty) {
        final fallback = categories.firstWhere(
          (c) => c.id != SettingsState.randomCategory,
          orElse: () => categories.first,
        );
        final pool = fallback.words;
        entry = pool[rand.nextInt(pool.length)];
        categoryName = fallback.displayName;
        categoryId = fallback.id;
      } else {
        final chosen = wordWithCategory[rand.nextInt(wordWithCategory.length)];
        entry = chosen.entry;
        categoryName = chosen.category.displayName;
        categoryId = chosen.category.id;
      }
    } else {
      // Categoría específica: comportamiento normal
      final category = categories.firstWhere(
        (c) => c.id == effectiveCategoryId,
        orElse: () => categories.first,
      );
      final filtered = category.words
          .where((w) => w.difficulty == effectiveDifficulty)
          .toList();
      final pool = filtered.isNotEmpty ? filtered : category.words;
      entry = pool[rand.nextInt(pool.length)];
      categoryName = category.displayName;
      categoryId = category.id;
    }
    final impostorIndexes = <int>{};
    while (impostorIndexes.length < settings.impostors) {
      impostorIndexes.add(rand.nextInt(settings.players));
    }

    // Determine starting index
    int startingIndex;
    if (settings.preventImpostorFirst) {
      // Find a non-impostor player to start
      final nonImpostors = List.generate(
        settings.players,
        (i) => i,
      ).where((i) => !impostorIndexes.contains(i)).toList();
      if (nonImpostors.isNotEmpty) {
        startingIndex = nonImpostors[rand.nextInt(nonImpostors.length)];
      } else {
        // Fallback: if all players are impostors (shouldn't happen), just pick random
        startingIndex = rand.nextInt(settings.players);
      }
    } else {
      startingIndex = rand.nextInt(settings.players);
    }

    return _GameSession(
      word: entry.text,
      categoryName: categoryName,
      categoryId: categoryId,
      players: settings.players,
      impostors: impostorIndexes,
      startingIndex: startingIndex,
    );
  }

  List<String> _normalizeNames(int count) {
    final base = widget.playerNames
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    while (base.length < count) {
      base.add('Player ${base.length + 1}');
    }
    if (base.length > count) {
      base.removeRange(count, base.length);
    }
    return base;
  }

  Future<void> _openReveal(
    int index,
    String playerName,
    String categoryName,
    String categoryId,
    String word,
    bool isImpostor,
  ) async {
    if (_revealed[index] ?? false) return;
    final didConfirm = await context.push<bool>(
      '/reveal',
      extra: PlayerRevealArgs(
        playerName: playerName,
        categoryName: categoryName,
        categoryId: categoryId,
        word: word,
        isImpostor: isImpostor,
        isRandomCategory: _overrideCategoryId == SettingsState.randomCategory,
      ),
    );
    if (!mounted) return;
    if (didConfirm == true) {
      setState(() {
        _revealed[index] = true;
      });
    }
  }
}

class _GameSession {
  _GameSession({
    required this.word,
    required this.categoryName,
    required this.categoryId,
    required this.players,
    required this.impostors,
    required this.startingIndex,
  });

  final String word;
  final String categoryName;
  final String categoryId;
  final int players;
  final Set<int> impostors;
  final int startingIndex;
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.title,
    required this.revealed,
    required this.isImpostor,
    required this.revealLabel,
    required this.revealedLabel,
    required this.onTap,
  });

  final String title;
  final bool revealed;
  final bool isImpostor;
  final String revealLabel;
  final String revealedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;
    final isTablet = ResponsiveHelper.isTablet(context);

    return GestureDetector(
      onTap: revealed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: revealed ? cardColor.withOpacity(0.7) : cardColor,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          border: Border.all(
            color:
                revealed ? colorScheme.primary : Colors.white.withOpacity(0.08),
            width: isTablet ? 2 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: isTablet ? 16 : 12,
              offset: Offset(0, isTablet ? 12 : 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child: SizedBox(
                  height: isTablet ? 48 : 40,
                  width: isTablet ? 48 : 40,
                  child: Image.asset(
                    'assets/images/player_silhouette.png',
                    fit: BoxFit.contain,
                    color: Colors.white70,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person_outline,
                      color: Colors.white70,
                      size: isTablet ? 40 : 28,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Flexible(
                flex: 1,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 18 : 14,
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Flexible(
                flex: 1,
                child: SizedBox(
                  height: isTablet ? 22 : 20,
                  child: AnimatedCrossFade(
                    firstChild: Center(
                      child: Text(
                        revealLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ),
                    secondChild: Center(
                      child: Text(
                        revealedLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    crossFadeState: revealed
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 140),
                    layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            key: bottomChildKey,
                            left: 0,
                            top: 0,
                            right: 0,
                            child: bottomChild,
                          ),
                          Positioned(
                            key: topChildKey,
                            left: 0,
                            top: 0,
                            right: 0,
                            child: topChild,
                          ),
                        ],
                      );
                    },
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

class _NewRoundOption extends StatelessWidget {
  const _NewRoundOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isTablet = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1E88E5),
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white54,
                size: isTablet ? 28 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
