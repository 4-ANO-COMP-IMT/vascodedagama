import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/app_provider.dart';
import 'package:frontend_flutter/game_state.dart';
import 'package:frontend_flutter/widgets/player_name_widget.dart';
import 'package:frontend_flutter/widgets/player_number_widget.dart';
import 'package:frontend_flutter/widgets/player_string_widget.dart';
import 'package:frontend_flutter/widgets/profile_dialog.dart';
import 'package:provider/provider.dart';

// Página principal do aplicativo, que exibe o jogo ou o conteúdo de login
class HomePage extends StatefulWidget {
  final bool isLoggedIn; // Indica se o usuário está logado
  final String? user; // Guarda o nome do usuário, se disponível

  const HomePage({super.key, required this.isLoggedIn, this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _guessController =
      TextEditingController(); // Controlador para o campo de texto de palpites
  Timer? _debounce; // Temporizador para debounce no campo de texto
  bool _isCorrectGuess = false; // Indica se o último palpite foi correto
  late AnimationController
      _animationController; // Controlador para animações de feedback visual

  @override
  void initState() {
    super.initState();
    // Configura a animação de feedback com uma duração de 500ms
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Carrega a lista de jogadores ao iniciar a página
    Provider.of<AppProvider>(context, listen: false).fetchPlayers();
    Provider.of<GameState>(context, listen: false).loadNewSecretPlayer();
  }

  @override
  void dispose() {
    // Libera o controlador de texto e o controlador de animação ao encerrar a página
    _guessController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Método que retorna a cor de validação (verde para correto, vermelho para incorreto)
  Color _getValidationColor(bool isCorrect) =>
      isCorrect ? Colors.green : Colors.red;

  // Executa uma animação de feedback visual quando o palpite está certo ou errado
  void _showResultAnimation(bool isCorrect) {
    setState(() => _isCorrectGuess = isCorrect);
    _animationController.forward(from: 0.0); // Inicia a animação
  }

  // Widget de comparação para um atributo (ex: altura, idade), indicando se é igual, maior ou menor
  Widget getComparisonWidget(
      String label, dynamic guessedValue, dynamic secretValue) {
    IconData icon;
    int? guessedNum =
        guessedValue is String ? int.tryParse(guessedValue) : guessedValue;
    int? secretNum =
        secretValue is String ? int.tryParse(secretValue) : secretValue;

    bool isCorrect =
        guessedNum == secretNum; // Verifica se os valores coincidem
    icon = isCorrect
        ? Icons.check
        : (guessedNum! < secretNum!
            ? Icons.arrow_upward
            : Icons.arrow_downward);

    return Row(
      children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getValidationColor(isCorrect))),
        Icon(icon, size: 18, color: _getValidationColor(isCorrect)),
      ],
    );
  }

