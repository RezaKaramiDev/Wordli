import 'package:equatable/equatable.dart';
import 'package:wordli_clone/wordli/wordli.dart';

class Word extends Equatable {
  final List<Letter> letters;

  const Word({required this.letters});

  factory Word.fromString(String word) =>
      Word(letters: word.split('').map((e) => Letter(val: e)).toList());

  String get wordString => letters.map((e) => e.val).join();

  void addLetter(String val) {
    final currentIndex = letters.indexWhere((e) => e.val.isEmpty);
    if (currentIndex != -1) {
      letters[currentIndex] = Letter(val: val);
    }
  }

  void removeLetter() {
    final recentLetterindex = letters.lastIndexWhere((e) => e.val.isNotEmpty);
    if (recentLetterindex != -1) {
      letters[recentLetterindex] = Letter.empty();
    }
  }

  @override
  List<Object?> get props => [letters];
}
