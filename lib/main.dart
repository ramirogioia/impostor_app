import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ocultar barras del sistema (status bar y navigation bar) para screenshots
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // Delay adicional del splash screen (1 segundo)
  await Future.delayed(const Duration(seconds: 1));

  runApp(const ProviderScope(child: ImpostorApp()));
}

