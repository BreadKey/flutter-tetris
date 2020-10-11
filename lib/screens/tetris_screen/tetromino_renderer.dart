import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/block_renderer.dart';

class TetrominoRenderer extends StatelessWidget {
  final TetrominoName name;
  final String info;
  final int rotateCount;

  const TetrominoRenderer(this.name, {Key key, this.info, this.rotateCount: 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 5 / 4,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tetromino =
                name == null ? null : Tetromino.spawn(name, Point(2, 2));
            for (int i = 0; i < rotateCount; i++) {
              tetromino?.rotate();
              if (i == 1) {
                tetromino?.move(Direction.up);
              } else if (i == 2) {
                tetromino?.move(Direction.right);
              }
            }
            final blockMap = Map<Point<int>, Block>.fromEntries(
                (tetromino?.blocks ?? [])
                    .map((block) => MapEntry(block.point, block)));

            final offsetX = name == TetrominoName.I || name == TetrominoName.O
                ? -constraints.maxWidth / 5 / 2
                : 0.0;

            final offsetY =
                name == TetrominoName.I ? -constraints.maxHeight / 4 / 2 : 0.0;

            return Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: GridView.count(
                key: ValueKey(tetromino),
                reverse: true,
                crossAxisCount: 5,
                children: List.generate(
                        4, (y) => List.generate(5, (x) => Point(x, y)))
                    .expand((element) => element)
                    .map((point) {
                  final block = blockMap[point];

                  return block == null
                      ? const SizedBox()
                      : BlockRenderer(
                          block,
                          key: ValueKey(block),
                        );
                }).toList(),
              ),
            );
          },
        ),
      );
}
