class Strings {
  const Strings._(this.lang);

  final String lang;

  static Strings fromLocale(String locale) {
    final language = locale.split('-').first.toLowerCase();
    if (language == 'es') {
      return const Strings._('es');
    } else if (language == 'pt') {
      return const Strings._('pt');
    } else {
      return const Strings._('en');
    }
  }

  bool get isEs => lang == 'es';
  bool get isPt => lang == 'pt';

  String get appTitle => isEs ? 'Impostor' : 'Impostor';

  // Locale selection
  String get chooseLanguage => isEs
      ? 'Elegí idioma y país'
      : isPt
          ? 'Escolha idioma e país'
          : 'Choose language & country';
  String get chooseLanguageSub => isEs
      ? 'Usamos esto para cargar el pack correcto.'
      : isPt
          ? 'Usamos isso para carregar o pacote correto.'
          : 'We use this to load the right word pack.';
  String get languageLabel => isEs
      ? 'Idioma'
      : isPt
          ? 'Idioma'
          : 'Language';
  String get countryLabel => isEs
      ? 'País'
      : isPt
          ? 'País'
          : 'Country';
  String get continueLabel => isEs
      ? 'Continuar'
      : isPt
          ? 'Continuar'
          : 'Continue';
  String get vocabularyAdaptedInfo => isEs
      ? 'El vocabulario y las palabras están adaptados a la región y país seleccionados.'
      : isPt
          ? 'O vocabulário e as palavras estão adaptados à região e país selecionados.'
          : 'Vocabulary and words are adapted to the selected region and country.';

  // Setup
  String get setupTitle => isEs
      ? 'Configuración rápida'
      : isPt
          ? 'Configuração rápida'
          : 'Quick setup';
  String get setupSub => isEs
      ? 'Ajustá tu lobby antes de empezar.'
      : isPt
          ? 'Ajuste seu lobby antes de começar.'
          : 'Tune your lobby before starting.';
  String get players => isEs
      ? 'Jugadores'
      : isPt
          ? 'Jogadores'
          : 'Players';
  String get impostors => isEs
      ? 'Impostores'
      : isPt
          ? 'Impostores'
          : 'Impostors';
  String get recommended => isEs
      ? 'Sugerido'
      : isPt
          ? 'Recomendado'
          : 'Recommended';
  String get useRecommended => isEs
      ? 'Usar sugerido'
      : isPt
          ? 'Usar recomendado'
          : 'Use recommended';
  String get difficulty => isEs
      ? 'Dificultad'
      : isPt
          ? 'Dificuldade'
          : 'Difficulty';
  String get easy => isEs
      ? 'Fácil'
      : isPt
          ? 'Fácil'
          : 'Easy';
  String get medium => isEs
      ? 'Media'
      : isPt
          ? 'Média'
          : 'Medium';
  String get hard => isEs
      ? 'Difícil'
      : isPt
          ? 'Difícil'
          : 'Hard';
  String get topic => isEs
      ? 'Tema / Categoría'
      : isPt
          ? 'Tema / Categoria'
          : 'Topic / Category';
  String get chooseCategory => isEs
      ? 'Elegí categoría'
      : isPt
          ? 'Escolha categoria'
          : 'Choose category';
  String get randomCategory => isEs
      ? 'Aleatoria'
      : isPt
          ? 'Aleatória'
          : 'Random';
  String get start => isEs
      ? 'Comenzar'
      : isPt
          ? 'Começar'
          : 'Start';
  String get impostorInvalid => isEs
      ? 'Los impostores deben ser menos que los jugadores.'
      : isPt
          ? 'Os impostores devem ser menos que os jogadores.'
          : 'Impostors must be less than players.';
  String get preventImpostorFirst => isEs
      ? 'El impostor no puede comenzar la ronda'
      : isPt
          ? 'O impostor não pode começar a rodada'
          : 'Impostor cannot start the round';

