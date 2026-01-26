import '../models/word_pack.dart';

enum Difficulty { easy, medium, hard }

class SettingsState {
  const SettingsState({
    required this.players,
    required this.impostors,
    required this.difficulty,
    required this.locale,
    required this.categoryId,
    required this.autoImpostors,
    this.cachedPlayerNames = const [],
    this.preventImpostorFirst = false,
  });

  static const int minPlayers = 3;
  static const int maxPlayers = 20;
  static const int minImpostors = 1;
  static const int maxImpostors = 6;
  static const String randomCategory = 'random';

  factory SettingsState.initial() {
    return const SettingsState(
      players: 3,
      impostors: 1,
      difficulty: Difficulty.medium,
      locale: 'es-AR',
      categoryId: randomCategory,
      autoImpostors: true,
      cachedPlayerNames: [],
      preventImpostorFirst: false,
    );
  }

  final int players;
  final int impostors;
  final Difficulty difficulty;
  final String locale;
  final String categoryId;
  final bool autoImpostors;
  final List<String> cachedPlayerNames;
  final bool preventImpostorFirst;

  SettingsState copyWith({
    int? players,
    int? impostors,
    Difficulty? difficulty,
    String? locale,
    String? categoryId,
    bool? autoImpostors,
    List<String>? cachedPlayerNames,
    bool? preventImpostorFirst,
  }) {
    return SettingsState(
      players: players ?? this.players,
      impostors: impostors ?? this.impostors,
      difficulty: difficulty ?? this.difficulty,
      locale: locale ?? this.locale,
      categoryId: categoryId ?? this.categoryId,
      autoImpostors: autoImpostors ?? this.autoImpostors,
      cachedPlayerNames: cachedPlayerNames ?? this.cachedPlayerNames,
      preventImpostorFirst: preventImpostorFirst ?? this.preventImpostorFirst,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'players': players,
      'impostors': impostors,
      'difficulty': difficulty.name,
      'locale': locale,
      'categoryId': categoryId,
      'autoImpostors': autoImpostors,
      'cachedPlayerNames': cachedPlayerNames,
      'preventImpostorFirst': preventImpostorFirst,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    final difficultyName = json['difficulty'] as String?;
    final difficulty = Difficulty.values.firstWhere(
      (d) => d.name == difficultyName,
      orElse: () => Difficulty.medium,
    );
    final cachedNames = json['cachedPlayerNames'];
    final List<String> playerNames;
    if (cachedNames is List) {
      playerNames = cachedNames.map((e) => e.toString()).toList();
    } else {
      playerNames = SettingsState.initial().cachedPlayerNames;
    }
    return SettingsState(
      players: (json['players'] as int?) ?? SettingsState.initial().players,
      impostors:
          (json['impostors'] as int?) ?? SettingsState.initial().impostors,
      difficulty: difficulty,
      locale: (json['locale'] as String?) ?? SettingsState.initial().locale,
      categoryId:
          (json['categoryId'] as String?) ?? SettingsState.initial().categoryId,
      autoImpostors: (json['autoImpostors'] as bool?) ??
          SettingsState.initial().autoImpostors,
      cachedPlayerNames: playerNames,
      preventImpostorFirst: (json['preventImpostorFirst'] as bool?) ??
          SettingsState.initial().preventImpostorFirst,
    );
  }

  // Este método está deprecado - usar Strings.fromLocale(locale).randomCategory en su lugar
  // Se mantiene solo para compatibilidad, pero debería eliminarse
  @Deprecated('Use Strings.fromLocale(locale).randomCategory instead')
  String categoryLabel(List<WordCategory> categories) {
    // Nota: Este método no puede localizar correctamente porque no tiene acceso al locale
    // Debería eliminarse o modificarse para recibir el locale como parámetro
    if (categoryId == randomCategory) {
      // Retornar un valor genérico - el código que use esto debería usar Strings en su lugar
      return 'Random'; // Este método está deprecado
    }
    return categories
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => const WordCategory(
            id: randomCategory,
            displayName: 'Random', // Este método está deprecado
            words: [],
          ),
        )
        .displayName;
  }
}
