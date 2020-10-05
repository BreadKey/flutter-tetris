import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/block.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/models/tetromino.dart';
import 'package:tetris/screens/block_renderer.dart';

class NextMinoRenderer extends StatelessWidget {
  final Tetris tetris;
  final tetrominoes = Map<TetrominoName, Tetromino>.fromEntries(TetrominoName
      .values
      .map((name) => MapEntry(name, Tetromino.from(name, Point(1, 2)))));

  NextMinoRenderer(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.black,
        child: StreamProvider<TetrominoName>.value(
          value: tetris.nextMinoStream,
          updateShouldNotify: (previous, current) => true,
          child: Consumer<TetrominoName>(
            builder: (context, name, child) {
              final nextMino = tetrominoes[name];

              final blockMap = Map<Point<int>, Block>.fromEntries(
                  (nextMino?.blocks ?? [])
                      .map((block) => MapEntry(block.point, block)));

              return GridView.count(
                key: ValueKey(nextMino),
                reverse: true,
                crossAxisCount: 4,
                children: List.generate(
                        4, (y) => List.generate(4, (x) => Point(x, y)))
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
              );
            },
          ),
        ),
      ));
}
