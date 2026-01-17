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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/setup'),
        ),
        title: const SizedBox.shrink(),
        centerTitle: true,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load settings: $e')),
        data: (settings) {
          final strings = Strings.fromLocale(settings.locale);
          final players = settings.players;
          _ensureControllers(players);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    height: 120,
                    child: Image.asset(
                      'assets/images/icon_square.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const LogoMark(size: 120),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.setupTitle,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  strings.enterPlayersSubtitle(players),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: players,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                            _submit();
                          }
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _allFilled ? _submit : null,
                    child: Text(strings.start),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _ensureControllers(int count) {
    while (_controllers.length < count) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    if (_controllers.length > count) {
      _controllers.removeRange(count, _controllers.length);
      _focusNodes.removeRange(count, _focusNodes.length);
    }
  }

  bool get _allFilled =>
      _controllers.isNotEmpty &&
      _controllers.every((c) => c.text.trim().isNotEmpty);

  void _submit() {
    final names =
        _controllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    context.go('/game', extra: names);
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
