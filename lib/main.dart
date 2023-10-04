import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart' as english_words;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: Color.fromARGB(238, 244, 67, 54),
      fontWeight: FontWeight.w700,
      fontFamily: 'Poppins',
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                'Word Game',
                style: style.copyWith(fontSize: 40.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        body: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  void resetTimer() {
    setState(() {
      timer = 60;
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
        resetTimer();
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
      //showMessage("Computer played: $computerWord");
      resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.headlineSmall!.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );
    SizedBox(height: 20);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            enabled: false,
            style: style,
            //controller: controller,
            decoration: InputDecoration(
                labelText: "Computer's Word: $currentWord",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.all(10.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            style: style,
            enabled: true,
            controller: controller,
            decoration: InputDecoration(
                labelText: 'Enter a word',
                labelStyle: TextStyle(color: Colors.black45),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.all(10.0)),
          ),
        ),
        ElevatedButton(
          onPressed: checkWord,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.only(
                  left: 30.0, right: 30.0, top: 20.0, bottom: 20.0)),
          child: const Text(
            'Submit',
            style: TextStyle(
                fontSize: 20,
                fontFamily: "Poppins",
                color: Colors.black54,
                fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            message,
            style: const TextStyle(
                color: Colors.red, fontSize: 16, fontFamily: "Poppins"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "$timer s",
            style: const TextStyle(
                fontSize: 20,
                fontFamily: "Poppins",
                color: Colors.black54,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
