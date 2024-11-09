import 'package:flutter/material.dart';

class PlayerNameWidget extends StatelessWidget {
  const PlayerNameWidget(
      {super.key,
      this.iconUrl,
      required this.guessedName,
      required this.realName});

  final String? iconUrl;
  final String guessedName;
  final String realName;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        width: 275,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
          color: (guessedName == realName) ? Colors.green : Colors.red,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nome',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconUrl != null
                  ? Image.network(iconUrl!)
                  : const SizedBox(height: 120),
              Text(
                guessedName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            ]));
  }
}
