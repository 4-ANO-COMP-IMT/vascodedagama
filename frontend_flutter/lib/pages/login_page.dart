import 'package:flutter/material.dart';
import 'package:frontend_flutter/app_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'seu@email.com',
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Senha',
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Usando o AppProvider para autenticação
                final appProvider = Provider.of<AppProvider>(context, listen: false);
                
                appProvider.login(
                  _emailController.text, 
                  _passwordController.text,
                ).then((success) {
                  if (success) {
                    // Login bem-sucedido, navega para a home
                    Navigator.pushReplacementNamed(context, '/');
                  } else {
                    // Exibindo mensagem de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erro ao fazer login')),
                    );
                  }
                });
              },
              child: const Text('Login'),
            ),
            // Add a button that navigates to the register page. The button is only a clickable text
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Não tem uma conta? Registre-se'),
            ),  
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        home: LoginPage(),
      ),
    ),
  );
}
