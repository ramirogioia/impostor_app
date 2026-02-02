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
  final Set<int> _visitedSteps = {0};

  void _goToStep(int index, int totalSteps) {
    final clamped = index.clamp(0, totalSteps - 1);
    setState(() {
      _currentStep = clamped;
      _visitedSteps.add(clamped);
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Failed to load settings: $e')),
              data: (settings) {
                final strings = Strings.fromLocale(settings.locale);
                final steps = <_RulesStep>[
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

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          height: 120,
                          child: Theme.of(context).brightness ==
                                  Brightness.light
                              ? Container(
                                  color: Colors.white,
                                  child: Image.asset(
                                    'assets/images/icon_square_foreground.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const LogoMark(size: 120, isLight: true),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/icon_square.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const LogoMark(size: 120),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          strings.rulesTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          strings.rulesSubtitleNew,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _TipCallout(
                        title: strings.rulesQuickTipTitle,
                        body: strings.rulesQuickTipBody,
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context)
                                .colorScheme
                                .copyWith(primary: Colors.white),
                          ),
                          child: Stepper(
                            type: StepperType.vertical,
                            currentStep: _currentStep,
                            onStepTapped: (i) => _goToStep(i, steps.length),
                            controlsBuilder: (context, details) {
                              final isFirst = details.currentStep == 0;
                              final isLast =
                                  details.currentStep == steps.length - 1;
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: isLast
                                            ? () => context.go('/setup')
                                            : details.onStepContinue,
                                        child: Text(isLast
                                            ? strings.rulesDoneCta
                                            : strings.rulesNextCta),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: isFirst
                                            ? null
                                            : details.onStepCancel,
                                        child: Text(strings.rulesBackCta),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onStepContinue: () =>
                                _goToStep(_currentStep + 1, steps.length),
                            onStepCancel: () =>
                                _goToStep(_currentStep - 1, steps.length),
                            steps: [
                              for (var i = 0; i < steps.length; i++)
                                Step(
                                  isActive: i == _currentStep,
                                  state: _visitedSteps.contains(i)
                                      ? StepState.complete
                                      : StepState.indexed,
                                  title: Text(
                                    steps[i].title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  content: _BulletList(
                                    icon: steps[i].icon,
                                    bullets: steps[i].bullets,
                                  ),
                                ),
                            ],
                          ),
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

class _BulletList extends StatelessWidget {
  const _BulletList({required this.icon, required this.bullets});

  final IconData icon;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          const SizedBox(height: 10),
          for (final line in bullets) ...[
            _Bullet(line),
            const SizedBox(height: 8),
          ],
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
