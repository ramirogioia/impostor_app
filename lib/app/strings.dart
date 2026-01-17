class Strings {
  const Strings._(this.lang);

  final String lang;

  static Strings fromLocale(String locale) {
    final language = locale.split('-').first.toLowerCase();
    return language == 'es' ? const Strings._('es') : const Strings._('en');
  }

  bool get isEs => lang == 'es';

  String get appTitle => isEs ? 'Impostor' : 'Impostor';

  // Locale selection
  String get chooseLanguage => isEs ? 'Elegí idioma y país' : 'Choose language & country';
  String get chooseLanguageSub =>
      isEs ? 'Usamos esto para cargar el pack correcto.' : 'We use this to load the right word pack.';
  String get languageLabel => isEs ? 'Idioma' : 'Language';
  String get countryLabel => isEs ? 'País' : 'Country';
  String get continueLabel => isEs ? 'Continuar' : 'Continue';

  // Setup
  String get setupTitle => isEs ? 'Configuración rápida' : 'Quick setup';
  String get setupSub => isEs ? 'Ajustá tu lobby antes de empezar.' : 'Tune your lobby before starting.';
  String get players => isEs ? 'Jugadores' : 'Players';
  String get impostors => isEs ? 'Impostores' : 'Impostors';
  String get recommended => isEs ? 'Sugerido' : 'Recommended';
  String get useRecommended => isEs ? 'Usar sugerido' : 'Use recommended';
  String get difficulty => isEs ? 'Dificultad' : 'Difficulty';
  String get easy => isEs ? 'Fácil' : 'Easy';
  String get medium => isEs ? 'Media' : 'Medium';
  String get hard => isEs ? 'Difícil' : 'Hard';
  String get topic => isEs ? 'Tema / Categoría' : 'Topic / Category';
  String get chooseCategory => isEs ? 'Elegí categoría' : 'Choose category';
  String get randomCategory => isEs ? 'Aleatoria' : 'Random';
  String get start => isEs ? 'Comenzar' : 'Start';
  String get impostorInvalid =>
      isEs ? 'Los impostores deben ser menos que los jugadores.' : 'Impostors must be less than players.';

  // Game
  String get tapToReveal => isEs ? 'Toca para ver' : 'Tap to reveal';
  String get tapCardsToReveal =>
      isEs ? 'Toca cada tarjeta para ver' : 'Tap each card to reveal';
  String get impostorRole => isEs ? 'Impostor' : 'Impostor';
  String get wordLabel => isEs ? 'Palabra' : 'Word';
  String get categoryLabel => isEs ? 'Categoría' : 'Category';
  String get newWord => isEs ? 'Nueva ronda' : 'New round';
  String get hideAll => isEs ? 'Ocultar todos' : 'Hide all';
  String get playerLabel => isEs ? 'Jugador' : 'Player';
  String get loadingFailed => isEs ? 'Falló la carga' : 'Failed to load';
  String get revealCardLabel => isEs ? 'Toca para ver' : 'Tap to reveal';

  // Player names
  String get enterPlayersTitle =>
      isEs ? 'Ingresar nombres de los jugadores' : 'Enter player names';
  String enterPlayersSubtitle(int count) => isEs
      ? 'Ingresa los $count nombres y empezamos'
      : 'Add all $count names to start';

  // Category dropdown label
  String get categoryFieldLabel => isEs ? 'Categoría' : 'Category';

  // Start info
  String get startsLabel => isEs ? 'Empieza:' : 'Starts:';
  String startsWith(String name) =>
      isEs ? 'Empieza: $name' : 'Starts: $name';

  // Dialog
  String get newRoundTitle => isEs ? 'Nueva ronda' : 'New round';
  String get confirm => isEs ? 'Confirmar' : 'Confirm';
  String get cancel => isEs ? 'Cancelar' : 'Cancel';
}
