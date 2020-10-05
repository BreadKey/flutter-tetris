import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/models/tetromino.dart';

void main() {
  Tetris tetris;
  setUp(() {
    tetris = Tetris();
    tetris.initPlayfield();
  });
  test("spawn I mino", () {
    tetris.spawn(TetrominoName.iMino);
  });

  test("point equals", () {
    expect(Point(1, 2), Point(1, 2));
  });

  test("can move", () {
    tetris.spawn(TetrominoName.iMino);

    expect(tetris.canMove(tetris.currentTetromino, Direction.down), true);

    tetris.move(Direction.down);

    tetris.spawn(TetrominoName.iMino);

    expect(tetris.canMove(tetris.currentTetromino, Direction.down), false);
  });
}
