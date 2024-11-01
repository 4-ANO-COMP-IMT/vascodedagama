import 'package:flutter/material.dart';

class PlayerNumberWidget extends StatelessWidget {
  const PlayerNumberWidget(
      {super.key,
      required this.type,
      required this.guessedNumber,
      required this.realNumber});

  final String type;
  final int guessedNumber;
  final int realNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        width: 200,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
          color: (guessedNumber == realNumber) ? Colors.green : Colors.red,
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
                    guessedNumber.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  guessedNumber == realNumber
                      ? const Icon(
                          Icons.check,
                          color: Colors.green,
                        )
                      : guessedNumber < realNumber
                          ? const Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 32,
                            )
                          : const Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                              size: 32,
                            ),
                ],
              )
            ]));
  }
}
