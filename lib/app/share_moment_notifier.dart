import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final shareMomentNotifierProvider =
    AsyncNotifierProvider.autoDispose<ShareMomentNotifier, ShareMomentState>(
  ShareMomentNotifier.new,
);

class ShareMomentState {
  const ShareMomentState({
    required this.consecutiveNewRounds,
    required this.nextThreshold,
    required this.sharedThisSession,
  });

  final int consecutiveNewRounds;
  final int nextThreshold;
  final bool sharedThisSession;

  bool get shouldShowInNewRoundDialog {
    if (sharedThisSession) return false;
    return consecutiveNewRounds >= nextThreshold;
  }

  ShareMomentState copyWith({
    int? consecutiveNewRounds,
    int? nextThreshold,
    bool? sharedThisSession,
  }) {
    return ShareMomentState(
      consecutiveNewRounds: consecutiveNewRounds ?? this.consecutiveNewRounds,
      nextThreshold: nextThreshold ?? this.nextThreshold,
      sharedThisSession: sharedThisSession ?? this.sharedThisSession,
    );
  }
}

class ShareMomentNotifier extends AutoDisposeAsyncNotifier<ShareMomentState> {
  late final Random _rand;

  @override
  Future<ShareMomentState> build() async {
    // Use a time-seeded PRNG (stable across Flutter/Android toolchains).
    _rand = Random(DateTime.now().microsecondsSinceEpoch);

    return ShareMomentState(
      consecutiveNewRounds: 0,
      nextThreshold: _rollThreshold(),
      sharedThisSession: false,
    );
  }

  int _rollThreshold() => 2 + _rand.nextInt(3); // 2..4

  void onNewRoundStarted() {
    final current = state.valueOrNull;
    if (current == null) return;

    if (current.sharedThisSession) return;

    state = AsyncData(
      current.copyWith(consecutiveNewRounds: current.consecutiveNewRounds + 1),
    );
  }

  void onPromptIgnored() {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.sharedThisSession) return;

    state = AsyncData(
      current.copyWith(
        consecutiveNewRounds: 0,
        nextThreshold: _rollThreshold(),
      ),
    );
  }

  void onShared() {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        consecutiveNewRounds: 0,
        nextThreshold: _rollThreshold(),
        sharedThisSession: true,
      ),
    );
  }
}

