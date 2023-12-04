import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/block_renderer.dart';

class TetrominoRenderer extends StatelessWidget {
  final TetrominoName? name;
  final String? info;
  final int rotateCount;
  final List<Direction>? kicks;
  final MaterialColor? color;

  const TetrominoRenderer(this.name,
      {Key? key, this.info, this.rotateCount = 0, this.kicks, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 5 / 4,
        child: Container(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tetromino =
                  name == null ? null : Tetromino.spawn(name!, Point(2, 2));
              for (int i = 0; i < rotateCount; i++) {
                tetromino?.rotate();
              }

              for (Direction kick in kicks ?? []) {
                tetromino?.move(kick);
              }

              final blockMap = Map<Point<int>?, Block>.fromEntries(
                  (tetromino?.blocks ?? [])
                      .map((block) => MapEntry(block.point, block)));

              final offsetX = name == TetrominoName.I || name == TetrominoName.O
                  ? -constraints.maxWidth / 5 / 2
                  : 0.0;

              final offsetY = name == TetrominoName.I
                  ? -constraints.maxHeight / 4 / 2
                  : 0.0;

              return Transform.translate(
                  offset: Offset(offsetX, offsetY),
                  child: Column(
                      verticalDirection: VerticalDirection.up,
                      children: List.generate(
                          4,
                          (y) => Expanded(
                                child: Row(
                                  children: [
                                    ...List.generate(5, (x) => Point(x, y))
                                        .map((point) {
                                      final block = blockMap[point];
                                      block?.color = color ?? block.color;

                                      return Expanded(
                                          child: block == null
                                              ? const SizedBox()
                                              : BlockRenderer(
                                                  block,
                                                  key: ValueKey(block),
                                                ));
                                    })
                                  ],
                                ),
                              ))));
            },
          ),
        ),
      );
}
