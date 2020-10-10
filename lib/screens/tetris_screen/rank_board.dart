import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/board.dart';

class RankBoard extends StatelessWidget {
  final Tetris tetris;

  const RankBoard(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Board(
        child: const SizedBox.expand(),
      );
}
