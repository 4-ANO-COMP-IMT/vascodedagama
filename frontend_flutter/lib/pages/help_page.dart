import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key, this.user}) : super(key: key);
  final String? user;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context); // Volta para a HomePage
          },
        ),
        title: const Text('Ajuda'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Adiciona SingleChildScrollView para rolagem
        child: Center(
          child: Padding( // Adiciona Padding para espaçamento
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Alinha os elementos ao centro horizontalmente
              children: [
                // Adiciona o conteúdo de "Como Jogar"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Alinha os elementos ao centro horizontalmente
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'Como Jogar',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'O Championsdle é um jogo que desafia você a adivinhar um jogador secreto de futebol. Você tem seis tentativas para descobrir quem é o jogador, usando as dicas fornecidas. Após cada palpite, você receberá dicas sobre os atributos do jogador.',
                      textAlign: TextAlign.center, // Alinha o texto ao centro
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Dicas:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return const ListTile(
                              leading: Icon(Icons.check, color: Colors.green),
                              title: Text('Verde: Significa que o atributo está correto.', textAlign: TextAlign.center),
                            );
                          case 1:
                            return const ListTile(
                              leading: Icon(Icons.close, color: Colors.red),
                              title: Text('Vermelho: Significa que o atributo está incorreto.', textAlign: TextAlign.center),
                            );
                          case 2:
                            return const ListTile(
                              leading: Icon(Icons.arrow_downward, color: Colors.red),
                              title: Text('Vermelho com seta para baixo (⬇️): Significa que o atributo é maior do que o do jogador secreto.', textAlign: TextAlign.center),
                            );
                          case 3:
                            return const ListTile(
                              leading: Icon(Icons.arrow_upward, color: Colors.red),
                              title: Text('Vermelho com seta para cima (⬆️): Significa que o atributo é menor do que o do jogador secreto.', textAlign: TextAlign.center),
                            );
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Volta para a HomePage;
                      },
                      child: const Text('Voltar ao jogo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}