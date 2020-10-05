import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';

import 'tetromino_test.dart';

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

  test("roll back", () {
    tetris.spawn(TetrominoName.iMino);

    final kickDirection = Direction.left;
    final clockwise = false;

    tetris.currentTetromino.move(kickDirection);
    tetris.currentTetromino.rotate(clockwise: clockwise);

    tetris.rollback(tetris.currentTetromino, kickDirection, clockwise);

    expect(tetris.currentTetromino.heading, Direction.down);
    expectPoints(tetris.currentTetromino,
        [Point(3, 20), Point(4, 20), Point(5, 20), Point(6, 20)]);
  });
}
