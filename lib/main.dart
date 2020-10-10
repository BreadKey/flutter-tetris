import 'package:flutter/material.dart';
import 'package:tetris/screens/tetris_screen.dart';

void main() {
  runApp(TetrisApp());
}

class TetrisApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "Pixel",),
      home: TetrisScreen(),
    );
  }
}
