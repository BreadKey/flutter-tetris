import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/tetris_screen/label_and_number_renderer.dart';

class ScoreboardRenderer extends StatelessWidget {
  final Tetris tetris;
  final Axis direction;

  const ScoreboardRenderer(this.tetris,
      {Key key, this.direction = Axis.horizontal})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: neutralBlackC,
        elevation: 4,
        child: Flex(
          direction: direction,
          children: [
            Expanded(
                child: LabelAndNumberRenderer(
              "Level",
              tetris.levelStream,
              direction: direction,
            )),
            Expanded(
                child: LabelAndNumberRenderer(
              "Score",
              tetris.scoreStream,
              direction: direction,
            ))
          ],
        ),
      );
}
