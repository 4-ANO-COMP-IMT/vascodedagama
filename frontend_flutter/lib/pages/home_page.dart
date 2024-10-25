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

// A classe _HomePageState deve herdar de State<HomePage>
class _HomePageState extends State<HomePage> {  
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Championsdle'),
        leading: IconButton(
          icon: appProvider.isLoggedIn ? const Icon(Icons.person, color: Colors.black,) : const Icon(Icons.login, color: Colors.white,),
          onPressed: () {
            if (appProvider.isLoggedIn) {
              print('Profile');
              Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => ProfilePage(user: appProvider.userEmail)));
            } else {
              Navigator.pushNamed(context, '/login');
            }
          },
        ),
      ),
      body: Center(
        child: appProvider.isLoggedIn
            ? Text('Bem-vindo, ${appProvider.userEmail} jogador:${appProvider.secretPlayer}')
            : const Text('Faça login para acessar o conteúdo'),
      ),
    );
  }
}
