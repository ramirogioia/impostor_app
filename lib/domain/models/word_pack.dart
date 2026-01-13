enum WordDifficulty { easy, medium, hard }

class WordCategory {
  const WordCategory({
    required this.id,
    required this.displayName,
    required this.words,
    this.difficulty,
  });

  final String id;
  final String displayName;
  final List<String> words;
  final WordDifficulty? difficulty;

  factory WordCategory.fromJson(Map<String, dynamic> json) {
    return WordCategory(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      words: (json['words'] as List<dynamic>).map((e) => e as String).toList(),
      difficulty: json['difficulty'] != null
          ? WordDifficulty.values.firstWhere(
              (d) => d.name == (json['difficulty'] as String).toLowerCase(),
              orElse: () => WordDifficulty.medium,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'words': words,
      if (difficulty != null) 'difficulty': difficulty!.name,
    };
  }
}

class WordPack {
  const WordPack({
    required this.locale,
    required this.version,
    required this.categories,
  });

  final String locale;
  final int version;
  final List<WordCategory> categories;

  factory WordPack.fromJson(Map<String, dynamic> json) {
    return WordPack(
      locale: json['locale'] as String,
      version: json['version'] as int,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => WordCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'version': version,
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }
}
