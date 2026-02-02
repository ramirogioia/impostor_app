import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings/settings_state.dart';

class SettingsStorage {
  static const _keyPlayers = 'settings_players';
  static const _keyImpostors = 'settings_impostors';
  static const _keyDifficulty = 'settings_difficulty';
  static const _keyLocale = 'settings_locale';
  static const _keyCategory = 'settings_category';
  static const _keyAutoImpostors = 'settings_auto_impostors';
  static const _keyDarkTheme = 'settings_dark_theme';
  static const _keyCachedPlayerNames = 'settings_cached_player_names';
  static const _keyCachedPlayerNamesLastUsed =
      'settings_cached_player_names_last_used';
  static const _keyPreventImpostorFirst = 'settings_prevent_impostor_first';

  Future<SettingsState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final difficultyName = prefs.getString(_keyDifficulty);
    final difficulty = Difficulty.values.firstWhere(
      (d) => d.name == difficultyName,
      orElse: () => SettingsState.initial().difficulty,
    );

    final cachedNames = prefs.getStringList(_keyCachedPlayerNames) ??
        SettingsState.initial().cachedPlayerNames;
    final cachedNamesLastUsed =
        prefs.getInt(_keyCachedPlayerNamesLastUsed);

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
      isDarkTheme:
          prefs.getBool(_keyDarkTheme) ?? SettingsState.initial().isDarkTheme,
      cachedPlayerNames: cachedNames,
      cachedPlayerNamesLastUsed: cachedNamesLastUsed,
      preventImpostorFirst: prefs.getBool(_keyPreventImpostorFirst) ??
          SettingsState.initial().preventImpostorFirst,
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
    await prefs.setBool(_keyDarkTheme, state.isDarkTheme);
    await prefs.setStringList(_keyCachedPlayerNames, state.cachedPlayerNames);
    if (state.cachedPlayerNamesLastUsed == null) {
      await prefs.remove(_keyCachedPlayerNamesLastUsed);
    } else {
      await prefs.setInt(
          _keyCachedPlayerNamesLastUsed, state.cachedPlayerNamesLastUsed!);
    }
    await prefs.setBool(_keyPreventImpostorFirst, state.preventImpostorFirst);
  }
}
