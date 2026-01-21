import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../app/strings.dart';
import '../widgets/logo_mark.dart';

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
                // Store cached names if not already stored
                if (_cachedNames == null) {
                  _cachedNames = settings.cachedPlayerNames;
                }
                _ensureControllers(players);
                return GestureDetector(
                  onTap: () {
                    // Minimize keyboard when tapping outside text fields
                    FocusScope.of(context).unfocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: Image.asset(
                            'assets/images/icon_square.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const LogoMark(size: 140),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          strings.setupTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strings.enterPlayersSubtitle(players),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
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
                                  fontSize: 12,
                                  color: Colors.cyan,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.cyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.separated(
                            itemCount: players,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _PlayerInputCard(
                                label: '${strings.playerLabel} ${index + 1}',
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
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
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _allFilled ? _submit : null,
                            child: Text(strings.start),
                          ),
                        ),
                      ],
                    ),
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

      // Load cached name if available
      if (_cachedNames != null && index < _cachedNames!.length) {
        controller.text = _cachedNames![index];
      }

      _controllers.add(controller);
      _focusNodes.add(focusNode);
    }

    // If count increased, load cached names for new fields (already done above)
    // Also ensure existing fields have cached names loaded if they're empty
    if (_cachedNames != null) {
      for (int i = 0;
          i < count && i < _controllers.length && i < _cachedNames!.length;
          i++) {
        if (_controllers[i].text.isEmpty) {
          _controllers[i].text = _cachedNames![i];
        }
      }
    }
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
    required this.onChanged,
    required this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              onSubmitted: onSubmitted,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                hintText: 'Escribe un nombre',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
