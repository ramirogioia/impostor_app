import 'settings_state.dart';

/// Suggest an impostor count based on player count and difficulty.
///
/// Algorithm (keep in sync with product spec):
/// 1) baseRatio by difficulty:
///    - easy:   0.12
///    - medium: 0.18
///    - hard:   0.25
/// 2) recommended = round(players * baseRatio)
/// 3) Clamp: recommended = clamp(recommended, 1, min(6, players - 1))
/// 4) For players <= 4, force recommended = 1 (all difficulties)
/// 5) For players 5-7:
///    - easy max 1, medium max 2, hard max 2 (still respecting clamp)
/// 6) For players >= 15 and difficulty hard, ensure recommended >= 3 (still clamped)
int suggestImpostors({
  required int players,
  required Difficulty difficulty,
}) {
  // Tweaked ratios to give 2 impostors earlier (e.g., 8 players on medium).
  final baseRatio = switch (difficulty) {
    Difficulty.easy => 0.14,
    Difficulty.medium => 0.20,
    Difficulty.hard => 0.27,
  };

  int recommended = (players * baseRatio).round();
  recommended = _clamp(recommended, 1, _min(6, players - 1));

  if (players <= 4) {
    return 1;
  }

  if (players >= 5 && players <= 7) {
    final maxByBracket = switch (difficulty) {
      Difficulty.easy => 1,
      Difficulty.medium => 2,
      Difficulty.hard => 2,
    };
    recommended = _clamp(recommended, 1, maxByBracket);
  }

  // For 8+ players, ensure at least 2 impostors on medium/hard.
  if (players >= 8 && difficulty != Difficulty.easy) {
    recommended = _clamp(recommended, 2, _min(6, players - 1));
  }

  if (players >= 15 && difficulty == Difficulty.hard) {
    recommended = _clamp(recommended, 3, _min(6, players - 1));
  }

  return recommended;
}

int _clamp(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

int _min(int a, int b) => a < b ? a : b;

