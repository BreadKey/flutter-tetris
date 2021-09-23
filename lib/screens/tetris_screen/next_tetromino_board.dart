import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/tetromino_renderer.dart';

import 'board.dart';

class NextTetrominoBoard extends StatelessWidget {
  const NextTetrominoBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Selector<Tetris, List<TetrominoName>>(
      selector: (_, tetris) => tetris.nextMinoBag,
      builder: (context, bag, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(5, (index) {
            final nextMino = index >= bag.length ? null : bag[index];
            return index == 0
                ? AspectRatio(
                    aspectRatio: 5 / 4,
                    child: Board(
                      child: Stack(children: [
                        TetrominoRenderer(nextMino),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(" Next"),
                        ),
                      ]),
                    ),
                  )
                : Expanded(
                    child: Transform.scale(
                        scale: 0.9,
                        alignment: Alignment.bottomLeft,
                        child: Board(
                          child: TetrominoRenderer(nextMino),
                        )));
          })));
}
