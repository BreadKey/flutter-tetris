import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/board.dart';
import 'package:tetris/screens/tetris_screen/tetromino_renderer.dart';

class HoldBoard extends StatelessWidget {
  const HoldBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Board(
        child: Stack(
          children: [
            Selector<Tetris, bool>(
                selector: (_, tetris) => tetris.canHold,
                builder: (_, canHold, __) => Selector<Tetris, TetrominoName?>(
                      selector: (_, tetris) => tetris.holdingMino,
                      builder: (_, holdingMino, __) => TetrominoRenderer(
                        holdingMino,
                        color: canHold ? null : Colors.grey,
                      ),
                    )),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                " Hold",
              ),
            ),
          ],
        ),
      );
}
