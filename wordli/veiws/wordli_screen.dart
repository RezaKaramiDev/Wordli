import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:wordli_clone/app/app_colors.dart';
import 'package:wordli_clone/wordli/data/word_list.dart';
import 'package:wordli_clone/wordli/wordli.dart';

enum GameStatus { playing, submitting, lost, won }

class WordliScreen extends StatefulWidget {
  const WordliScreen({super.key});

  @override
  State<WordliScreen> createState() => _WordliScreenState();
}

class _WordliScreenState extends State<WordliScreen> {
  GameStatus _gameStatus = GameStatus.playing;

  final List<Word> _board = List.generate(
      6, (_) => Word(letters: List.generate(5, (_) => Letter.empty())));

  final List<List<GlobalKey<FlipCardState>>> _flipCardKeys = List.generate(
      6, (_) => List.generate(5, (_) => GlobalKey<FlipCardState>()));

  int _currentWordIndex = 0;
  Word? get _currentWord =>
      _currentWordIndex < _board.length ? _board[_currentWordIndex] : null;

  Word _solution = Word.fromString(
    fiveLetterWords[Random().nextInt(fiveLetterWords.length)].toUpperCase(),
  );

  final Set<Letter> _keyboardeLetters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Wordli',
          style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Board(board: _board, flipCardKeys: _flipCardKeys),
        const SizedBox(
          height: 80,
        ),
        Keyboard(
          onKeyTapped: _onKeyTapped,
          onDeleteTapped: _onDeleteTapped,
          onEnterTapped: _onEnterTapped,
          letters: _keyboardeLetters,
        ),
      ]),
    );
  }

  void _onKeyTapped(String val) {
    if (_gameStatus == GameStatus.playing) {
      setState(() => _currentWord?.addLetter(val));
    }
  }

  void _onDeleteTapped() {
    if (_gameStatus == GameStatus.playing) {
      setState(() => _currentWord?.removeLetter());
    }
  }

  Future<void> _onEnterTapped() async {
    if (_gameStatus == GameStatus.playing &&
        _currentWord != null &&
        !_currentWord!.letters.contains(Letter.empty())) {
      _gameStatus = GameStatus.submitting;

      for (var i = 0; i < _currentWord!.letters.length; i++) {
        final currentWordLetter = _currentWord!.letters[i];
        final currentSolutionLetter = _solution.letters[i];
        setState(() {
          if (currentWordLetter == currentSolutionLetter) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.correct);
          } else if (_solution.letters.contains(currentWordLetter)) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.inWord);
          } else {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.notInWord);
          }
        });
        final letter = _keyboardeLetters.firstWhere(
          (e) => e.val == currentWordLetter.val,
          orElse: () => Letter.empty(),
        );
        if (letter.status != LetterStatus.correct) {
          _keyboardeLetters.removeWhere((e) => e.val == currentWordLetter.val);
          _keyboardeLetters.add(_currentWord!.letters[i]);
        }

        await Future.delayed(
            const Duration(milliseconds: 150),
            () =>
                _flipCardKeys[_currentWordIndex][i].currentState?.toggleCard());
      }
      _checkIfWinOrLose();
    }
  }

  void _checkIfWinOrLose() {
    if (_currentWord!.wordString == _solution.wordString) {
      _gameStatus = GameStatus.won;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.none,
          duration: const Duration(days: 1),
          backgroundColor: correctColor,
          content: const Text(
            'You Won!',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'New Game',
            onPressed: _restart,
            textColor: Colors.white,
          ),
        ),
      );
    } else if (_currentWordIndex + 1 >= _board.length) {
      _gameStatus = GameStatus.lost;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        dismissDirection: DismissDirection.none,
        duration: const Duration(days: 1),
        backgroundColor: Colors.redAccent.shade200,
        content: Text(
          'You Lost! Solution: ${_solution.wordString}',
          style: const TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'New Game',
          onPressed: _restart,
          textColor: Colors.white,
        ),
      ));
    } else {
      _gameStatus = GameStatus.playing;
    }
    _currentWordIndex += 1;
  }

  void _restart() {
    setState(() {
      _gameStatus = GameStatus.playing;
      _currentWordIndex = 0;
      _board
        ..clear()
        ..addAll(
          List.generate(
            6,
            (_) => Word(
              letters: List.generate(5, (_) => Letter.empty()),
            ),
          ),
        );
      _solution = Word.fromString(
          fiveLetterWords[Random().nextInt(fiveLetterWords.length)]
              .toUpperCase());
      _flipCardKeys
        ..clear()
        ..addAll(
          List.generate(
              6, (_) => List.generate(5, (_) => GlobalKey<FlipCardState>())),
        );
      _keyboardeLetters.clear();
    });
  }
}
