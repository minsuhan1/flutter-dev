import 'package:flutter/material.dart';

// void main() {
//   // Argument : MyApp Instance
//   runApp(MyApp());
// }

void main() => runApp(MyApp());

// Widget은 Object이다
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Text('Hello!'),);
  }
}