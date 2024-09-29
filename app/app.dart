import 'package:flutter/material.dart';
import 'package:wordli_clone/wordli/veiws/wordli_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Wordli App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const WordliScreen(),
    );
  }
}
