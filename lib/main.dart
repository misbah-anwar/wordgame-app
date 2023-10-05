import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart' as english_words;
import 'dart:async';
import 'dart:math';
import 'Strings.dart';

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
          backgroundColor: Colors.white,
          toolbarHeight: 100,
          flexibleSpace: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 50.0),
            child: Text(
              'Word Game',
              style: style.copyWith(fontSize: 40.0),
              textAlign: TextAlign.center,
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
  bool isEnded = false;
  String start = "Start Game";
  String end = "End Game";
  bool _showWordsList = false;
  late FocusNode _focusNode;

  void _toggleWordsList() {
    setState(() {
      _showWordsList = !_showWordsList;
    });
  }

  void _toggleGameButtonLabel() {
    setState(() {
      if (isEnded) {
        start = "Start Game";
      } else {
        start = "End Game";
      }
    });
  }

  void startGame() {
    setState(() {
      words.clear();
      currentWord = "";
      message = "";
      timer = 60;
      isEnded = false;
      startTimer();
      generateComputerWord();
      _toggleWordsList();
      _toggleGameButtonLabel();
      resetTimer();
      _focusNode.requestFocus();
    });
  }

  void endGame() {
    _timer.cancel();
    setState(() {
      isEnded = true;
      _toggleWordsList();
      _toggleGameButtonLabel();
      _focusNode.unfocus(); // Close the keypad
    });
  }

  Widget buildWordsList() {
    if (_showWordsList && isEnded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              words.join(', '),
              style: const TextStyle(
                fontSize: 20,
                fontFamily: "Poppins",
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    generateComputerWord();
    _focusNode = FocusNode();
  }

  void toggleGame() {
    setState(() {
      isEnded = !isEnded;
      if (!isEnded) {
        startGame();
      } else {
        endGame();
      }
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (this.timer > 0) {
          this.timer--;
        } else {
          _timer.cancel();
          showMessage(timeUp);
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
        showMessage(wordAlreadyUsed);
      } else if (currentWord.isNotEmpty &&
          currentWord[currentWord.length - 1] != newWord[0]) {
        showMessage(noValidWordFound);
      } else if (!english_words.all.contains(newWord)) {
        showMessage(notEnglish);
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
        : english_words.all[Random().nextInt(english_words.all.length)][0];

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
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
          child: TextField(
            enabled: false,
            style: style,
            decoration: InputDecoration(
                labelText: "$currentWord",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.all(10.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, top: 20.0, bottom: 60.0),
          child: TextField(
            focusNode: _focusNode, // Assign the focus node here
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: checkWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 10, bottom: 10),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Poppins",
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: toggleGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnded ? Colors.lightBlue : Colors.red,
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
              ),
              child: Text(
                isEnded ? start : end,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: "Poppins",
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontFamily: "Poppins",
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "$timer s",
            style: const TextStyle(
                fontSize: 20,
                fontFamily: "Poppins",
                color: Colors.black54,
                fontWeight: FontWeight.w500),
          ),
        ),
        buildWordsList(),
      ],
    );
  }
}
