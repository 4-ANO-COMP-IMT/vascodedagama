import 'package:flutter/material.dart';

class PlayerStringWidget extends StatelessWidget {
  const PlayerStringWidget(
      {super.key,
      required this.type,
      required this.guessedString,
      required this.realString,
      this.iconUrl});

  final String? iconUrl;
  final String type;
  final String guessedString;
  final String realString;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        width: 275,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
          color: (guessedString == realString) ? Colors.green : Colors.red,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    guessedString,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconUrl != null
                      ? Image.network(iconUrl!)
                      : const SizedBox(height: 30),
                ],
              )
            ]));
  }
}
