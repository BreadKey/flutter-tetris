import 'dart:math';

import 'package:flutter/material.dart';
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

  tearDown(() {
    tetris.dispose();
  });
  test("spawn I mino", () {
    tetris.spawn(TetrominoName.I);
    expectPoints(tetris.currentTetromino,
        [Point(3, 20), Point(4, 20), Point(5, 20), Point(6, 20)]);
  });

  test("spawn T mino", () {
    tetris.spawn(TetrominoName.T);

    expectPoints(tetris.currentTetromino,
        [Point(3, 20), Point(4, 20), Point(5, 20), Point(4, 21)]);
  });

  test("point equals", () {
    expect(Point(1, 2), Point(1, 2));
  });

  test("can move", () {
    tetris.spawn(TetrominoName.I);

    expect(tetris.canMove(tetris.currentTetromino, Direction.down), true);

    tetris.move(Direction.down);

    tetris.spawn(TetrominoName.I);

    expect(tetris.canMove(tetris.currentTetromino, Direction.down), false);
  });

  test("roll back", () {
    tetris.spawn(TetrominoName.I);

    final kickDirection = Direction.left;
    final clockwise = false;

    tetris.currentTetromino.move(kickDirection);
    tetris.currentTetromino.rotate(clockwise: clockwise);

    tetris.rollback(tetris.currentTetromino, kickDirection, clockwise);

    expect(tetris.currentTetromino.heading, Direction.down);
    expectPoints(tetris.currentTetromino,
        [Point(3, 20), Point(4, 20), Point(5, 20), Point(6, 20)]);
  });

  test("super rotation system", () {
    final mino = null; //just more readable;
    final grey = Block(color: Colors.grey);
    final playfield = [
      <Block>[null, null, null, null, grey, grey, null, null, null, null],
      <Block>[null, null, null, null, null, grey, grey, grey, null, null],
      <Block>[null, null, null, null, mino, null, grey, grey, grey, grey],
      <Block>[null, grey, grey, grey, mino, mino, mino, grey, grey, grey],
      <Block>[grey, grey, null, null, null, null, grey, grey, grey, grey],
      <Block>[grey, grey, grey, grey, null, null, grey, grey, grey, grey],
      <Block>[grey, grey, grey, grey, grey, null, grey, grey, grey, grey],
    ].reversed.toList();

    final jMino = Tetromino.from(TetrominoName.J, Point(5, 3));
    jMino.rotate();
    jMino.rotate();

    tetris.rotateBySrs(jMino, playfield, clockwise: false);

    expectPoints(jMino, [Point(4, 1), Point(5, 1), Point(5, 2), Point(5, 3)]);
  });
}
