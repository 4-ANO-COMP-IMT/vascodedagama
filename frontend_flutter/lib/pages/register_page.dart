import 'package:flutter/material.dart';
import 'package:frontend_flutter/app_provider.dart';
import 'package:frontend_flutter/pages/home_page.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterPage({super.key});

  _handleRegister(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    appProvider
        .register(
      _emailController.text,
      _passwordController.text,
    )
        .then((success) {
      if (success) {
        appProvider
            .login(_emailController.text, _passwordController.text)
            .then((loginSuccess) {
          if (loginSuccess) {
            Navigator.pushReplacementNamed(context, '/');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Erro ao fazer login após o registro')),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registrar')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const HomePage(
                        isLoggedIn: false,
                      )),
            );
          },
        ),
        title: const Text('Registrar'),
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
              onEditingComplete: () => _handleRegister(context),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onEditingComplete: () => _handleRegister(context),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _handleRegister(context);
              },
              child: const Text('Registrar'),
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
        home: RegisterPage(),
      ),
    ),
  );
}
