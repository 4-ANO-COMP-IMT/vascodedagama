import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/home_page.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  Future<bool> _login() async {
    // Implement login logic here
    String email = _emailController.text;
    String password = _passwordController.text;

    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final headers = {'Content-Type': 'application/json'};

    var response = await http.post(
      Uri.parse('http://localhost:3001/login'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
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
            // Navigate to the home page using a named route.
            // Navigator.pushNamed(context, '/');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(isLoggedIn: false,)));
          },
        ),
        title: const Text('Login'),
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
                // Handle login logic here
                String email = _emailController.text;
                String password = _passwordController.text;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(isLoggedIn: true,)));
                print('Email: $email, Senha: $password');
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
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}