  // Widget para validação de atributos iguais (ex: time, país, posição)
  Widget getValidationWidget(
      String label, dynamic guessedValue, dynamic secretValue) {
    bool isCorrect =
        guessedValue == secretValue; // Verifica se os valores coincidem
    IconData icon = isCorrect ? Icons.check : Icons.close;

    return Row(
      children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getValidationColor(isCorrect))),
        Icon(icon, size: 18, color: _getValidationColor(isCorrect)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Championsdle'),
        // Botão de perfil ou login
        leading: IconButton(
          icon: appProvider.isLoggedIn
              ? const Icon(Icons.person, color: Colors.black)
              : const Icon(Icons.login, color: Colors.black),
          onPressed: () {
            if (appProvider.isLoggedIn) {
              showDialog(
                  context: context,
                  builder: (context) => ProfileDialog(
                        name: appProvider.userEmail ?? 'Unknown User',
                        score: gameState.score,
                        onLogout: () {
                          appProvider.logout();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ));
            } else {
              Navigator.pushNamed(context, '/login');
            }
          },
        ),
        actions: [
          // Botão de ajuda
          IconButton(
            icon: const Icon(Icons.help, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/champions-stadium.png'), // Insira o caminho da imagem
            fit: BoxFit.cover, // Ajusta a imagem ao tamanho do Container
          ),
        ),
        child: SingleChildScrollView(
          child: appProvider.isLoggedIn
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text('Tentativas: ${gameState.attempts}/6',
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white)), // Contador de tentativas
                    Text(
                      'Pontuação: ${gameState.score}',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ), // Exibe a pontuação
                    Text(
                      'Recorde: ${gameState.highScore}',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ), // Exibe o recorde
                    const SizedBox(height: 40),
                    // Condicional para exibir o jogador secreto se disponível
                    appProvider.secretPlayer != null
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Coluna de input e histórico de tentativas
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextField(
                                        style: const TextStyle(
                                            color: Colors.white),
                                        controller: _guessController,
                                        onChanged: (text) {
                                          // Debounce para limitar a quantidade de chamadas ao digitar
                                          _debounce?.cancel();
                                          _debounce = Timer(
                                              const Duration(milliseconds: 500),
                                              () {
                                            setState(() {
                                              // Sugestões de jogadores ao digitar (filtra enquanto o usuário digita)
                                              gameState.suggestions = appProvider
                                                  .players
                                                  .where((player) =>
                                                      player['name']
                                                          .toLowerCase()
                                                          .contains(text
                                                              .toLowerCase()) &&
                                                      !gameState.guessHistory
                                                          .any((guess) =>
                                                              guess.player.id ==
                                                              player['id']))
                                                  .toList();
                                            });
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Adivinhe o nome do jogador secreto',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Exibe mensagem de acerto ou erro com animação
                                    FadeTransition(
                                      opacity: _animationController,
                                      child: Text(
                                        _isCorrectGuess ? "Acertou!" : "Errou!",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: _isCorrectGuess
                                              ? Colors.green
                                              : const Color.fromARGB(
                                                  255, 244, 48, 34),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Lista de sugestões de jogadores baseada na entrada de texto
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount: gameState.suggestions.length,
                                        itemBuilder: (context, index) {
                                          final player =
                                              gameState.suggestions[index];
                                          return ListTile(
                                            title: Text(player['name'],
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            onTap: () {
                                              setState(() {
                                                // Atualiza o texto e verifica o palpite
                                                _guessController.text =
                                                    player['name'];
                                                gameState.guessedPlayer =
                                                    player;
                                                gameState.suggestions = [];
                                                _guessController.clear();
                                              });
                                              gameState.checkGuess(
                                                  context,
                                                  player['id'],
                                                  appProvider
                                                      .secretPlayer!['id']);
                                              _showResultAnimation(
                                                  gameState.isGuessCorrect);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    // Histórico de palpites do jogador
                                    gameState.guessHistory.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                  'Histórico de Palpites:',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(
                                                height: 300,
                                                child: ListView.builder(
                                                  reverse: false,
                                                  itemCount: gameState
                                                      .guessHistory.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final guess = gameState
                                                        .guessHistory[gameState
                                                            .guessHistory
                                                            .length -
                                                        1 -
                                                        index];
                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5,
                                                          horizontal: 10),
                                                      child: ListTile(
                                                        leading: guess.player
                                                                    .name ==
                                                                appProvider
                                                                        .secretPlayer![
                                                                    'name']
                                                            ? const Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .green)
                                                            : const Icon(
                                                                Icons.close,
                                                                color:
                                                                    Colors.red),
                                                        title: SingleChildScrollView(
                                                          scrollDirection: Axis
                                                              .horizontal,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              PlayerNameWidget(
                                                                  guessedName:
                                                                      guess.player
                                                                          .name,
                                                                  realName:
                                                                      appProvider
                                                                              .secretPlayer![
                                                                          'name'],
                                                                  iconUrl: guess
                                                                      .player
                                                                      .icon),
                                                              PlayerNumberWidget(
                                                                  type: 'Altura',
                                                                  guessedNumber:
                                                                      guess.player
                                                                          .height,
                                                                  realNumber: appProvider
                                                                          .secretPlayer![
                                                                      'height']),
                                                              PlayerStringWidget(
                                                                type: 'Time',
                                                                guessedString:
                                                                    guess.player
                                                                        .team,
                                                                realString:
                                                                    appProvider
                                                                            .secretPlayer![
                                                                        'team'],
                                                                iconUrl: guess
                                                                    .player
                                                                    .clubLogo,
                                                              ),
                                                              PlayerStringWidget(
                                                                  type:
                                                                      'Nacionalidade',
                                                                  guessedString:
                                                                      guess.player
                                                                          .country,
                                                                  realString:
                                                                      appProvider
                                                                              .secretPlayer![
                                                                          'country']),
                                                              PlayerNumberWidget(
                                                                  type: 'Idade',
                                                                  guessedNumber:
                                                                      guess.player
                                                                          .age,
                                                                  realNumber:
                                                                      appProvider
                                                                              .secretPlayer![
                                                                          'age']),
                                                              // PlayerStringWidget(
                                                              //     type: 'Pé',
                                                              //     guessedString:
                                                              //         guess.player
                                                              //             .foot,
                                                              //     realString:
                                                              //         appProvider
                                                              //                 .secretPlayer![
                                                              //             'foot']),
                                                              PlayerStringWidget(
                                                                  type: 'Posição',
                                                                  guessedString:
                                                                      guess.player
                                                                          .position,
                                                                  realString: appProvider
                                                                          .secretPlayer![
                                                                      'position']),
                                                              PlayerStringWidget(
                                                                  type: 'Liga',
                                                                  guessedString:
                                                                      guess.player
                                                                          .league,
                                                                  realString: appProvider
                                                                          .secretPlayer![
                                                                      'league']),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                              // Coluna que exibe os detalhes do jogador secreto
                              const SizedBox(width: 20),
                            ],
                          )
                        : const Text('Carregando jogador secreto...'),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_soccer,
                            size: 80, color: Colors.blueAccent),
                        const SizedBox(height: 120),
                        const Text(
                          'Championsdle',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Faça login para acessar o conteúdo',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ), // Mensagem se não estiver logado
        ),
      ),
      // Botão flutuante para carregar um novo jogador secreto
      floatingActionButton: appProvider.isLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                await appProvider
                    .loadNewSecretPlayer(); // Carrega um novo jogador secreto
                gameState.resetGame(); // Reseta o estado do jogo
                _guessController.clear(); // Limpa o campo
              },
              tooltip: 'Novo Jogador Secreto',
              child: const Icon(Icons.refresh),
            )
          : null, // Não exibe o botão se não estiver logado
    );
  }
}
