import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../widgets/logo_mark.dart';
import '../widgets/responsive_helper.dart';

class PlayerNamesScreen extends ConsumerStatefulWidget {
  const PlayerNamesScreen({super.key});

  @override
  ConsumerState<PlayerNamesScreen> createState() => _PlayerNamesScreenState();
}

class _PlayerNamesScreenState extends ConsumerState<PlayerNamesScreen> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  List<String>? _cachedNames;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Failed to load settings: $e')),
              data: (settings) {
                final strings = Strings.fromLocale(settings.locale);
                final players = settings.players;
                // Always reload cached names from settings to ensure we have the latest
                // This allows users to edit names after playing rounds
                _cachedNames = settings.cachedPlayerNames;
                _ensureControllers(players);
                return GestureDetector(
                  onTap: () {
                    // Minimize keyboard when tapping outside text fields
                    FocusScope.of(context).unfocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Builder(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: isTablet ? 20 : 12),
                                SizedBox(
                                  height: isTablet ? 160 : 140,
                                  child: Image.asset(
                                    'assets/images/icon_square.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        LogoMark(size: isTablet ? 160 : 140),
                                  ),
                                ),
                                SizedBox(height: isTablet ? 16 : 12),
                                Text(
                                  strings.setupTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: isTablet ? 32 : null,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isTablet ? 10 : 6),
                                Text(
                                  strings.enterPlayersSubtitle(players),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white70,
                                        fontSize: isTablet ? 18 : null,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isTablet ? 28 : 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: _resetUsers,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        strings.resetUsers,
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 12,
                                          color: Colors.cyan,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.cyan,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isTablet ? 12 : 8),
                                Expanded(
                                  child: isTablet
                                      ? GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20,
                                            childAspectRatio: 1.1,
                                          ),
                                          itemCount: players,
                                          itemBuilder: (context, index) {
                                            return _PlayerInputCard(
                                              label: '${strings.playerLabel} ${index + 1}',
                                              controller: _controllers[index],
                                              focusNode: _focusNodes[index],
                                              strings: strings,
                                              onChanged: () => setState(() {}),
                                              onSubmitted: (value) {
                                                if (index + 1 < players) {
                                                  _focusNodes[index + 1].requestFocus();
                                                } else {
                                                  if (_allFilled) {
                                                    _submit();
                                                  }
                                                }
                                              },
                                            );
                                          },
                                        )
                                      : ListView.separated(
                                          itemCount: players,
                                          separatorBuilder: (_, __) =>
                                              SizedBox(height: isTablet ? 14 : 10),
                                          itemBuilder: (context, index) {
                                            return _PlayerInputCard(
                                              label: '${strings.playerLabel} ${index + 1}',
                                              controller: _controllers[index],
                                              focusNode: _focusNodes[index],
                                              strings: strings,
                                              onChanged: () => setState(() {}),
                                              onSubmitted: (value) {
                                                if (index + 1 < players) {
                                                  _focusNodes[index + 1].requestFocus();
                                                } else {
                                                  // Only submit if all fields are filled
                                                  if (_allFilled) {
                                                    _submit();
                                                  }
                                                }
                                              },
                                            );
                                          },
                                        ),
                                ),
                                SizedBox(height: isTablet ? 20 : 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _allFilled ? _submit : null,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: isTablet ? 24 : 16,
                                      ),
                                      minimumSize: Size(0, isTablet ? 56 : 48),
                                    ),
                                    child: Text(
                                      strings.start,
                                      style: TextStyle(
                                        fontSize: isTablet ? 20 : null,
                                        fontWeight: isTablet ? FontWeight.w600 : null,
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
              },
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    GoRouter.of(context).go('/setup');
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ensureControllers(int count) {
    // Remove excess controllers if count decreased
    if (_controllers.length > count) {
      // Dispose removed controllers
      for (int i = count; i < _controllers.length; i++) {
        _controllers[i].dispose();
        _focusNodes[i].dispose();
      }
      _controllers.removeRange(count, _controllers.length);
      _focusNodes.removeRange(count, _focusNodes.length);
    }

    // Add new controllers if needed
    while (_controllers.length < count) {
      final index = _controllers.length;
      final controller = TextEditingController();
      final focusNode = FocusNode();

      // Load cached name if available (only when creating new controllers)
      if (_cachedNames != null && index < _cachedNames!.length) {
        controller.text = _cachedNames![index];
      }

      _controllers.add(controller);
      _focusNodes.add(focusNode);
    }

    // Note: We don't restore cached names to existing controllers here
    // because that would interfere with user editing. Cached names are only
    // loaded when creating new controllers (above). This allows users to
    // clear fields and edit names freely.
  }

  bool get _allFilled =>
      _controllers.isNotEmpty &&
      _controllers.every((c) => c.text.trim().isNotEmpty);

  void _submit() async {
    final names = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Save names to cache
    final notifier = ref.read(settingsNotifierProvider.notifier);
    await notifier.setCachedPlayerNames(names);
    _cachedNames = names;

    context.go('/game', extra: names);
  }

  void _resetUsers() async {
    // Clear all text fields
    for (final controller in _controllers) {
      controller.clear();
    }

    // Clear cache
    final notifier = ref.read(settingsNotifierProvider.notifier);
    await notifier.setCachedPlayerNames([]);
    _cachedNames = [];

    setState(() {});
  }
}

class _PlayerInputCard extends StatelessWidget {
  const _PlayerInputCard({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.strings,
    required this.onChanged,
    required this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Strings strings;
  final VoidCallback onChanged;
  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 12),
        child: isTablet
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: onSubmitted,
                      onChanged: (_) => onChanged(),
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: strings.enterNameHint,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: onSubmitted,
                    onChanged: (_) => onChanged(),
                    decoration: InputDecoration(
                      hintText: strings.enterNameHint,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
