import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/block_renderer.dart';
import 'package:tetris/screens/tetris_screen/tetromino_renderer.dart';

import 'board.dart';

class NextTetrominoBoard extends StatelessWidget {
  final Tetris tetris;

  NextTetrominoBoard(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      StreamProvider<List<TetrominoName>>.value(
          value: tetris.nextMinoBagStream,
          initialData: [],
          updateShouldNotify: (previous, current) => true,
          child: Consumer<List<TetrominoName>>(
              builder: (context, bag, child) => Column(
                      children: List.generate(5, (index) {
                    final nextMino = index >= bag.length ? null : bag[index];
                    return index == 0
                        ? Board(
                            child: Stack(children: [
                              TetrominoRenderer(nextMino),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(" Next"),
                              ),
                            ]),
                          )
                        : Transform.scale(
                            scale: 0.9,
                            alignment: Alignment.bottomLeft,
                            child: Board(
                              child: TetrominoRenderer(nextMino),
                            ));
                  }))));
}
