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
  });

  static const int minPlayers = 3;
  static const int maxPlayers = 20;
  static const int minImpostors = 1;
  static const int maxImpostors = 6;
  static const String randomCategory = 'random';

  factory SettingsState.initial() {
    return const SettingsState(
      players: 6,
      impostors: 1,
      difficulty: Difficulty.medium,
      locale: 'en-US',
      categoryId: randomCategory,
      autoImpostors: true,
    );
  }

  final int players;
  final int impostors;
  final Difficulty difficulty;
  final String locale;
  final String categoryId;
  final bool autoImpostors;

  SettingsState copyWith({
    int? players,
    int? impostors,
    Difficulty? difficulty,
    String? locale,
    String? categoryId,
    bool? autoImpostors,
  }) {
    return SettingsState(
      players: players ?? this.players,
      impostors: impostors ?? this.impostors,
      difficulty: difficulty ?? this.difficulty,
      locale: locale ?? this.locale,
      categoryId: categoryId ?? this.categoryId,
      autoImpostors: autoImpostors ?? this.autoImpostors,
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
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    final difficultyName = json['difficulty'] as String?;
    final difficulty = Difficulty.values.firstWhere(
      (d) => d.name == difficultyName,
      orElse: () => Difficulty.medium,
    );
    return SettingsState(
      players: (json['players'] as int?) ?? SettingsState.initial().players,
      impostors:
          (json['impostors'] as int?) ?? SettingsState.initial().impostors,
      difficulty: difficulty,
      locale: (json['locale'] as String?) ?? SettingsState.initial().locale,
      categoryId:
          (json['categoryId'] as String?) ?? SettingsState.initial().categoryId,
      autoImpostors:
          (json['autoImpostors'] as bool?) ?? SettingsState.initial().autoImpostors,
    );
  }

  String categoryLabel(List<WordCategory> categories) {
    if (categoryId == randomCategory) return 'Random';
    return categories
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => const WordCategory(
            id: randomCategory,
            displayName: 'Random',
            words: [],
          ),
        )
        .displayName;
  }
}

