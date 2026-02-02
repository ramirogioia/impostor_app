import 'package:flutter/material.dart';

/// Helper function to check if a category has a badge
String? categoryBadgeLabel(String categoryId) {
  if (categoryId == 'famosos' ||
      categoryId == 'lugares') {
    return 'HOT';
  }
  if (categoryId == 'futbolistas' ||
      categoryId == 'anime' ||
      categoryId == 'bandas_musica' ||
      categoryId == 'nfl_players' ||
      categoryId == 'nba_players' ||
      categoryId == 'us_celebrities' ||
      categoryId == 'hollywood_actors' ||
      categoryId == 'tv_shows_usa') {
    return 'NEW';
  }
  return null;
}

/// Widget to display a category name with optional HOT badge
class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.displayName,
    required this.categoryId,
  });

  final String displayName;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = categoryBadgeLabel(categoryId);

    if (badgeLabel == null) {
      return Text(displayName);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(displayName),
        const SizedBox(width: 6),
        HotBadge(label: badgeLabel),
      ],
    );
  }
}

/// Hot badge widget matching the Argentina badge style
class HotBadge extends StatefulWidget {
  const HotBadge({super.key, this.label = 'HOT'});

  final String label;

  @override
  State<HotBadge> createState() => _HotBadgeState();
}

class _HotBadgeState extends State<HotBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF4D6D),
                Color(0xFFFF7A18),
                Color(0xFFFFC107),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6A3D).withOpacity(0.35 + (0.35 * t)),
                blurRadius: 8 + (10 * t),
                spreadRadius: 0.5 + (1.5 * t),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF1A1F2E),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.06 + (0.08 * t)),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.9 + (0.1 * t)),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

