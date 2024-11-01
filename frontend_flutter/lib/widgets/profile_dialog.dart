import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  final String name;
  final int score;
  final VoidCallback onLogout;

  const ProfileDialog({
    super.key,
    required this.name,
    required this.score,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Profile'),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nome: $name'),
          const SizedBox(height: 8.0),
          Text('Pontuação: $score'),
          const SizedBox(height: 8.0),
          TextButton(onPressed: () {
            // Adicione a navegação para a página de perfil
            Navigator.pushNamed(context, '/profile');
          }, child: 
            const Text('Mais Detalhes'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Tem certeza que deseja sair?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: onLogout,
                      child: const Text('Sim'),
                    ),
                  ],
                );
              },
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('Logout'),
        ),

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
