import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/tetris_screen/label_and_number_renderer.dart';

class ScoreboardRenderer extends StatelessWidget {
  final Tetris tetris;

  const ScoreboardRenderer(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 4/ 5,
        child: Material(
          color: neutralBlackC,
          elevation: 4,
          child: Column(
            children: [
              Expanded(
                  child: LabelAndNumberRenderer("Level", tetris.levelStream)),
              Expanded(
                  child: LabelAndNumberRenderer("Score", tetris.scoreStream))
            ],
          ),
        ),
      );
}
