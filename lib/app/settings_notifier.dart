import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_storage.dart';
import '../domain/settings/impostor_suggestion.dart';
import '../domain/settings/settings_state.dart';

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  late final SettingsStorage _storage;

  @override
  Future<SettingsState> build() async {
    _storage = SettingsStorage();
    final loaded = await _storage.load();
    // Keep cached player names - don't clear them on app start
    // Users should be able to edit names after playing rounds
    // Ensure stored values respect constraints.
    var sanitized = _sanitizeState(loaded);
    if (sanitized.cachedPlayerNames.isNotEmpty &&
        sanitized.cachedPlayerNamesLastUsed == null) {
      sanitized = sanitized.copyWith(
        cachedPlayerNamesLastUsed: DateTime.now().millisecondsSinceEpoch,
      );
      await _storage.save(sanitized);
    }
    return sanitized;
  }

  Future<void> setPlayers(int value) async {
    final current = state.value ?? SettingsState.initial();
    final players =
        _clamp(value, SettingsState.minPlayers, SettingsState.maxPlayers);
    var impostors = current.impostors;

    // Do not auto-apply suggested impostors when player count changes.
    // Only clamp if current impostors becomes invalid.
    if (impostors >= players) {
      impostors = _clamp(
          players - 1, SettingsState.minImpostors, SettingsState.maxImpostors);
    }

    await _updateState(
      current.copyWith(players: players, impostors: impostors),
    );
  }

  Future<void> setImpostors(int value) async {
    final current = state.value ?? SettingsState.initial();
    final impostors = _clamp(
      value,
      SettingsState.minImpostors,
      _min(SettingsState.maxImpostors, current.players - 1),
    );
    await _updateState(current.copyWith(impostors: impostors));
  }

  Future<void> setDifficulty(Difficulty difficulty) async {
    final current = state.value ?? SettingsState.initial();
    // Do not auto-change impostors on difficulty change to avoid UX jumps.
    // Only clamp if the current value becomes invalid.
    var impostors = current.impostors;
    if (impostors >= current.players) {
      impostors = _clamp(current.players - 1, SettingsState.minImpostors,
          SettingsState.maxImpostors);
    }
    await _updateState(
        current.copyWith(difficulty: difficulty, impostors: impostors));
  }

  Future<void> setLocale(String locale) async {
    final current = state.value ?? SettingsState.initial();
    // When locale changes, category may become invalid; reset to random for now.
    await _updateState(
      current.copyWith(
          locale: locale, categoryId: SettingsState.randomCategory),
    );
  }

  Future<void> setCategory(String categoryId) async {
    final current = state.value ?? SettingsState.initial();
    await _updateState(current.copyWith(categoryId: categoryId));
  }

  Future<void> setAutoImpostors(bool enabled) async {
    final current = state.value ?? SettingsState.initial();
    var impostors = current.impostors;
    if (enabled) {
      impostors = suggestImpostors(
          players: current.players, difficulty: current.difficulty);
    } else if (impostors >= current.players) {
      impostors = _clamp(current.players - 1, SettingsState.minImpostors,
          SettingsState.maxImpostors);
    }
    await _updateState(
        current.copyWith(autoImpostors: enabled, impostors: impostors));
  }

  Future<void> setDarkTheme(bool isDark) async {
    final current = state.value ?? SettingsState.initial();
    await _updateState(current.copyWith(isDarkTheme: isDark));
  }

  Future<void> useRecommendedImpostors() async {
    final current = state.value ?? SettingsState.initial();
    final impostors = suggestImpostors(
        players: current.players, difficulty: current.difficulty);
    await _updateState(current.copyWith(impostors: impostors));
  }

  Future<void> setCachedPlayerNames(List<String> names) async {
    final current = state.value ?? SettingsState.initial();
    final hasNames = names.isNotEmpty;
    await _updateState(
      current.copyWith(
        cachedPlayerNames: names,
        cachedPlayerNamesLastUsed:
            hasNames ? DateTime.now().millisecondsSinceEpoch : null,
      ),
    );
  }

  Future<void> setPreventImpostorFirst(bool value) async {
    final current = state.value ?? SettingsState.initial();
    await _updateState(current.copyWith(preventImpostorFirst: value));
  }

  Future<void> clearCachedPlayerNamesIfExpired({
    Duration maxAge = const Duration(hours: 12),
  }) async {
    final current = state.value ?? SettingsState.initial();
    if (current.cachedPlayerNames.isEmpty) {
      return;
    }
    final lastUsedMillis = current.cachedPlayerNamesLastUsed;
    if (lastUsedMillis == null) {
      return;
    }
    final lastUsed =
        DateTime.fromMillisecondsSinceEpoch(lastUsedMillis, isUtc: false);
    final now = DateTime.now();
    if (now.difference(lastUsed) >= maxAge) {
      await _updateState(
        current.copyWith(
          cachedPlayerNames: [],
          cachedPlayerNamesLastUsed: null,
        ),
      );
    }
  }

  SettingsState _sanitizeState(SettingsState state) {
    final players = _clamp(
        state.players, SettingsState.minPlayers, SettingsState.maxPlayers);
    var impostors = _clamp(
      state.impostors,
      SettingsState.minImpostors,
      _min(SettingsState.maxImpostors, players - 1),
    );
    if (impostors >= players) {
      impostors = _clamp(
          players - 1, SettingsState.minImpostors, SettingsState.maxImpostors);
    }
    return state.copyWith(players: players, impostors: impostors);
  }

  Future<void> _updateState(SettingsState next) async {
    state = AsyncData(next);
    await _storage.save(next);
  }
}

int _clamp(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

int _min(int a, int b) => a < b ? a : b;
