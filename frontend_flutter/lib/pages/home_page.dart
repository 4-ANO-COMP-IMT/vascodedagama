import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  get isLoggedIn => widget.isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: isLoggedIn ? const Icon(Icons.person, color: Colors.white,) : const Icon(Icons.login, color: Colors.white,),
          onPressed: () {
            if (widget.isLoggedIn) {
              print('Profile');
              // Navigator.pushNamed(context, '/profile');
            } else {
              Navigator.pushNamed(context, '/login');
            }
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