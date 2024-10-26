import 'package:flutter/material.dart';
import 'package:frontend_flutter/app_provider.dart';
import 'package:frontend_flutter/pages/profile_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final bool isLoggedIn;
  final String? user;

  const HomePage({super.key, required this.isLoggedIn, this.user});

  @override
  _HomePageState createState() => _HomePageState(); // Certifique-se de que retorna um State<HomePage>
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Championsdle'),
        leading: IconButton(
          icon: appProvider.isLoggedIn
              ? const Icon(Icons.person, color: Colors.black)
              : const Icon(Icons.login, color: Colors.black),
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
      body: Center(
        child: appProvider.isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bem-vindo, ${appProvider.userEmail}!'),
                  const SizedBox(height: 10),
                  appProvider.secretPlayer != null
                      ? Column(
                          children: [
                            Text(
                              'Jogador secreto: ${appProvider.secretPlayer!['name']}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text('Altura: ${appProvider.secretPlayer!['height']} cm'),
                            Text('Time: ${appProvider.secretPlayer!['team']}'),
                            Text('Idade: ${appProvider.secretPlayer!['age']} anos'),
                            Text('Posição: ${appProvider.secretPlayer!['position']}'),
                            Text('Liga: ${appProvider.secretPlayer!['league']}'),
                            const SizedBox(height: 20),
                          ],
                        )
                      : const Text('Carregando jogador secreto...'),
                ],
              )
            : const Text('Faça login para acessar o conteúdo'),
      ),
      floatingActionButton: appProvider.isLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                await appProvider.loadNewSecretPlayer(); // Carregar um novo jogador secreto
                setState(() {}); // Atualizar a interface
              },
              tooltip: 'Novo Jogador Secreto',
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }
}
