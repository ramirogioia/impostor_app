import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../../data/word_pack_repository.dart';
import '../../domain/models/word_pack.dart';
import '../widgets/logo_mark.dart';
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
                onPressed: () => context.go('/setup'),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
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
                                errorBuilder: (_, __, ___) =>
                                    const LogoMark(size: 120),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                            child: Text(
                              '${strings.categoryLabel}: ${session.categoryName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                final crossAxisCount = width > 900
                                    ? 4
                                    : width > 600
                                        ? 3
                                        : 2;
                                return GridView.builder(
                                  itemCount: gridItems.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _startNewRandomRound(
                                      settings, result.pack),
                                  child: Text(strings.newWord),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _revealed.clear();
                                    });
                                  },
                                  child: Text(strings.hideAll),
                                ),
                              ),
                            ],
                          ),
                        ],
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
    String word,
    bool isImpostor,
  ) async {
    if (_revealed[index] ?? false) return;
    final didConfirm = await context.push<bool>(
      '/reveal',
      extra: PlayerRevealArgs(
        playerName: playerName,
        categoryName: categoryName,
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
    required this.players,
    required this.impostors,
    required this.startingIndex,
  });

  final String word;
  final String categoryName;
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

    return GestureDetector(
      onTap: revealed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: revealed ? cardColor.withOpacity(0.7) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                revealed ? colorScheme.primary : Colors.white.withOpacity(0.08),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 44,
                width: 44,
                child: Image.asset(
                  'assets/images/player_silhouette.png',
                  fit: BoxFit.contain,
                  color: Colors.white70,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person_outline,
                    color: Colors.white70,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              AnimatedCrossFade(
                firstChild: Text(revealLabel),
                secondChild: Text(
                  revealedLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                crossFadeState: revealed
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 140),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
