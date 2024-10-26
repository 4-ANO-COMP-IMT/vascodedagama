import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// AppProvider: responsável por gerenciar o estado da aplicação
class AppProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  Map<String, dynamic>? _secretPlayer;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  Map<String, dynamic>? get secretPlayer => _secretPlayer;

  // Função para login
  Future<bool> login(String email, String password) async {
    final body = jsonEncode({'email': email, 'password': password});
    final headers = {'Content-Type': 'application/json'};

    var response = await http.post(
      Uri.parse('http://localhost:3001/login'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      _isLoggedIn = true;
      _userEmail = email;
      _secretPlayer = data['secretPlayer'];
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  // Função para registro
  Future<bool> register(String email, String password) async {
    final body = jsonEncode({'email': email, 'password': password});
    final headers = {'Content-Type': 'application/json'};

    var response = await http.post(
      Uri.parse('http://localhost:3001/signup'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      _isLoggedIn = true;
      _userEmail = email;
      _secretPlayer = data['secretPlayer'];
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  // Função para logout
  Future<void> logout() async {
    await http.post(Uri.parse('http://localhost:3001/logout'));
    _isLoggedIn = false;
    _userEmail = null;
    _secretPlayer = null;
    notifyListeners();
  }

  Future<void> loadNewSecretPlayer() async {
    final url = Uri.parse('http://localhost:3002/secret-player');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _secretPlayer = data; // Armazena o jogador completo
        notifyListeners();
      } else if (response.statusCode == 404) {
        _secretPlayer = {'error': 'Nenhum jogador disponível'};
        notifyListeners();
      } else {
        throw Exception('Falha ao carregar o jogador secreto');
      }
    } catch (e) {
      print('Erro ao carregar o jogador secreto: $e');
      _secretPlayer = {'error': 'Erro ao carregar jogador'};
      notifyListeners();
    }
  }
}
