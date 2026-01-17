enum WordDifficulty { easy, medium, hard }

class WordEntry {
  const WordEntry({
    required this.text,
    required this.difficulty,
    this.revealHint,
  });

  final String text;
  final WordDifficulty difficulty;
  final String? revealHint;

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    final difficultyName = (json['difficulty'] as String?)?.toLowerCase() ?? 'medium';
    final difficulty = WordDifficulty.values.firstWhere(
      (d) => d.name == difficultyName,
      orElse: () => WordDifficulty.medium,
    );
    return WordEntry(
      text: json['text'] as String,
      difficulty: difficulty,
      revealHint: json['reveal_hint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'difficulty': difficulty.name,
      if (revealHint != null) 'reveal_hint': revealHint,
    };
  }
}

class WordCategory {
  const WordCategory({
    required this.id,
    required this.displayName,
    required this.words,
  });

  final String id;
  final String displayName;
  final List<WordEntry> words;

  factory WordCategory.fromJson(Map<String, dynamic> json) {
    return WordCategory(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      words: (json['words'] as List<dynamic>)
          .map((e) => WordEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'words': words.map((e) => e.toJson()).toList(),
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
