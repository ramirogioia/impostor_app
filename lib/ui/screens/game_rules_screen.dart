import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../widgets/logo_mark.dart';

class GameRulesScreen extends ConsumerStatefulWidget {
  const GameRulesScreen({super.key});

  @override
  ConsumerState<GameRulesScreen> createState() => _GameRulesScreenState();
}

class _GameRulesScreenState extends ConsumerState<GameRulesScreen> {
  int _currentStep = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _stepKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToStep(int stepIndex) {
    final key = _stepKeys[stepIndex];
    if (key?.currentContext == null) return;

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      
      final context = key?.currentContext;
      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.1, // 10% from top
      );
    });
  }

  void _goNext(int totalSteps) {
    if (_currentStep < totalSteps - 1) {
      setState(() => _currentStep++);
      HapticFeedback.selectionClick();
      _scrollToStep(_currentStep);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      HapticFeedback.selectionClick();
      _scrollToStep(_currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            
            // Main content
            settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (settings) {
                final strings = Strings.fromLocale(settings.locale);
                final steps = _buildSteps(strings);

                return Column(
                  children: [
                    // Header (non-scrollable)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: Theme.of(context).brightness == Brightness.light
                                ? Container(
                                    color: Colors.white,
                                    child: Image.asset(
                                      'assets/images/icon_square_foreground.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const LogoMark(size: 100, isLight: true),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/icon_square.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const LogoMark(size: 100),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            strings.rulesTitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.rulesSubtitleNew,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _TipCallout(
                            title: strings.rulesQuickTipTitle,
                            body: strings.rulesQuickTipBody,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Steps (scrollable)
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 160,
                        ),
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          // Create a key for each step
                          _stepKeys.putIfAbsent(index, () => GlobalKey());
                          
                          return _StepCard(
                            key: _stepKeys[index],
                            stepNumber: index + 1,
                            title: steps[index].title,
                            icon: steps[index].icon,
                            bullets: steps[index].bullets,
                            isActive: index == _currentStep,
                            isCompleted: index < _currentStep,
                            onTap: () {
                              setState(() => _currentStep = index);
                              HapticFeedback.selectionClick();
                            },
                          );
                        },
                      ),
                    ),

                    // Bottom controls (fixed)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _currentStep == steps.length - 1
                                    ? () => context.go('/setup')
                                    : () => _goNext(steps.length),
                                child: Text(
                                  _currentStep == steps.length - 1
                                      ? strings.rulesDoneCta
                                      : strings.rulesNextCta,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextButton(
                                onPressed: _currentStep == 0 ? null : _goBack,
                                child: Text(strings.rulesBackCta),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_RulesStep> _buildSteps(Strings strings) {
    return [
      _RulesStep(
        icon: Icons.groups_rounded,
        title: strings.rulesStepSetupTitle,
        bullets: strings.rulesStepSetupBullets,
      ),
      _RulesStep(
        icon: Icons.phone_iphone_rounded,
        title: strings.rulesStepRevealTitle,
        bullets: strings.rulesStepRevealBullets,
      ),
      _RulesStep(
        icon: Icons.record_voice_over_rounded,
        title: strings.rulesStepTalkTitle,
        bullets: strings.rulesStepTalkBullets,
      ),
      _RulesStep(
        icon: Icons.how_to_vote_rounded,
        title: strings.rulesStepVoteTitle,
        bullets: strings.rulesStepVoteBullets,
      ),
      _RulesStep(
        icon: Icons.refresh_rounded,
        title: strings.rulesStepNextRoundTitle,
        bullets: strings.rulesStepNextRoundBullets,
      ),
    ];
  }
}

class _RulesStep {
  const _RulesStep({
    required this.icon,
    required this.title,
    required this.bullets,
  });

  final IconData icon;
  final String title;
  final List<String> bullets;
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.icon,
    required this.bullets,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  final int stepNumber;
  final String title;
  final IconData icon;
  final List<String> bullets;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Colors.white
        : isCompleted
            ? Colors.white70
            : Colors.white38;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step header
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : isCompleted
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : Text(
                              '$stepNumber',
                              style: TextStyle(
                                color: isActive
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                    ),
                  ),
                ],
              ),

              // Step content (only show when active)
              if (isActive) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
                      const SizedBox(height: 12),
                      for (final bullet in bullets) ...[
                        _Bullet(bullet),
                        if (bullet != bullets.last) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCallout extends StatelessWidget {
  const _TipCallout({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.lightbulb_outline_rounded,
                color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70, height: 1.25),
          ),
        ),
      ],
    );
  }
}
