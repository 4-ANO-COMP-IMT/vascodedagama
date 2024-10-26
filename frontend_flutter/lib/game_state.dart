import 'package:flutter/material.dart';
import 'package:frontend_flutter/app_provider.dart';

class GameState extends ChangeNotifier {
  final AppProvider appProvider;
  int attempts = 0;
  int score = 0;
  int highScore = 0;
  List<PlayerGuess> guessHistory = [];

  GameState({required this.appProvider});

  /// Carrega um novo jogador secreto usando o `AppProvider`
  Future<void> loadNewSecretPlayer() async {
    await appProvider.loadNewSecretPlayer();
    notifyListeners();
  }

  /// Define o jogador secreto usando o `AppProvider`
  void initializeSecretPlayer() {
    if (appProvider.secretPlayer != null) {
      setSecretPlayer(appProvider.secretPlayer!);
    }
  }

  /// Define o jogador secreto no estado do jogo
  void setSecretPlayer(Map<String, dynamic> playerData) {
    guessHistory.clear();
    attempts = 0;
    score = 0;
    notifyListeners();
  }

  /// Incrementa o número de tentativas
  void incrementAttempts() {
    attempts++;
    notifyListeners();
  }

  /// Atualiza a pontuação, reseta se incorreta
  void updateScore(bool isCorrect) {
    if (isCorrect) {
      score++;
      if (score > highScore) {
        highScore = score;
      }
    } else {
      score = 0;
    }
    notifyListeners();
  }

  /// Adiciona uma tentativa ao histórico de palpites
  void addToGuessHistory(Player player, bool isCorrect) {
    guessHistory.add(PlayerGuess(player, isCorrect));
    notifyListeners();
  }

  /// Reinicia o jogo, mantendo apenas o `highScore`
  void resetGame() {
    attempts = 0;
    score = 0;
    guessHistory.clear();
    notifyListeners();
  }
}

class PlayerGuess {
  final Player player;
  final bool isCorrect;

  PlayerGuess(this.player, this.isCorrect);
}

class Player {
  final String name;

  Player(this.name);
}
