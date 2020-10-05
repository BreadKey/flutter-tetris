import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetromino.dart';

void main() {
  test("rotate L mino", () {
    final lMino = LMino(Point(0, 0));

    expect(lMino.heading, Direction.down);

    lMino.rotate();

    expect(lMino.heading, Direction.left);
    expectPoints(lMino, [Point(-1, 1), Point(0, 1), Point(0, 0), Point(0, -1)]);
  });

  test("rotate I mino", () {
    final iMino = IMino(Point(0, 0));

    expect(iMino.heading, Direction.down);
    expectPoints(
        iMino, [Point(-1, -1), Point(0, -1), Point(1, -1), Point(2, -1)]);

    iMino.rotate();

    expect(iMino.heading, Direction.left);
    expectPoints(iMino, [Point(0, 1), Point(0, 0), Point(0, -1), Point(0, -2)]);

    iMino.rotate();

    expect(iMino.heading, Direction.up);
    expectPoints(iMino, [Point(-1, 0), Point(0, 0), Point(1, 0), Point(2, 0)]);

    iMino.rotate();

    expect(iMino.heading, Direction.right);
    expectPoints(iMino, [Point(1, 1), Point(1, 0), Point(1, -1), Point(1, -2)]);

    iMino.rotate(clockwise: false);
    iMino.rotate(clockwise: false);
    iMino.rotate(clockwise: false);
    iMino.rotate(clockwise: false);

    expect(iMino.heading, Direction.right);
    expectPoints(iMino, [Point(1, 1), Point(1, 0), Point(1, -1), Point(1, -2)]);
  });
}

void expectPoints(Tetromino tetromino, Iterable<Point<int>> points) {
  final tetrominoPoints = tetromino.blocks.map((e) => e.point);

  points.forEach((point) {
    tetrominoPoints.contains(point);
  });
}
