import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/logo_mark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/select-locale');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final asset = isLandscape
              ? 'assets/images/splash_landscape.png'
              : 'assets/images/splash_portrait.png';
          return ColoredBox(
            color: const Color(0xFF06070E),
            child: SizedBox.expand(
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                alignment: const Alignment(0, 0.4),
                errorBuilder: (_, __, ___) {
                  return const ColoredBox(
                    color: Colors.black,
                    child: Center(child: LogoMark()),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
