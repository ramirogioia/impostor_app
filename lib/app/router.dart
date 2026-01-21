import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/home_screen.dart';
import '../ui/screens/locale_selection_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/setup_screen.dart';
import '../ui/screens/game_screen.dart';
import '../ui/screens/player_names_screen.dart';
import '../ui/screens/game_rules_screen.dart';
import '../ui/screens/player_reveal_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/select-locale',
    routes: [
      GoRoute(
        path: '/select-locale',
        name: 'select-locale',
        builder: (context, state) => const LocaleSelectionScreen(),
      ),
      GoRoute(
        path: '/setup',
        name: 'setup',
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/rules',
        name: 'rules',
        builder: (context, state) => const GameRulesScreen(),
      ),
      GoRoute(
        path: '/players',
        name: 'players',
        builder: (context, state) => const PlayerNamesScreen(),
      ),
      GoRoute(
        path: '/game',
        name: 'game',
        builder: (context, state) => GameScreen(
          playerNames: (state.extra as List<String>?) ?? const [],
        ),
      ),
      GoRoute(
        path: '/reveal',
        name: 'reveal',
        builder: (context, state) => PlayerRevealScreen(
          args: state.extra as PlayerRevealArgs,
        ),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

