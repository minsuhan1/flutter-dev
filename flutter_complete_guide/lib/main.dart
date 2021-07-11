import 'package:flutter/material.dart';
import './question.dart';

// void main() {
//   // Argument : MyApp Instance
//   runApp(MyApp());
// }

void main() => runApp(MyApp());

// Widget은 Object이다
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

// '_'를 앞에 붙이면 private class가 된다.
class _MyAppState extends State<MyApp> {
  var _questionIndex = 0;

  void _answerQuestion() {
    setState(() {
      _questionIndex = _questionIndex + 1;
    });
    print(_questionIndex);
  }

  @override
  Widget build(BuildContext context) {
    // list
    var questions = [
      'What\'s your favorite color?',
      'What\'s your favorite animal?'
    ];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My First App'),
        ),
        body: Column(
          // Invisible Widget
          children: [
            Question(questions[_questionIndex]),
            RaisedButton(onPressed: _answerQuestion, child: Text('Answer 1')),
            RaisedButton(
                // Anonymous Function
                onPressed: () => print('Answer 2 chosen!'),
                child: Text('Answer 2')),
            RaisedButton(
                onPressed: () {
                  // Anonymous Function
                  print('Answer 3 chosen!');
                },
                child: Text('Answer 3')),
          ],
        ),
      ),
    );
  }
} // Ctrl + Alt + L : auto code formatting
