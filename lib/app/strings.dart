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
  String get chooseLanguage =>
      isEs ? 'Elegí idioma y país' : 'Choose language & country';
  String get chooseLanguageSub => isEs
      ? 'Usamos esto para cargar el pack correcto.'
      : 'We use this to load the right word pack.';
  String get languageLabel => isEs ? 'Idioma' : 'Language';
  String get countryLabel => isEs ? 'País' : 'Country';
  String get continueLabel => isEs ? 'Continuar' : 'Continue';

  // Setup
  String get setupTitle => isEs ? 'Configuración rápida' : 'Quick setup';
  String get setupSub => isEs
      ? 'Ajustá tu lobby antes de empezar.'
      : 'Tune your lobby before starting.';
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
  String get impostorInvalid => isEs
      ? 'Los impostores deben ser menos que los jugadores.'
      : 'Impostors must be less than players.';

  // Game
  String get tapToReveal => isEs ? 'Toca para ver' : 'Tap to reveal';
  String get tapCardsToReveal => isEs
      ? 'Toca tu nombre, revela tu palabra y pasa el dispositivo.'
      : 'Tap your name, reveal your word, then pass the device.';
  String get impostorRole => isEs ? 'Impostor' : 'Impostor';
  String get wordLabel => isEs ? 'Palabra' : 'Word';
  String get categoryLabel => isEs ? 'Categoría' : 'Category';
  String get newWord => isEs ? 'Nueva ronda' : 'New round';
  String get hideAll => isEs ? 'Ocultar todos' : 'Hide all';
  String get playerLabel => isEs ? 'Jugador' : 'Player';
  String get loadingFailed => isEs ? 'Falló la carga' : 'Failed to load';
  String get revealCardLabel => isEs ? 'Toca para ver' : 'Tap to reveal';
  String wordForPlayer(String name) =>
      isEs ? 'La palabra para $name' : 'The word for $name';
  String get tapBoxToReveal =>
      isEs ? 'Toca la caja para revelar' : 'Tap the box to reveal';
  String get understood => isEs ? '¡Entendido!' : 'Understood';
  String get revealDone => isEs ? 'Listo' : 'Done';

  // Rate us
  String get rateUsTitle => isEs ? '¿Te gusta el juego?' : 'Enjoying the game?';
  String get rateUsMessage => isEs
      ? 'Tu apoyo nos ayuda a seguir mejorando.'
      : 'Your support helps us keep improving.';
  String get rateUsCta => isEs ? 'Calificanos ⭐' : 'Rate us ⭐';
  String get rateUsLater => isEs ? 'Ahora no' : 'Not now';

  // Rules
  String get rulesTitle => isEs ? 'Cómo se juega' : 'How to play';
  String get rulesSubtitle => isEs
      ? 'Guía completa para jugar una ronda.'
      : 'Full guide to play a round.';
  String get rulesGoalTitle => isEs ? 'Objetivo' : 'Goal';
  String get rulesGoalBody => isEs
      ? 'Encontrar al impostor. Los jugadores con palabra deben descubrir quién no la tiene, y el impostor debe mezclarse sin ser descubierto.'
      : 'Find the impostor. Players with the word try to spot who does not have it, and the impostor blends in without being caught.';
  String get rulesSetupTitle => isEs ? 'Configuración' : 'Setup';
  String get rulesSetupBody => isEs
      ? 'Elegí cantidad de jugadores, impostores, categoría y dificultad. Luego ingresá los nombres.'
      : 'Choose players, impostors, category, and difficulty. Then enter player names.';
  String get rulesRoundTitle => isEs ? 'Ronda' : 'Round';
  String get rulesRoundBody => isEs
      ? 'La app indica quién empieza. Cada jugador toca su tarjeta, pasa a una pantalla donde debe tocar para revelar su rol o palabra y luego tocar “Entendido”.'
      : 'The app shows who starts. Each player taps their card, then on the reveal screen taps to see their role or word and confirms with “Understood”.';
  String get rulesImpostorTitle => isEs ? 'Impostor' : 'Impostor';
  String get rulesImpostorBody => isEs
      ? 'Si te sale “Impostor”, no tenés palabra. Tu objetivo es disimular y participar sin delatarte.'
      : 'If you see “Impostor”, you have no word. Your goal is to blend in and participate without being caught.';
  String get rulesAfterTitle => isEs ? 'Después' : 'Afterwards';
  String get rulesAfterBody => isEs
      ? 'Con todos los roles vistos, discutan en grupo y descubran al impostor. Podés iniciar “Nueva ronda” o “Ocultar todos” para reiniciar las cartas.'
      : 'After all roles are seen, discuss as a group and identify the impostor. You can start a “New round” or “Hide all” to reset the cards.';
  String get rulesTipsTitle => isEs ? 'Tips' : 'Tips';
  String get rulesTipsBody => isEs
      ? 'Usá “Nueva ronda” para una categoría aleatoria con la misma configuración. Ajustá dificultad para variar la complejidad de las palabras.'
      : 'Use “New round” for a random category with the same settings. Change difficulty to vary word complexity.';

  // Player names
  String get enterPlayersTitle =>
      isEs ? 'Ingresar nombres de los jugadores' : 'Enter player names';
  String enterPlayersSubtitle(int count) => isEs
      ? 'Ingresa los $count nombres y empezamos'
      : 'Add all $count names to start';
  String get resetUsers => isEs ? 'Reset users' : 'Reset users';

  // Category dropdown label
  String get categoryFieldLabel => isEs ? 'Categoría' : 'Category';

  // Start info
  String get startsLabel => isEs ? 'Empieza:' : 'Starts:';
  String startsWith(String name) => isEs ? 'Empieza: $name' : 'Starts: $name';

  // Dialog
  String get newRoundTitle => isEs ? 'Nueva ronda' : 'New round';
  String get confirm => isEs ? 'Confirmar' : 'Confirm';
  String get cancel => isEs ? 'Cancelar' : 'Cancel';

  // Update
  String get updateAvailable => isEs ? 'Actualización disponible' : 'Update available';
  String get updateMessage => isEs
      ? 'Hay una nueva versión disponible. ¿Querés actualizar ahora?'
      : 'A new version is available. Would you like to update now?';
  String get updateButton => isEs ? 'Actualizar' : 'Update';
  String get updateLater => isEs ? 'Más tarde' : 'Later';
}
