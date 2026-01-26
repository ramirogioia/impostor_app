import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../widgets/category_item.dart';
import '../widgets/logo_mark.dart';
import '../widgets/rate_us_dialog.dart';
import '../widgets/responsive_helper.dart';

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
    'pt': 'Português',
  };
  static const Map<String, List<String>> _regionsByLanguage = {
    'es': ['AR', 'ES', 'MX', 'UY'],
    'en': ['US', 'GB', 'AU', 'CA'],
    'pt': ['BR', 'PT'],
  };
  static const Map<String, String> _regionLabels = {
    'AR': 'Argentina',
    'ES': 'España',
    'MX': 'México',
    'UY': 'Uruguay',
    'US': 'United States',
    'GB': 'United Kingdom',
    'AU': 'Australia',
    'CA': 'Canada',
    'BR': 'Brasil',
    'PT': 'Portugal',
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

    final isTablet = ResponsiveHelper.isTablet(context);
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final verticalPadding = ResponsiveHelper.getVerticalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isTablet ? 24 : 12),
                  SizedBox(
                    height: isTablet ? 180 : 140,
                    child: Image.asset(
                      'assets/images/icon_square.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => LogoMark(
                        size: isTablet ? 180 : 140,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 12),
                  Text(
                    strings.chooseLanguage,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: isTablet ? 32 : null,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 10 : 6),
                  Text(
                    strings.chooseLanguageSub,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: isTablet ? 18 : null,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  _FrostedCard(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _language,
                          decoration: InputDecoration(
                            labelText: strings.languageLabel,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 16 : 12,
                              vertical: isTablet ? 20 : 16,
                            ),
                          ),
                          dropdownColor: const Color(0xFF0F1628),
                          menuMaxHeight: 300,
                          alignment: AlignmentDirectional.bottomStart,
                          items: _languages.entries
                              .map(
                                (entry) => DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : null,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _language = value;
                                    final newRegions =
                                        _regionsByLanguage[value] ??
                                            const <String>['US'];
                                    _region = newRegions.first;
                                  });
                                },
                        ),
                        SizedBox(height: isTablet ? 20 : 14),
                        DropdownButtonFormField<String>(
                          value: currentRegion,
                          decoration: InputDecoration(
                            labelText: strings.countryLabel,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 16 : 12,
                              vertical: isTablet ? 20 : 16,
                            ),
                          ),
                          dropdownColor: const Color(0xFF0F1628),
                          menuMaxHeight: 300,
                          alignment: AlignmentDirectional.bottomStart,
                          items: regions
                              .map(
                                (region) => DropdownMenuItem<String>(
                                  value: region,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _regionLabels[region] ?? region,
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : null,
                                        ),
                                      ),
                                      if (region == 'AR') ...[
                                        const SizedBox(width: 6),
                                        const HotBadge(),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          selectedItemBuilder: (context) {
                            // Mostrar el badge "HOT" cuando Argentina está seleccionada
                            return regions.map((region) {
                              final label = _regionLabels[region] ?? region;
                              if (region == 'AR') {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: isTablet ? 18 : null,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const HotBadge(),
                                  ],
                                );
                              }
                              return Text(
                                label,
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : null,
                                ),
                              );
                            }).toList();
                          },
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() => _region = value);
                                },
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: isTablet ? 20 : 16,
                              color: Colors.white70,
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Expanded(
                              child: Text(
                                strings.vocabularyAdaptedInfo,
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 28 : 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _saveAndContinue,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 18 : 16,
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: isTablet ? 24 : 20,
                                    width: isTablet ? 24 : 20,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    strings.continueLabel,
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : null,
                                    ),
                                  ),
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
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 18 : 16,
                        ),
                      ),
                      child: Text(
                        strings.rateUsCta,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
