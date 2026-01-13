import '../models/word_pack.dart';

class WordPackLoadResult {
  const WordPackLoadResult({
    required this.pack,
    required this.validation,
  });

  final WordPack pack;
  final WordPackValidationReport validation;
}

class WordPackValidationReport {
  const WordPackValidationReport({
    required this.locale,
    required this.duplicateWordsByCategory,
    required this.shortWordsByCategory,
    required this.smallCategoryCounts,
  });

  final String locale;
  final Map<String, List<String>> duplicateWordsByCategory;
  final Map<String, List<String>> shortWordsByCategory;
  final Map<String, int> smallCategoryCounts;

  bool get hasBlockingIssues =>
      shortWordsByCategory.isNotEmpty || duplicateWordsByCategory.isNotEmpty;

  bool get hasWarnings => smallCategoryCounts.isNotEmpty;

  @override
  String toString() {
    return 'WordPackValidationReport(locale: $locale, '
        'duplicates: $duplicateWordsByCategory, '
        'shortWords: $shortWordsByCategory, '
        'smallCategories: $smallCategoryCounts)';
  }
}

class WordPackValidator {
  WordPackValidator(this.pack);

  final WordPack pack;

  WordPackValidationReport validate() {
    final duplicateWordsByCategory = <String, List<String>>{};
    final shortWordsByCategory = <String, List<String>>{};
    final smallCategoryCounts = <String, int>{};

    for (final category in pack.categories) {
      final seen = <String>{};
      final duplicates = <String>[];
      final short = <String>[];

      for (final word in category.words) {
        final trimmed = word.trim();
        if (trimmed.length < 2) {
          short.add(word);
          continue;
        }
        final normalized = trimmed.toLowerCase();
        if (seen.contains(normalized)) {
          duplicates.add(word);
        } else {
          seen.add(normalized);
        }
      }

      if (duplicates.isNotEmpty) {
        duplicateWordsByCategory[category.id] = duplicates;
      }
      if (short.isNotEmpty) {
        shortWordsByCategory[category.id] = short;
      }
      if (category.words.length < 20) {
        smallCategoryCounts[category.id] = category.words.length;
      }
    }

    return WordPackValidationReport(
      locale: pack.locale,
      duplicateWordsByCategory: duplicateWordsByCategory,
      shortWordsByCategory: shortWordsByCategory,
      smallCategoryCounts: smallCategoryCounts,
    );
  }
}

