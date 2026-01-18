import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../widgets/logo_mark.dart';

class PlayerRevealArgs {
  const PlayerRevealArgs({
    required this.playerName,
    required this.categoryName,
    required this.word,
    required this.isImpostor,
  });

  final String playerName;
  final String categoryName;
  final String word;
  final bool isImpostor;
}

class PlayerRevealScreen extends ConsumerStatefulWidget {
  const PlayerRevealScreen({super.key, required this.args});

  final PlayerRevealArgs args;

  @override
  ConsumerState<PlayerRevealScreen> createState() => _PlayerRevealScreenState();
}

class _PlayerRevealScreenState extends ConsumerState<PlayerRevealScreen>
    with SingleTickerProviderStateMixin {
  bool _revealed = false;
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.96).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.96, end: 1).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 60,
      ),
    ]).animate(_tapController);
    _glow = CurvedAnimation(
      parent: _tapController,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider).valueOrNull;
    final strings = Strings.fromLocale(settings?.locale ?? 'en-US');
    final args = widget.args;
    final revealText = args.isImpostor ? strings.impostorRole : args.word;

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.wordForPlayer(args.playerName),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${strings.categoryLabel}: ${args.categoryName}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: Image.asset(
                        'assets/images/icon_square.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const LogoMark(size: 120),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (_revealed) return;
                  _tapController.forward(from: 0);
                  Future.delayed(const Duration(milliseconds: 140), () {
                    if (!mounted) return;
                    setState(() {
                      _revealed = true;
                    });
                  });
                },
                child: AnimatedBuilder(
                  animation: _tapController,
                  builder: (context, child) {
                    final glowStrength = _glow.value;
                    return Transform.scale(
                      scale: _tapScale.value,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 320),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        decoration: BoxDecoration(
                          color: _revealed
                              ? Theme.of(context).cardColor
                              : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _revealed
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white.withOpacity(0.2),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.35 * glowStrength),
                              blurRadius: 22 * glowStrength,
                              spreadRadius: 2 * glowStrength,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 96,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.92, end: 1.0)
                                      .animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _revealed
                                ? Center(
                                    key: const ValueKey('revealed'),
                                    child: Text(
                                      revealText,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: args.isImpostor
                                                ? Theme.of(context).colorScheme.error
                                                : const Color(0xFF7DF9FF),
                                          ),
                                    ),
                                  )
                                : Column(
                                    key: const ValueKey('hidden'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.visibility_outlined, size: 28),
                                      const SizedBox(height: 10),
                                      Text(
                                        strings.tapBoxToReveal,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _revealed ? () => Navigator.of(context).pop(true) : null,
                  child: Text(strings.understood),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
