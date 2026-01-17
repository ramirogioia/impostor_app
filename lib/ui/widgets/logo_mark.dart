import 'package:flutter/material.dart';

/// Simple, code-drawn version of the provided logo so we don't depend on an
/// external asset. Replace with Image.asset if you drop in the official file.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 260});

  final double size;

  @override
  Widget build(BuildContext context) {
    final hatHeight = size * 0.34;
    final hatWidth = size * 0.92;
    final bodyWidth = size * 0.52;
    final bodyHeight = size * 0.65;

    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1C2F55).withOpacity(0.5),
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -size * 0.1),
            child: Transform.rotate(
              angle: -0.1,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: hatWidth,
                    height: hatHeight * 0.42,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(hatHeight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: hatHeight * 0.08,
                    child: Container(
                      width: hatWidth * 0.64,
                      height: hatHeight * 0.7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0F16),
                        borderRadius: BorderRadius.circular(hatHeight * 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF151C2B),
                            Color(0xFF06080F),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: hatHeight * 0.48,
                    child: Container(
                      width: hatWidth * 0.7,
                      height: hatHeight * 0.1,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E1E1E),
                            Color(0xFF0B0B0B),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: bodyWidth,
            height: bodyHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF05070F),
              borderRadius: BorderRadius.circular(size * 0.18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2A7BFF).withOpacity(0.35),
                  blurRadius: 32,
                  spreadRadius: 1,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'g',
                  style: TextStyle(
                    fontSize: bodyHeight * 0.74,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 0.9,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: bodyWidth * 0.32,
                  height: bodyWidth * 0.32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A7BFF),
                    borderRadius: BorderRadius.circular(bodyWidth * 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2A7BFF).withOpacity(0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
