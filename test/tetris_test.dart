import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/block.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/models/tetromino.dart';

void main() {
  Tetris tetris;
  setUp(() {
    tetris = Tetris();
  });
  test("spawn I mino", () {
    tetris.spawn(TetrominoName.iMino);
  });

  test("point equals", () {
    expect(Point(1, 2), Point(1, 2));
  });
}
