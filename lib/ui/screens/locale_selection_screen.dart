import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../widgets/logo_mark.dart';
import '../widgets/rate_us_dialog.dart';

class LocaleSelectionScreen extends ConsumerStatefulWidget {
  const LocaleSelectionScreen({super.key});

  @override
  ConsumerState<LocaleSelectionScreen> createState() =>
      _LocaleSelectionScreenState();
}

class _LocaleSelectionScreenState extends ConsumerState<LocaleSelectionScreen> {
  static const Map<String, String> _languages = {
    'es': 'Español',
    'en': 'English',
  };
  static const Map<String, List<String>> _regionsByLanguage = {
    'es': ['AR', 'ES', 'MX'],
    'en': ['US', 'GB'],
  };
  static const Map<String, String> _regionLabels = {
    'AR': 'Argentina',
    'ES': 'España',
    'MX': 'México',
    'US': 'United States',
    'GB': 'United Kingdom',
  };

  String _language = 'es';
  String _region = 'AR';
  bool _prefilled = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    settingsAsync.whenData((settings) {
      if (_prefilled) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _prefilled) return;
        final locale = settings.locale;
        final parts = locale.split('-');
        setState(() {
          if (parts.isNotEmpty) {
            _language = parts.first.toLowerCase();
            if (parts.length > 1) {
              _region = parts[1].toUpperCase();
            }
          }
          _prefilled = true;
        });
      });
    });

    final isLoading = settingsAsync.isLoading || _isSaving;
    final regions = _regionsByLanguage[_language] ?? const <String>['US'];
    final currentRegion = regions.contains(_region)
        ? _region
        : (regions.isNotEmpty ? regions.first : null);
    final strings = Strings.fromLocale(
        '${_language.toLowerCase()}-${currentRegion ?? 'US'}');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: Image.asset(
                  'assets/images/icon_square.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const LogoMark(size: 140),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.chooseLanguage,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                strings.chooseLanguageSub,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _FrostedCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _language,
                      decoration: InputDecoration(
                        labelText: strings.languageLabel,
                      ),
                      dropdownColor: const Color(0xFF0F1628),
                      items: _languages.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() {
                                _language = value;
                                final newRegions = _regionsByLanguage[value] ??
                                    const <String>['US'];
                                _region = newRegions.first;
                              });
                            },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: currentRegion,
                      decoration: InputDecoration(
                        labelText: strings.countryLabel,
                      ),
                      dropdownColor: const Color(0xFF0F1628),
                      items: regions
                          .map(
                            (region) => DropdownMenuItem<String>(
                              value: region,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(_regionLabels[region] ?? region),
                                  if (region == 'AR') ...[
                                    const SizedBox(width: 6),
                                    _HotBadge(),
                                  ],
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _region = value);
                            },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveAndContinue,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(strings.continueLabel),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    RateUsDialog.show(
                      context: context,
                      title: strings.rateUsTitle,
                      message: strings.rateUsMessage,
                      primaryLabel: strings.rateUsCta,
                      secondaryLabel: strings.rateUsLater,
                    );
                  },
                  child: Text(strings.rateUsCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    final locale = '${_language}-${_region.toUpperCase()}';
    await ref.read(settingsNotifierProvider.notifier).setLocale(locale);
    if (!mounted) return;
    setState(() => _isSaving = false);
    context.go('/setup');
  }
}

class _HotBadge extends StatefulWidget {
  const _HotBadge();

  @override
  State<_HotBadge> createState() => _HotBadgeState();
}

class _HotBadgeState extends State<_HotBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF4D6D),
                Color(0xFFFF7A18),
                Color(0xFFFFC107),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6A3D).withOpacity(0.35 + (0.35 * t)),
                blurRadius: 8 + (10 * t),
                spreadRadius: 0.5 + (1.5 * t),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF1A1F2E),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.06 + (0.08 * t)),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'HOT',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.9 + (0.1 * t)),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FrostedCard extends StatelessWidget {
  const _FrostedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}
