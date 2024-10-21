import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/home_page.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterPage({super.key});

  Future<bool> _register() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    
    final body = jsonEncode({
      'email': email,
      'password': password,
    });
    final headers = {'Content-Type': 'application/json'};
    var response = await http.post(
      Uri.parse('http://localhost:3001/signup'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
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
                    builder: (context) => const HomePage(isLoggedIn: false)));
            // Navigator.pushNamed(context, '/');
          },
        ),
        title: const Text('Registrar'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _register().then((value) {
                  if (value) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const HomePage(isLoggedIn: true)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao registrar')));
                  }
                });
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
  runApp(MaterialApp(
    home: RegisterPage(),
  ));
}
