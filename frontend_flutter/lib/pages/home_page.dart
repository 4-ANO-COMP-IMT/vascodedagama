import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/app_provider.dart';
import 'package:frontend_flutter/game_state.dart';
import 'package:frontend_flutter/pages/profile_page.dart';
import 'package:provider/provider.dart';

// Página principal do aplicativo, que exibe o jogo ou o conteúdo de login
class HomePage extends StatefulWidget {
  final bool isLoggedIn; // Indica se o usuário está logado
  final String? user; // Guarda o nome do usuário, se disponível

  const HomePage({super.key, required this.isLoggedIn, this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _guessController = TextEditingController(); // Controlador para o campo de texto de palpites
  Timer? _debounce; // Temporizador para debounce no campo de texto
  bool _isCorrectGuess = false; // Indica se o último palpite foi correto
  late AnimationController _animationController; // Controlador para animações de feedback visual

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
  }

  @override
  void dispose() {
    // Libera o controlador de texto e o controlador de animação ao encerrar a página
    _guessController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Método que retorna a cor de validação (verde para correto, vermelho para incorreto)
  Color _getValidationColor(bool isCorrect) => isCorrect ? Colors.green : Colors.red;

  // Executa uma animação de feedback visual quando o palpite está certo ou errado
  void _showResultAnimation(bool isCorrect) {
    setState(() => _isCorrectGuess = isCorrect);
    _animationController.forward(from: 0.0); // Inicia a animação
  }

  // Widget de comparação para um atributo (ex: altura, idade), indicando se é igual, maior ou menor
  Widget getComparisonWidget(String label, dynamic guessedValue, dynamic secretValue) {
    IconData icon;
    int? guessedNum = guessedValue is String ? int.tryParse(guessedValue) : guessedValue;
    int? secretNum = secretValue is String ? int.tryParse(secretValue) : secretValue;

    bool isCorrect = guessedNum == secretNum; // Verifica se os valores coincidem
    icon = isCorrect ? Icons.check : (guessedNum! < secretNum! ? Icons.arrow_upward : Icons.arrow_downward);

    return Row(
      children: [
        Text('$label: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getValidationColor(isCorrect))),
        Icon(icon, size: 18, color: _getValidationColor(isCorrect)),
      ],
    );
  }

  // Widget para validação de atributos iguais (ex: time, país, posição)
  Widget getValidationWidget(String label, dynamic guessedValue, dynamic secretValue) {
    bool isCorrect = guessedValue == secretValue; // Verifica se os valores coincidem
    IconData icon = isCorrect ? Icons.check : Icons.close;

    return Row(
      children: [
        Text('$label: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getValidationColor(isCorrect))),
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
        title: const Text('Championsdle'),
        // Botão de perfil ou login
        leading: IconButton(
          icon: appProvider.isLoggedIn ? const Icon(Icons.person, color: Colors.black) : const Icon(Icons.login, color: Colors.black),
          onPressed: () {
            if (appProvider.isLoggedIn) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: appProvider.userEmail),
                ),
              );
            } else {
              Navigator.pushNamed(context, '/login');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: appProvider.isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Tentativas: ${gameState.attempts}/5'), // Contador de tentativas
                  Text('Score: ${gameState.score}'), // Exibe o score
                  Text('Recorde: ${gameState.highScore}'), // Exibe o recorde
                  const SizedBox(height: 20),
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
                                      controller: _guessController,
                                      onChanged: (text) {
                                        // Debounce para limitar a quantidade de chamadas ao digitar
                                        _debounce?.cancel();
                                        _debounce = Timer(const Duration(milliseconds: 300), () {
                                          setState(() {
                                            gameState.guessedPlayer = null;
                                            _guessController.text = text;
                                            // Sugestões de jogadores ao digitar
                                            gameState.suggestions = appProvider.players
                                                .where((player) => player['name'].toLowerCase().contains(text.toLowerCase()))
                                                .toList();
                                          });
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Adivinhe o nome do jogador secreto',
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
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
                                        color: _isCorrectGuess ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Lista de sugestões de jogadores baseada na entrada de texto
                                  Container(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: gameState.suggestions.length,
                                      itemBuilder: (context, index) {
                                        final player = gameState.suggestions[index];
                                        return ListTile(
                                          title: Text(player['name']),
                                          onTap: () {
                                            setState(() {
                                              // Atualiza o texto e verifica o palpite
                                              _guessController.text = player['name'];
                                              gameState.guessedPlayer = player;
                                              gameState.suggestions = [];
                                              _guessController.clear();
                                            });
                                            gameState.checkGuess(player['id'], appProvider.secretPlayer!['id']);
                                            _showResultAnimation(gameState.isGuessCorrect);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Histórico de palpites do jogador
                                  gameState.guessHistory.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Histórico de Palpites:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            Container(
                                              height: 300,
                                              child: ListView.builder(
                                                reverse: false,
                                                itemCount: gameState.guessHistory.length,
                                                itemBuilder: (context, index) {
                                                  final guess = gameState.guessHistory[gameState.guessHistory.length - 1 - index];
                                                  return Card(
                                                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                    child: ListTile(
                                                      leading: guess.player.name == appProvider.secretPlayer!['name']
                                                          ? Icon(Icons.check, color: Colors.green)
                                                          : Icon(Icons.close, color: Colors.red),
                                                      title: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(guess.player.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                          getComparisonWidget('Altura', guess.player.height, appProvider.secretPlayer!['height']),
                                                          getValidationWidget('Time', guess.player.team, appProvider.secretPlayer!['team']),
                                                          getValidationWidget('País', guess.player.country, appProvider.secretPlayer!['country']),
                                                          getComparisonWidget('Idade', guess.player.age, appProvider.secretPlayer!['age']),
                                                          getValidationWidget('Pé', guess.player.foot, appProvider.secretPlayer!['foot']),
                                                          getValidationWidget('Posição', guess.player.position, appProvider.secretPlayer!['position']),
                                                          getValidationWidget('Liga', guess.player.league, appProvider.secretPlayer!['league']),
                                                        ],
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
                            Expanded(
                              flex: 2,
                              child: gameState.guessedPlayer != null
                                  ? Column(
                                      children: [
                                        Text('Jogador secreto: ${appProvider.secretPlayer!['name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        getComparisonWidget('Altura', gameState.guessedPlayer!['height'], appProvider.secretPlayer!['height']),
                                        getValidationWidget('Time', gameState.guessedPlayer!['team'], appProvider.secretPlayer!['team']),
                                        getValidationWidget('País', gameState.guessedPlayer!['country'], appProvider.secretPlayer!['country']),
                                        getComparisonWidget('Idade', gameState.guessedPlayer!['age'], appProvider.secretPlayer!['age']),
                                        getValidationWidget('Pé', gameState.guessedPlayer!['foot'], appProvider.secretPlayer!['foot']),
                                        getValidationWidget('Posição', gameState.guessedPlayer!['position'], appProvider.secretPlayer!['position']),
                                        getValidationWidget('Liga', gameState.guessedPlayer!['league'], appProvider.secretPlayer!['league']),
                                      ],
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        )
                      : const Text('Carregando jogador secreto...'),
                ],
              )
            : const Text('Faça login para acessar o conteúdo'), // Mensagem se não estiver logado
      ),
      // Botão flutuante para carregar um novo jogador secreto
      floatingActionButton: appProvider.isLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                await appProvider.loadNewSecretPlayer(); // Carrega um novo jogador secreto
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
