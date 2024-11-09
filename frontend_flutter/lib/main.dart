import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/help_page.dart';
import 'package:frontend_flutter/pages/home_page.dart';
import 'package:frontend_flutter/pages/login_page.dart';
import 'package:frontend_flutter/pages/register_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend_flutter/game_state.dart';
import 'app_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProxyProvider<AppProvider, GameState>(
          create: (_) => GameState(appProvider: AppProvider()),
          update: (_, appProvider, gameState) => GameState(appProvider: appProvider),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      title: 'Flutter Demo',
      home: const HomePage(isLoggedIn: false),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/help': (context) => const HelpPage(),
      },
      // theme of blue colors and white font
    );
  }
}