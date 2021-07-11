import 'package:flutter/material.dart';

class Question extends StatelessWidget {
  final String questionText; // cannot change after initialized

  Question(this.questionText);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Container takes the full width of the screen.
      margin: EdgeInsets.all(10),
      child: Text(
        questionText,
        style: TextStyle(fontSize: 28),
        textAlign: TextAlign.center, // Enum
      ),
    );
  }
}
