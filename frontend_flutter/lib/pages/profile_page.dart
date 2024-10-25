import 'package:flutter/material.dart';
import 'package:frontend_flutter/app_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key, this.user}) : super(key: key);
  final String? user;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bem-vindo, ${user}'), // Exibe o email do usuário
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                  // Executa o logout via AppProvider
                appProvider.logout();
                // Redireciona para a página de login
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout'),
            ),
            // Adicione outras informações do perfil e opções de edição
            // como:
            // ElevatedButton(onPressed: () {}, child: Text('Alterar Nome')),
            // ElevatedButton(onPressed: () {}, child: Text('Alterar Senha')),
            // ...
          ],
        ),
      ),
    );
  }
}