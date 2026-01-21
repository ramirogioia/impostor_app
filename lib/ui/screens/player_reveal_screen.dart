import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../widgets/category_pill.dart';
import '../widgets/logo_mark.dart';
import '../widgets/responsive_helper.dart';

class PlayerRevealArgs {
  const PlayerRevealArgs({
    required this.playerName,
    required this.categoryName,
    required this.categoryId,
    required this.word,
    required this.isImpostor,
  });

  final String playerName;
  final String categoryName;
  final String categoryId;
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
      body: Builder(
        builder: (context) {
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    CategoryPill(
                      categoryName: args.categoryName,
                      categoryId: args.categoryId,
                      locale: settings?.locale ?? 'en-US',
                      fontSize: 20,
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
                    final isTablet = ResponsiveHelper.isTablet(context);
                    return Transform.scale(
                      scale: _tapScale.value,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 480 : 320,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 16,
                          vertical: isTablet ? 32 : 22,
                        ),
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
                          height: isTablet ? 120 : 96,
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
                                            fontSize: isTablet ? 32 : null,
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
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 18 : 16,
                            ),
                          ),
                          child: Text(
                            strings.understood,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : null,
                            ),
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
    );
  }
}