  // Game
  String get tapToReveal => isEs
      ? 'Toca para ver'
      : isPt
          ? 'Toque para ver'
          : 'Tap to reveal';
  String get tapCardsToReveal => isEs
      ? 'Toca tu nombre, revela tu palabra y pasa el dispositivo.'
      : isPt
          ? 'Toque seu nome, revele sua palavra e passe o dispositivo.'
          : 'Tap your name, reveal your word, then pass the device.';
  String get impostorRole => 'Impostor';
  String get wordLabel => isEs
      ? 'Palabra'
      : isPt
          ? 'Palavra'
          : 'Word';
  String get categoryLabel => isEs
      ? 'Categoría'
      : isPt
          ? 'Categoria'
          : 'Category';
  String get newWord => isEs
      ? 'Nueva ronda'
      : isPt
          ? 'Nova rodada'
          : 'New round';
  String get hideAll => isEs
      ? 'Ocultar todos'
      : isPt
          ? 'Ocultar todos'
          : 'Hide all';
  String get playerLabel => isEs
      ? 'Jugador'
      : isPt
          ? 'Jogador'
          : 'Player';
  String get loadingFailed => isEs
      ? 'Falló la carga'
      : isPt
          ? 'Falha ao carregar'
          : 'Failed to load';
  String get revealCardLabel => isEs
      ? 'Toca para ver'
      : isPt
          ? 'Toque para ver'
          : 'Tap to reveal';
  String wordForPlayer(String name) => isEs
      ? 'La palabra para $name'
      : isPt
          ? 'A palavra para $name'
          : 'The word for $name';
  String get tapBoxToReveal => isEs
      ? 'Toca la caja para revelar'
      : isPt
          ? 'Toque a caixa para revelar'
          : 'Tap the box to reveal';
  String get understood => isEs
      ? '¡Entendido!'
      : isPt
          ? 'Entendido!'
          : 'Understood';
  String get revealDone => isEs
      ? 'Listo'
      : isPt
          ? 'Pronto'
          : 'Done';

  // Rate us
  String get rateUsTitle => isEs
      ? '¿Te gusta el juego?'
      : isPt
          ? 'Está gostando do jogo?'
          : 'Enjoying the game?';
  String get rateUsMessage => isEs
      ? 'Tu apoyo nos ayuda a seguir mejorando.'
      : isPt
          ? 'Seu apoio nos ajuda a continuar melhorando.'
          : 'Your support helps us keep improving.';
  String get rateUsCta => isEs
      ? 'Calificanos ⭐'
      : isPt
          ? 'Avalie-nos ⭐'
          : 'Rate us ⭐';
  String get rateUsLater => isEs
      ? 'Ahora no'
      : isPt
          ? 'Agora não'
          : 'Not now';

  // Rules
  String get rulesTitle => isEs
      ? 'Cómo se juega'
      : isPt
          ? 'Como jogar'
          : 'How to play';
  String get rulesSubtitle => isEs
      ? 'Guía completa para jugar una ronda.'
      : isPt
          ? 'Guia completo para jogar uma rodada.'
          : 'Full guide to play a round.';
  String get rulesGoalTitle => isEs
      ? 'Objetivo'
      : isPt
          ? 'Objetivo'
          : 'Goal';
  String get rulesGoalBody => isEs
      ? 'Encontrar al impostor. Los jugadores con palabra deben descubrir quién no la tiene, y el impostor debe mezclarse sin ser descubierto.'
      : isPt
          ? 'Encontrar o impostor. Os jogadores com palavra devem descobrir quem não a tem, e o impostor deve se misturar sem ser descoberto.'
          : 'Find the impostor. Players with the word try to spot who does not have it, and the impostor blends in without being caught.';
  String get rulesSetupTitle => isEs
      ? 'Configuración'
      : isPt
          ? 'Configuração'
          : 'Setup';
  String get rulesSetupBody => isEs
      ? 'Elegí cantidad de jugadores, impostores, categoría y dificultad. Luego ingresá los nombres.'
      : isPt
          ? 'Escolha quantidade de jogadores, impostores, categoria e dificuldade. Depois insira os nomes.'
          : 'Choose players, impostors, category, and difficulty. Then enter player names.';
  String get rulesRoundTitle => isEs
      ? 'Ronda'
      : isPt
          ? 'Rodada'
          : 'Round';
  String get rulesRoundBody => isEs
      ? 'La app indica quién empieza. Cada jugador toca su tarjeta, pasa a una pantalla donde debe tocar para revelar su rol o palabra y luego tocar “Entendido”.'
      : 'The app shows who starts. Each player taps their card, then on the reveal screen taps to see their role or word and confirms with “Understood”.';
  String get rulesImpostorTitle => 'Impostor';
  String get rulesImpostorBody => isEs
      ? 'Si te sale “Impostor”, no tenés palabra. Tu objetivo es disimular y participar sin delatarte.'
      : 'If you see “Impostor”, you have no word. Your goal is to blend in and participate without being caught.';
  String get rulesAfterTitle => isEs
      ? 'Después'
      : isPt
          ? 'Depois'
          : 'Afterwards';
  String get rulesAfterBody => isEs
      ? 'Con todos los roles vistos, discutan en grupo y descubran al impostor. Podés iniciar “Nueva ronda” o “Ocultar todos” para reiniciar las cartas.'
      : 'After all roles are seen, discuss as a group and identify the impostor. You can start a “New round” or “Hide all” to reset the cards.';
  String get rulesTipsTitle => 'Tips';
  String get rulesTipsBody => isEs
      ? 'Usá “Nueva ronda” para una categoría aleatoria con la misma configuración. Ajustá dificultad para variar la complejidad de las palabras.'
      : 'Use “New round” for a random category with the same settings. Change difficulty to vary word complexity.';

