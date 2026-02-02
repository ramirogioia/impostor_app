import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../../app/version_checker_notifier.dart';
import '../widgets/rate_us_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static final Uri _legalUrl = Uri.parse(
    'https://www.notion.so/Pol-tica-de-Privacidad-Impostor-2f89fd95a62b80c5969df8e44411aaca',
  );
  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();
  static const String _feedbackEmail = 'info@giftera-store.com';
  static const String _feedbackSubject = 'Impostor Words - Sugerencia';

  static String _formatTimestamp(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

  static String _buildFeedbackBody({
    required PackageInfo info,
    required String locale,
    required String platform,
    required DateTime timestamp,
  }) {
    return 'Hola, dejo mi sugerencia:\n\n'
        '[Escribí acá]\n\n'
        '---\n'
        'App: Impostor Words\n'
        'Versión: ${info.version} (build ${info.buildNumber})\n'
        'Plataforma: $platform\n'
        'Idioma: $locale\n'
        'Fecha: ${_formatTimestamp(timestamp)}';
  }

  static Uri _buildFeedbackUri({required String body}) {
    return Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      queryParameters: {
        'subject': _feedbackSubject,
        'body': body,
      },
    );
  }

  static Future<void> _showFeedbackFallbackDialog({
    required BuildContext context,
    required Strings strings,
    required String body,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(strings.feedbackDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${strings.feedbackEmailLabel}: $_feedbackEmail'),
                const SizedBox(height: 12),
                SelectableText(body),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: body));
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(strings.feedbackCopy),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final strings = Strings.fromLocale(
      settingsAsync.valueOrNull?.locale ?? 'es-AR',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load settings: $e')),
        data: (settings) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Sección de tema temporalmente deshabilitada
                      // _Section(
                      //   title: strings.themeSectionTitle,
                      //   child: SwitchListTile(
                      //     contentPadding: EdgeInsets.zero,
                      //     value: settings.isDarkTheme,
                      //     onChanged: (value) => ref
                      //         .read(settingsNotifierProvider.notifier)
                      //         .setDarkTheme(value),
                      //     secondary: Icon(
                      //       settings.isDarkTheme
                      //           ? Icons.dark_mode_outlined
                      //           : Icons.light_mode_outlined,
                      //     ),
                      //     title: Text(strings.themeDarkLabel),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      _Section(
                        title: strings.contactSectionTitle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.mail_outline),
                                title: Text(strings.feedbackTitle),
                                trailing: const Icon(Icons.chevron_right, size: 18),
                                onTap: () async {
                                  final info = await _packageInfo;
                                  final locale =
                                      Localizations.localeOf(context).toLanguageTag();
                                  final platform = Platform.isIOS ? 'ios' : 'android';
                                  final body = _buildFeedbackBody(
                                    info: info,
                                    locale: locale,
                                    platform: platform,
                                    timestamp: DateTime.now(),
                                  );
                                  final uri = _buildFeedbackUri(body: body);
                                  final launched = await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!launched && context.mounted) {
                                    await _showFeedbackFallbackDialog(
                                      context: context,
                                      strings: strings,
                                      body: body,
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.star_outline),
                                title: Text(strings.rateUsSettingsTitle),
                                trailing: const Icon(Icons.chevron_right, size: 18),
                                onTap: () {
                                  RateUsDialog.show(
                                    context: context,
                                    title: strings.rateUsTitle,
                                    message: strings.rateUsMessage,
                                    primaryLabel: strings.rateUsCta,
                                    secondaryLabel: strings.rateUsLater,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Section(
                        title: strings.legalSectionTitle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.menu_book_outlined),
                                title: Text(strings.legalGuideTitle),
                                trailing:
                                    const Icon(Icons.chevron_right, size: 18),
                                onTap: () => context.push('/rules'),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.gavel_outlined),
                                title: Text(strings.legalLinkTitle),
                                trailing: const Icon(Icons.open_in_new, size: 18),
                                onTap: () async {
                                  final launched = await launchUrl(
                                    _legalUrl,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!launched && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('No se pudo abrir el enlace.'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.system_update_alt),
                        title: Text(strings.checkUpdatesTitle),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () {
                          ref.read(versionCheckerNotifierProvider.notifier).checkForUpdates(
                            context: context,
                            strings: strings,
                            showNoUpdateMessage: true,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<PackageInfo>(
                  future: _packageInfo,
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    final versionText = info == null 
                        ? '' 
                        : 'Version: ${info.version}';
                    return Text(
                      versionText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
