import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/home_page.dart';
import 'package:frontend_flutter/pages/login_page.dart';
import 'package:frontend_flutter/pages/register_page.dart';
import 'package:frontend_flutter/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
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
      initialRoute: '/',
      title: 'Flutter Demo',
      home: const HomePage(isLoggedIn: false),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile': (context) => ProfilePage(),
      },
      // theme of blue colors and white font
    );
  }
}