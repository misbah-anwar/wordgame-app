import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart' as english_words;
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w700,
      fontFamily: 'Poppins',
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Word Game', style: style),
        ),
        body: GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  TextEditingController controller = TextEditingController();
  List<String> words = [];
  String currentWord = "";
  String message = "";
  int timer = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    generateComputerWord();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (this.timer > 0) {
          this.timer--;
        } else {
          _timer.cancel();
          showMessage("Time's up!");
        }
      });
    });
  }

  void showMessage(String msg) {
    setState(() {
      message = msg;
    });
  }

  void checkWord() {
    String newWord = controller.text.toLowerCase();
    if (newWord.isNotEmpty) {
      if (words.contains(newWord)) {
        showMessage("Word already used!");
      } else if (currentWord.isNotEmpty &&
          currentWord[currentWord.length - 1] != newWord[0]) {
        showMessage("Invalid word!");
      } else if (!english_words.all.contains(newWord)) {
        showMessage("Not an English word!");
      } else {
        words.add(newWord);
        currentWord = newWord;
        controller.clear();
        showMessage("");
        generateComputerWord();
      }
    }
  }

  void generateComputerWord() {
    String lastChar = currentWord.isNotEmpty
        ? currentWord[currentWord.length - 1]
        : english_words.all[0][0];

    String computerWord = english_words.all.firstWhere(
        (word) =>
            word.toLowerCase().startsWith(lastChar.toLowerCase()) &&
            !words.contains(word.toLowerCase()),
        orElse: () => "No valid word found");

    if (computerWord == "No valid word found") {
      showMessage("Computer can't find a word!");
    } else {
      words.add(computerWord.toLowerCase());
      currentWord = computerWord.toLowerCase();
      showMessage("Computer played: $computerWord");
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.headlineMedium!.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontFamily: 'Poppins',
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Current Word: $currentWord",
            style: style,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Enter a word',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: checkWord,
          child: Text('Submit'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, padding: const EdgeInsets.all(25)),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            message,
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Time left: $timer seconds",
            style: TextStyle(
                fontSize: 20,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
