import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings/settings_state.dart';

class SettingsStorage {
  static const _keyPlayers = 'settings_players';
  static const _keyImpostors = 'settings_impostors';
  static const _keyDifficulty = 'settings_difficulty';
  static const _keyLocale = 'settings_locale';
  static const _keyCategory = 'settings_category';
  static const _keyAutoImpostors = 'settings_auto_impostors';

  Future<SettingsState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final difficultyName = prefs.getString(_keyDifficulty);
    final difficulty = Difficulty.values.firstWhere(
      (d) => d.name == difficultyName,
      orElse: () => SettingsState.initial().difficulty,
    );

    final loaded = SettingsState(
      players: prefs.getInt(_keyPlayers) ?? SettingsState.initial().players,
      impostors:
          prefs.getInt(_keyImpostors) ?? SettingsState.initial().impostors,
      difficulty: difficulty,
      locale: prefs.getString(_keyLocale) ?? SettingsState.initial().locale,
      categoryId:
          prefs.getString(_keyCategory) ?? SettingsState.initial().categoryId,
      autoImpostors: prefs.getBool(_keyAutoImpostors) ??
          SettingsState.initial().autoImpostors,
    );

    return loaded;
  }

  Future<void> save(SettingsState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPlayers, state.players);
    await prefs.setInt(_keyImpostors, state.impostors);
    await prefs.setString(_keyDifficulty, state.difficulty.name);
    await prefs.setString(_keyLocale, state.locale);
    await prefs.setString(_keyCategory, state.categoryId);
    await prefs.setBool(_keyAutoImpostors, state.autoImpostors);
  }
}

