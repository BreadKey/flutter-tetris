import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/board.dart';
import 'package:tetris/screens/tetris_screen/tetromino_renderer.dart';

class HoldBoard extends StatelessWidget {
  final Tetris tetris;

  const HoldBoard(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Board(
        child: Stack(
          children: [
            StreamProvider.value(
                value: tetris.holdingMinoStream,
                child: Consumer<TetrominoName>(
                    builder: (context, holdingTetrominoName, _) =>
                        TetrominoRenderer(
                          holdingTetrominoName,
                          key: ValueKey(holdingTetrominoName),
                        ))),
            Align(
              alignment: Alignment.topLeft,
              child: Text(" Hold"),
            ),
          ],
        ),
      );
}
