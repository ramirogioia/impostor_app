import 'package:flutter/material.dart';

import '../../app/strings.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.locale,
    this.fontSize,
  });

  final String categoryName;
  final String categoryId;
  final String locale;
  final double? fontSize;

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'famosos':
        return Icons.star;
      case 'lugares':
        return Icons.location_on;
      case 'objetos':
        return Icons.category;
      case 'comida_bebida':
        return Icons.restaurant;
      case 'cine_tv':
        return Icons.movie;
      case 'deportes':
        return Icons.sports_soccer;
      case 'marcas':
        return Icons.shopping_bag;
      case 'animales':
        return Icons.pets;
      case 'historia_cultura':
        return Icons.menu_book;
      case 'random':
        return Icons.shuffle;
      default:
        return Icons.label;
    }
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'famosos':
        return const Color(0xFFE53935); // Red
      case 'lugares':
        return const Color(0xFF1E88E5); // Blue
      case 'objetos':
        return const Color(0xFF7B1FA2); // Purple
      case 'comida_bebida':
        return const Color(0xFFF57C00); // Orange
      case 'cine_tv':
        return const Color(0xFFD32F2F); // Dark Red
      case 'deportes':
        return const Color(0xFF388E3C); // Green
      case 'marcas':
        return const Color(0xFF1976D2); // Blue
      case 'animales':
        return const Color(0xFF5D4037); // Brown
      case 'historia_cultura':
        return const Color(0xFF6A1B9A); // Deep Purple
      case 'random':
        return const Color(0xFF616161); // Grey
      default:
        return const Color(0xFFE53935); // Default Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(categoryId);
    final categoryIcon = _getCategoryIcon(categoryId);
    final strings = Strings.fromLocale(locale);
    final effectiveFontSize = fontSize ?? Theme.of(context).textTheme.titleMedium?.fontSize ?? 16;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon,
            size: fontSize != null ? fontSize! * 1.1 : 18,
            color: categoryColor,
          ),
          const SizedBox(width: 6),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: effectiveFontSize,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
              children: [
                TextSpan(text: '${strings.categoryLabel}: '),
                TextSpan(
                  text: categoryName,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

