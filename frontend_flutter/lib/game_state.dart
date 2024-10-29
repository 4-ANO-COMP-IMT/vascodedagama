import 'package:flutter/material.dart';
import 'package:frontend_flutter/app_provider.dart';

class GameState extends ChangeNotifier {
  final AppProvider appProvider;
  int attempts = 0;
  int score = 0;
  int highScore = 0;
  List<PlayerGuess> guessHistory = [];
  Map<String, dynamic>? guessedPlayer;
  List<Map<String, dynamic>> suggestions = []; // Lista para sugestões de jogadores
  bool isGuessCorrect = false; // Variável de estado para último palpite

  GameState({required this.appProvider}){
    highScore = appProvider.highScore;
    score = appProvider.score;

    // Adiciona o listener apenas uma vez
    appProvider.addListener(_updateScoreFromAppProvider);
  }

   // Atualiza o score a partir do AppProvider
  void _updateScoreFromAppProvider() {
    score = appProvider.score;
    notifyListeners();
  }

  @override
  void dispose() {
    appProvider.removeListener(_updateScoreFromAppProvider);
    super.dispose();
  }

  /// Carrega um novo jogador secreto usando o AppProvider
  Future<void> loadNewSecretPlayer() async {
    await appProvider.loadNewSecretPlayer();
    if (appProvider.secretPlayer != null) {
      resetGame();
      notifyListeners();
    }
  }

  /// Verifica se o palpite está correto
  void checkGuess(guessedPlayerId, secretPlayerId) {
    if (appProvider.secretPlayer != null && guessedPlayer != null) {
      if (guessedPlayerId == secretPlayerId) { // Compare IDs
        print('Acertou!');
        isGuessCorrect = true; // Define como verdadeiro se acertou
        updateScore(true); // Atualiza o score se acertar
        attempts = 0; // Reseta o número de tentativas
      } else {
        isGuessCorrect = false; // Define como falso se errou
        incrementAttempts();
        // Adiciona o palpite ao histórico
        final guessedPlayerData = appProvider.players.firstWhere((player) => player['id'] == guessedPlayerId);
        addToGuessHistory(
          Player(
            guessedPlayerData['id'],
            guessedPlayerData['name'],
            guessedPlayerData['team'],
            guessedPlayerData['foot'],
            guessedPlayerData['height'],
            guessedPlayerData['position'],
            guessedPlayerData['age'],
            guessedPlayerData['league'],
            guessedPlayerData['country']
          ), 
          true
        );
        notifyListeners();
        if (attempts >= 5) {
          resetGame(); // Reseta após 5 tentativas erradas
        }
      }
      this.guessedPlayer = guessedPlayer; // Atribui o jogador adivinhado ao GameState
      notifyListeners();
    }
  }

  /// Incrementa o número de tentativas
  void incrementAttempts() {
    attempts++;
    notifyListeners();
  }

  /// Atualiza a pontuação e o highScore
  void updateScore(bool isCorrect) {
    if (isCorrect) {
      score++;
      if (score > appProvider.highScore) {
        highScore = score;
        appProvider.saveHighScore(highScore); // Salva o novo highScore
      }
    }
    notifyListeners();
  }

  /// Adiciona uma tentativa ao histórico de palpites
  void addToGuessHistory(Player player, bool isCorrect) {
    guessHistory.add(PlayerGuess(player, isCorrect));
    notifyListeners();
  }

  /// Reinicia o jogo, mantendo apenas o highScore
  void resetGame() {
    attempts = 0;
    guessHistory.clear();
    guessedPlayer = null; // Limpa o jogador adivinhado
    appProvider.resetScore(); // Reseta o score diretamente no AppProvider
    score = appProvider.score; // Atualiza o score local após o reset
    notifyListeners();
  }
}

class PlayerGuess {
  final Player player;
  final bool isCorrect;

  PlayerGuess(this.player, this.isCorrect);
}

class Player {
  final int id;
  final String name;
  final String team; 
  final String foot; 
  final int height; 
  final String icon = 'https://via.placeholder.com/150';
  final String position;
  final int age;
  final String league;
  final String country;

  Player(this.id, this.name, this.team, this.foot, this.height, this.position, this.age, this.league, this.country);
}