  // Player names
  String get enterPlayersTitle => isEs
      ? 'Ingresar nombres de los jugadores'
      : isPt
          ? 'Inserir nomes dos jogadores'
          : 'Enter player names';
  String enterPlayersSubtitle(int count) => isEs
      ? 'Ingresa los $count nombres y empezamos'
      : isPt
          ? 'Insira os $count nomes e começamos'
          : 'Add all $count names to start';
  String get resetUsers => isEs
      ? 'Reset users'
      : isPt
          ? 'Redefinir usuários'
          : 'Reset users';
  String get enterNameHint => isEs
      ? 'Escribe un nombre'
      : isPt
          ? 'Escreva um nome'
          : 'Enter a name';

  // Category dropdown label
  String get categoryFieldLabel => isEs
      ? 'Categoría'
      : isPt
          ? 'Categoria'
          : 'Category';

  // Start info
  String get startsLabel => isEs
      ? 'Empieza:'
      : isPt
          ? 'Começa:'
          : 'Starts:';
  String startsWith(String name) => isEs
      ? 'Empieza: $name'
      : isPt
          ? 'Começa: $name'
          : 'Starts: $name';

  // Dialog
  String get newRoundTitle => isEs
      ? 'Nueva ronda'
      : isPt
          ? 'Nova rodada'
          : 'New round';
  String get sameCategory => isEs
      ? 'Misma categoría'
      : isPt
          ? 'Mesma categoria'
          : 'Same category';
  String get changeCategory => isEs
      ? 'Cambiar categoría'
      : isPt
          ? 'Mudar categoria'
          : 'Change category';
  String get selectCategoryForNewRound => isEs
      ? 'Selecciona la categoría para la nueva ronda'
      : isPt
          ? 'Selecione a categoria para a nova rodada'
          : 'Select category for the new round';
  String get confirm => isEs
      ? 'Confirmar'
      : isPt
          ? 'Confirmar'
          : 'Confirm';
  String get cancel => isEs
      ? 'Cancelar'
      : isPt
          ? 'Cancelar'
          : 'Cancel';

  // Update
  String get updateAvailable => isEs
      ? 'Actualización disponible'
      : isPt
          ? 'Atualização disponível'
          : 'Update available';
  String get updateMessage => isEs
      ? 'Hay una nueva versión disponible. ¿Querés actualizar ahora?'
      : isPt
          ? 'Há uma nova versão disponível. Deseja atualizar agora?'
          : 'A new version is available. Would you like to update now?';
  String get updateButton => isEs
      ? 'Actualizar'
      : isPt
          ? 'Atualizar'
          : 'Update';
  String get updateLater => isEs
      ? 'Más tarde'
      : isPt
          ? 'Mais tarde'
          : 'Later';
}
