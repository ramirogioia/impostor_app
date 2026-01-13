import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/settings_notifier.dart';
import '../domain/models/word_pack.dart';
import '../domain/validation/word_pack_validation.dart';

final wordPackRepositoryProvider = Provider<WordPackRepository>((ref) {
  return WordPackRepository();
});

final currentWordPackProvider = FutureProvider<WordPackLoadResult>((ref) async {
  final repository = ref.watch(wordPackRepositoryProvider);
  final settings = await ref.watch(settingsNotifierProvider.future);
  return repository.loadPack(settings.locale);
});

class WordPackRepository {
  WordPackRepository();

  static const String fallbackLocale = 'en-US';

  static const Map<String, String> _assetByLocale = {
    'es-AR': 'assets/words/es-AR.json',
    'es-ES': 'assets/words/es-ES.json',
    'es-MX': 'assets/words/es-MX.json',
    'en-US': 'assets/words/en-US.json',
    'en-GB': 'assets/words/en-GB.json',
  };

  static const Map<String, String> _languageFallback = {
    'es': 'es-AR',
    'en': 'en-US',
  };

  Future<WordPackLoadResult> loadPack(String locale) async {
    final resolvedLocale = _resolveLocale(locale);
    final assetPath =
        _assetByLocale[resolvedLocale] ?? _assetByLocale[fallbackLocale]!;
    final jsonString = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final pack = WordPack.fromJson(decoded);
    final validation = WordPackValidator(pack).validate();
    return WordPackLoadResult(pack: pack, validation: validation);
  }

  String _resolveLocale(String locale) {
    final normalized = _normalizeLocale(locale);
    if (_assetByLocale.containsKey(normalized)) {
      return normalized;
    }

    final parts = normalized.split('-');
    if (parts.isNotEmpty) {
      final languageCode = parts.first;
      final fallback = _languageFallback[languageCode];
      if (fallback != null && _assetByLocale.containsKey(fallback)) {
        return fallback;
      }
    }
    return fallbackLocale;
  }

  String _normalizeLocale(String locale) {
    final trimmed = locale.trim();
    if (trimmed.isEmpty) return fallbackLocale;
    final sanitized = trimmed.replaceAll('_', '-');
    final parts = sanitized.split('-');
    if (parts.length >= 2) {
      final language = parts.first.toLowerCase();
      final region = parts[1].toUpperCase();
      return '$language-$region';
    }
    return parts.first.toLowerCase();
  }
}
