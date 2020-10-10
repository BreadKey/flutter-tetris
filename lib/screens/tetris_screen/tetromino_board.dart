import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/block_renderer.dart';

import 'board.dart';

class TetrominoBoard extends StatelessWidget {
  static final tetrominoes = Map<TetrominoName, Tetromino>.fromEntries(
      TetrominoName.values
          .map((name) => MapEntry(name, Tetromino.spawn(name, Point(2, 2)))));
  final Stream<TetrominoName> minoStream;
  final String info;

  TetrominoBoard(this.minoStream, {Key key, this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) => AspectRatio(
      aspectRatio: 5 / 4,
      child: Board(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) =>
                    StreamProvider<TetrominoName>.value(
                  value: minoStream,
                  updateShouldNotify: (previous, current) => true,
                  child: Consumer<TetrominoName>(
                    builder: (context, name, child) {
                      final nextMino = tetrominoes[name];

                      final blockMap = Map<Point<int>, Block>.fromEntries(
                          (nextMino?.blocks ?? [])
                              .map((block) => MapEntry(block.point, block)));

                      final offsetX =
                          name == TetrominoName.I || name == TetrominoName.O
                              ? -constraints.maxWidth / 5 / 2
                              : 0.0;

                      final offsetY = name == TetrominoName.I
                          ? -constraints.maxHeight / 4 / 2
                          : 0.0;

                      return Transform.translate(
                        offset: Offset(offsetX, offsetY),
                        child: GridView.count(
                          key: ValueKey(nextMino),
                          reverse: true,
                          crossAxisCount: 5,
                          children: List.generate(4,
                                  (y) => List.generate(5, (x) => Point(x, y)))
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
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  " $info",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )));
}
