import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.login, color: Colors.white,),
          onPressed: () {
            // Navigate to the login page using a named route.
            Navigator.pushNamed(context, '/login');
          },
        ),
        title: const Text('Championsdle', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [IconButton(
            icon: const Icon(Icons.help, color: Colors.white,),
            onPressed: () {},
          )],
        backgroundColor: Colors.blue,
      ),
    );
  }
}