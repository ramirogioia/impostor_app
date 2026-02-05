import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'strings.dart';

class ShareMomentService {
  static const String _androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.rgioia.impostorwords';
  static const String _iosStoreUrl =
      'https://apps.apple.com/ar/app/impostor-words-party-game/id6757995242';

  static Future<bool> shareMoment({
    required Strings strings,
    required int players,
  }) async {
    final storeUrl = _storeUrlForCurrentPlatform();
    final text = '${strings.shareMomentShareText(players)}\n\n'
        '${strings.shareMomentCta}\n'
        '$storeUrl';

    // Share an image to improve compatibility with Instagram.
    // Many Instagram targets don't appear for text/plain, but they do for images.
    final imageFile = await _writeShareImageToTempFile(strings);
    final files = <XFile>[
      XFile(
        imageFile.path,
        mimeType: _mimeTypeForPath(imageFile.path),
        name: _shareFilenameFor(strings),
      ),
    ];

    final result = await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: files,
      ),
    );
    return result.status == ShareResultStatus.success;
  }

  static String _storeUrlForCurrentPlatform() {
    if (Platform.isAndroid) return _androidStoreUrl;
    if (Platform.isIOS) return _iosStoreUrl;
    // Fallback (desktop/web): include both, user can delete.
    return 'Android: $_androidStoreUrl\n'
        'iOS: $_iosStoreUrl';
  }

  static Future<File> _writeShareImageToTempFile(Strings strings) async {
    final assetPath = _shareImageAssetPath(strings);
    final bytes = (await rootBundle.load(assetPath))
        .buffer
        .asUint8List();
    final dir = await getTemporaryDirectory();
    final extension = assetPath.toLowerCase().endsWith('.jpeg')
        ? 'jpeg'
        : assetPath.toLowerCase().endsWith('.jpg')
            ? 'jpg'
            : 'png';
    final file = File('${dir.path}/impostor_words_share.$extension');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static String _shareImageAssetPath(Strings strings) {
    if (strings.isEs) return 'assets/images/sharing/sharing_spanish.png';
    if (strings.isPt) return 'assets/images/sharing/sharing_portuguez.png';
    return 'assets/images/sharing/sharing_english.png';
  }

  static String _shareFilenameFor(Strings strings) {
    if (strings.isEs) return 'impostor_words_es.png';
    if (strings.isPt) return 'impostor_words_pt.png';
    return 'impostor_words_en.png';
  }

  static String _mimeTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg')) return 'image/jpeg';
    if (lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}

