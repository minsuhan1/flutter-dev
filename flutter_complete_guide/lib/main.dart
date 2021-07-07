import 'package:flutter/material.dart';

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
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  var questionIndex = 0;

  void answerQuestion() {
    setState(() {
      questionIndex = questionIndex + 1;
    });
    print(questionIndex);
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
            Text(questions[questionIndex]),
            ElevatedButton(onPressed: answerQuestion, child: Text('Answer 1')),
            ElevatedButton(
                // Anonymous Function
                onPressed: () => print('Answer 2 chosen!'),
                child: Text('Answer 2')),
            ElevatedButton(
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
