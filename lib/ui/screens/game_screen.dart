import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../../data/word_pack_repository.dart';
import '../../domain/models/word_pack.dart';
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                              child: Image.asset(
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
                                      onPressed: () => _startNewRandomRound(
                                          settings, result.pack),
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

  void _startNewRandomRound(SettingsState settings, WordPack pack) {
    setState(() {
      _overrideCategoryId = SettingsState.randomCategory;
      _overrideDifficulty = null; // keep current difficulty from settings
      _session = _createSession(settings, pack);
      _revealed.clear();
    });
  }

  _GameSession _createSession(SettingsState settings, WordPack pack) {
    final rand = Random.secure();
    final categories = pack.categories;

    WordCategory category;
    final effectiveCategoryId = _overrideCategoryId ?? settings.categoryId;
    if (effectiveCategoryId == SettingsState.randomCategory) {
      category = categories[rand.nextInt(categories.length)];
    } else {
      category = categories.firstWhere(
        (c) => c.id == effectiveCategoryId,
        orElse: () => categories.first,
      );
    }

    final effectiveDifficulty = _overrideDifficulty ?? settings.difficulty;
    final filtered = category.words
        .where((w) => w.difficulty == effectiveDifficulty)
        .toList();
    final pool = filtered.isNotEmpty ? filtered : category.words;
    final entry = pool[rand.nextInt(pool.length)];
    final impostorIndexes = <int>{};
    while (impostorIndexes.length < settings.impostors) {
      impostorIndexes.add(rand.nextInt(settings.players));
    }

    return _GameSession(
      word: entry.text,
      categoryName: category.displayName,
      categoryId: category.id,
      players: settings.players,
      impostors: impostorIndexes,
      startingIndex: rand.nextInt(settings.players),
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
