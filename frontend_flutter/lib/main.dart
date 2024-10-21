import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/home_page.dart';
import 'package:frontend_flutter/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      title: 'Flutter Demo',
      home: const HomePage(),
      routes: {
        '/login': (context) => LoginPage(),
      },
      // theme of blue colors and white font
    );
  }
}