import 'package:flutter/material.dart';

import '../../app/strings.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.locale,
    this.fontSize,
    this.isRandomCategory = false,
  });

  final String categoryName;
  final String categoryId;
  final String locale;
  final double? fontSize;
  /// Cuando true: icono de shuffle y color de la categoría sorteada; nunca mostrar "Random" como texto.
  final bool isRandomCategory;

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
      case 'anime':
        return Icons.auto_awesome;
      case 'bandas_musica':
        return Icons.music_note;
      case 'equipos_futbol':
        return Icons.groups;
      case 'futbolistas':
        return Icons.sports_soccer;
      case 'deportistas':
        return Icons.directions_run;
      case 'nfl_players':
        return Icons.sports_football;
      case 'nba_players':
        return Icons.sports_basketball;
      case 'us_celebrities':
        return Icons.verified;
      case 'hollywood_actors':
        return Icons.theater_comedy;
      case 'tv_shows_usa':
        return Icons.tv;
      case 'random':
        return Icons.shuffle;
      default:
        return Icons.label;
    }
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'famosos':
        return const Color(0xFFFF8F00); // Amber - celebridades
      case 'lugares':
        return const Color(0xFF1E88E5); // Azul - lugares
      case 'objetos':
        return const Color(0xFF546E7A); // Azul gris - objetos
      case 'comida_bebida':
        return const Color(0xFFF57C00); // Naranja - comida
      case 'cine_tv':
        return const Color(0xFFD84315); // Naranja oscuro - cine
      case 'deportes':
        return const Color(0xFF388E3C); // Verde - deportes
      case 'marcas':
        return const Color(0xFF3949AB); // Índigo - marcas
      case 'animales':
        return const Color(0xFF5D4037); // Marrón - animales
      case 'historia_cultura':
        return const Color(0xFF6A1B9A); // Púrpura - cultura
      case 'anime':
        return const Color(0xFFAD1457); // Rosa - anime
      case 'bandas_musica':
        return const Color(0xFF8E24AA); // Violeta - música
      case 'equipos_futbol':
        return const Color(0xFF00695C); // Verde azulado - equipos
      case 'futbolistas':
        return const Color(0xFF43A047); // Verde claro - futbolistas
      case 'deportistas':
        return const Color(0xFF0097A7); // Cian - atletas
      case 'nfl_players':
        return const Color(0xFF1565C0); // Azul oscuro - NFL
      case 'nba_players':
        return const Color(0xFFEF6C00); // Naranja intenso - NBA
      case 'us_celebrities':
        return const Color(0xFFFFB300); // Ámbar - celebs US
      case 'hollywood_actors':
        return const Color(0xFFF9A825); // Amarillo - Hollywood
      case 'tv_shows_usa':
        return const Color(0xFF00ACC1); // Cian claro - TV
      case 'random':
        return const Color(0xFF616161); // Gris - aleatorio
      default:
        return const Color(0xFF795548); // Marrón claro - default
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings.fromLocale(locale);
    final effectiveFontSize = fontSize ?? Theme.of(context).textTheme.titleMedium?.fontSize ?? 16;
    // Cuando es random: mostrar solo el nombre de la categoría sorteada, icono de shuffle, color de esa categoría
    final categoryColor = _getCategoryColor(categoryId);
    final categoryIcon = isRandomCategory
        ? _getCategoryIcon('random')
        : _getCategoryIcon(categoryId);
    // Nunca mostrar "Categoría: Random" / "Categoría: Aleatoria"; si es random sin nombre real, no mostrar ese texto
    final displayName = (categoryId == 'random' || categoryName == strings.randomCategory)
        ? '—'
        : categoryName;

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
                  text: displayName,
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

