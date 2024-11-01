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
  bool isDisposed = false; // Variável para verificar descarte

  GameState({required this.appProvider}){
    highScore = appProvider.highScore;
    score = appProvider.score;
    appProvider.addListener(_updateScoreFromAppProvider);
  }

  // Atualiza o score a partir do AppProvider
  void _updateScoreFromAppProvider() {
    if (isDisposed) return; // Verificação antes de atualizar
    score = appProvider.score;
    notifyListeners();
  }

  @override
  void dispose() {
    isDisposed = true; // Marca como descartado
    appProvider.removeListener(_updateScoreFromAppProvider);
    super.dispose();
  }

  /// Carrega um novo jogador secreto usando o AppProvider
  Future<void> loadNewSecretPlayer() async {
    if (isDisposed) return; // Verificação antes de atualizar
    await appProvider.loadNewSecretPlayer();
  }

  /// Verifica se o palpite está correto
  void checkGuess(BuildContext context, guessedPlayerId, secretPlayerId) {
    if (appProvider.secretPlayer != null && guessedPlayer != null) {
      if (guessedPlayerId == secretPlayerId) { // Compare IDs
        print('Acertou!');
        // Exibe caixa de diálogo de sucesso
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Parabéns!'),
              content: Text('Você acertou o jogador: ${appProvider.secretPlayer?["name"]}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    isGuessCorrect = true;
                    updateScore(true); // Atualiza o score se acertar
                    resetAttempts(); // Reseta as tentativas
                    loadNewSecretPlayer(); // Carrega um novo jogador secreto
                    Navigator.of(context).pop(); // Fecha o diálogo
                  },
                  child: Text('Continuar'),
                ),
              ],
            );
          },
        );
      } else {
          isGuessCorrect = false; // Define como falso se errou
          print(appProvider.secretPlayer?["name"]);
          incrementAttempts();
          // Adiciona o palpite ao histórico
          final guessedPlayerData = appProvider.players.firstWhere((player) => player['id'] == guessedPlayerId);
          addToGuessHistory(
            Player(
              id: guessedPlayerData['id'],
              name: guessedPlayerData['name'],
              team: guessedPlayerData['team'],
              foot: guessedPlayerData['foot'],
              height: guessedPlayerData['height'],
              icon: guessedPlayerData['icon'],
              clubLogo: guessedPlayerData['club_logo'],
              position: guessedPlayerData['position'],
              age: guessedPlayerData['age'],
              league: guessedPlayerData['league'],
              country: guessedPlayerData['country']
            ), 
          true
        );
        notifyListeners();
        if (attempts >= 6) {
          // Exibe caixa de diálogo de erro
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Que pena!'),
                content: Text('Infelizmente o jogador ${appProvider.secretPlayer?["name"]} não foi palpitado a tempo. Tente novamente!'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      resetGame(); // Reseta após 6 tentativas erradas
                      loadNewSecretPlayer(); // Carrega um novo jogador secreto
                      Navigator.of(context).pop(); // Fecha o diálogo
                    },
                    child: Text('Tentar de novo'),
                  ),
                ],
              );
            },
          );
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
      notifyListeners();
    }
  }

  /// Adiciona uma tentativa ao histórico de palpites
  void addToGuessHistory(Player player, bool isCorrect) {
    guessHistory.add(PlayerGuess(player, isCorrect));
    notifyListeners();
  }

  /// Reinicia o jogo, mantendo apenas o highScore
  void resetGame() {
    if (isDisposed) return; // Verifica se o GameState foi descartado
    print("Resetando o jogo");
    attempts = 0;
    guessHistory.clear();
    guessedPlayer = null; // Limpa o jogador adivinhado
    appProvider.resetScore(); // Reseta o score diretamente no AppProvider
    score = appProvider.score; // Atualiza o score local após o reset
    notifyListeners();
  }

  void resetAttempts() {
    if (isDisposed) return; // Verifica se o GameState foi descartado
    print("Resetando as tentativas");
    attempts = 0;
    guessHistory.clear();
    guessedPlayer = null; // Limpa o jogador adivinhado
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
  final String? icon;
  final String position;
  final int age;
  final String league;
  final String? clubLogo;
  final String country;

  Player({required this.id, required this.name, required this.team, required this.foot, required this.height, this.icon='https://via.placeholder.com/150', this.clubLogo='https://via.placeholder.com/30',  required this.position, required this.age, required this.league, required this.country});
}