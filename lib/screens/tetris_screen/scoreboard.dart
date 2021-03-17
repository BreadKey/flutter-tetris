import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/board.dart';
import 'package:tetris/screens/tetris_screen/label_and_number_renderer.dart';

class Scoreboard extends StatelessWidget {
  final Tetris tetris;
  final Axis direction;

  const Scoreboard(this.tetris,
      {Key key, this.direction = Axis.horizontal})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Board(
        child: Flex(
          direction: direction,
          children: [
            Expanded(
                child: LabelAndNumberRenderer(
              "Level",
              (tetris) => tetris.level,
              direction: direction,
            )),
            Expanded(
                child: LabelAndNumberRenderer(
              "Score",
              (tetris) => tetris.score,
              direction: direction,
            ))
          ],
        ),
      );
}
