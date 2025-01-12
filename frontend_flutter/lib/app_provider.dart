import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// AppProvider: responsável por gerenciar o estado da aplicação
class AppProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  Map<String, dynamic>? _secretPlayer;
  int _highScore = 0;
  int _score = 0;
  List<Map<String, dynamic>> _players = []; // List to hold player data

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  Map<String, dynamic>? get secretPlayer => _secretPlayer;
  int get highScore => _highScore;
  int get score => _score;
  List<Map<String, dynamic>> get players => _players; // Expose the player list

  // Função para login
  Future<String?> login(String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return 'Preencha todos os campos';
  }

  final body = jsonEncode({'email': email, 'password': password});
  final headers = {'Content-Type': 'application/json'};

  var response = await http.post(
    Uri.parse('http://localhost:31245/login'), // 3001 Alterar o <NODE_PORT> se necessário
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    _isLoggedIn = true;
    _userEmail = email;
    _secretPlayer = data['secretPlayer'];
    await loadHighScore();
    await fetchPlayers();
    notifyListeners();
    return null; // Login bem-sucedido
  } else if (response.statusCode == 401) {
    return 'Senha incorreta';
  } else if (response.statusCode == 404) {
    return 'Usuário não encontrado';
  } else {
    return 'Erro ao fazer login. Tente novamente';
  }
}

  Future<String?> register(String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return 'Preencha todos os campos';
  }
  if (password.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    return 'Formato de e-mail inválido';
  }

  final body = jsonEncode({'email': email, 'password': password});
  final headers = {'Content-Type': 'application/json'};

  var response = await http.post(
    Uri.parse('http://localhost:31245/signup'), // 3001 Alterar o <NODE_PORT> se necessário
    headers: headers,
    body: body,
  );

  if (response.statusCode == 201) {
    var data = jsonDecode(response.body);
    _isLoggedIn = true;
    _userEmail = email;
    _secretPlayer = data['secretPlayer'];
    await loadHighScore();
    notifyListeners();
    return null; // Registro bem-sucedido
  } else if (response.statusCode == 409) {
    return 'Usuário já cadastrado';
  } else {
    return 'Erro ao registrar. Tente novamente';
  }
}

  // Função para logout
  Future<void> logout() async {
    await http.post(Uri.parse('http://localhost:31245/logout'));  // 3001 Alterar o PORT
    _isLoggedIn = false;
    _userEmail = null;
    _secretPlayer = null;
    notifyListeners();
  }

  // Carrega o highScore salvo para o usuário logado
  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('${_userEmail}_highScore') ?? 0;
    print('HighScore carregado: $_highScore');
    notifyListeners();
  }

  // Salva o highScore para o usuário logado
  Future<void> saveHighScore(int newHighScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_userEmail}_highScore', newHighScore);
    _highScore = newHighScore;
    print('HighScore salvo: $_highScore');
    _score = _highScore;
    notifyListeners();
  }

  // Reseta o score para o início de um novo jogo
  void resetScore() {
    _score = 0;
    notifyListeners();
  }

  // Fetch the player list from your backend
  Future<void> fetchPlayers() async {
    final url = Uri.parse('http://localhost:31448/players'); // 3002 Alterar o <NODE_PORT> se necessário
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
       _players = data.map((player) => { 
        'id': int.parse(player['id']),  
        'name': player['name'], 
        'icon': player['icon'],
        'height': int.parse(player['height']),
        'price': int.tryParse(player['price'].replaceAll('€', '').replaceAll('M', '').trim()) ?? 0 * 1000000, // Remove o símbolo € e converte
        'foot': player['foot'],
        'team': player['team'],
        'league': player['league'],
        'club_logo': player['club_logo'],
        'country': player['country'],
        'position': player['position'],
        'age': int.parse(player['age']),
      }).cast<Map<String, dynamic>>().toList();
      print('Players carregados: ${_players.length}');
      notifyListeners();
    } else {
      print('Erro ao carregar jogadores: ${response.statusCode}');
    }
  }

  Future<void> loadNewSecretPlayer() async {
  final url = Uri.parse('http://localhost:31448/secret-player'); // 3002 Alterar o <NODE_PORT> se necessário

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _secretPlayer = {
        'id': int.parse(data['id']),  
        'name': data['name'], 
        'icon': data['icon'],
        'height': int.parse(data['height']),
        'price': int.tryParse(data['price'].replaceAll('€', '').trim()) ?? 0, // Remove euro e espaços
        'foot': data['foot'],
        'team': data['team'],
        'league': data['league'],
        'club_logo': data['club_logo'],
        'country': data['country'],
        'position': data['position'],
        'age': int.parse(data['age']),
      }; // Armazena o jogador como um Mapa
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
