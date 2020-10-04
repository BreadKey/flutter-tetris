import 'dart:math';

import 'package:tetris/models/block.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/rules.dart';

enum TetrominoName { iMino, oMino, tMino, sMino, zMino, jMino, lMino }

abstract class Tetromino {
  final TetrominoName name;
  final Iterable<Point<int>> downwardOffsets;
  Direction heading;
  final Iterable<Block> blocks;
  Tetromino(this.name, this.downwardOffsets)
      : assert(downwardOffsets.length == 4),
        blocks =
            List.generate(4, (index) => Block(color: tetriminoColors[name]));

  factory Tetromino.from(TetrominoName name) {
    assert(name != null);

    switch (name) {
      case TetrominoName.iMino:
        return IMino();
      case TetrominoName.oMino:
        return OMino();
      case TetrominoName.tMino:
        return TMino();
      case TetrominoName.sMino:
        return SMino();
      case TetrominoName.zMino:
        return ZMino();
      case TetrominoName.jMino:
        return JMino();
      case TetrominoName.lMino:
        return LMino();
    }
  }

  void spawn(Point<int> spawnPoint) {
    heading = Direction.down;

    final blockIterator = blocks.iterator;
    final offsetIterator = downwardOffsets.iterator;

    while (blockIterator.moveNext()) {
      offsetIterator.moveNext();

      blockIterator.current.point = spawnPoint + offsetIterator.current;
    }
  }

  void move(Direction direction) {
    blocks.forEach((block) {
      block.point += direction.vector;
    });
  }
}

///     Z
/// [0][1][2][3]
class IMino extends Tetromino {
  IMino()
      : super(TetrominoName.iMino,
            [Point(-1, -1), Point(0, -1), Point(1, -1), Point(2, -1)]);
}

/// [Z][1]
/// [2][3]
class OMino extends Tetromino {
  OMino()
      : super(TetrominoName.oMino,
            [Point(0, 0), Point(1, 0), Point(0, -1), Point(1, -1)]);
}

/// [0][Z][2]
///    [3]
class TMino extends Tetromino {
  TMino()
      : super(TetrominoName.tMino,
            [Point(-1, 0), Point(0, 0), Point(1, 0), Point(0, -1)]);
}

///    [Z][1]
/// [2][3]
class SMino extends Tetromino {
  SMino()
      : super(TetrominoName.sMino,
            [Point(0, 0), Point(1, 0), Point(-1, -1), Point(0, -1)]);
}

/// [0][Z]
///    [2][3]
class ZMino extends Tetromino {
  ZMino()
      : super(
            TetrominoName.zMino,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(0, -1), Point(1, -1)]));
}

/// [0][Z][2]
///       [3]
class JMino extends Tetromino {
  JMino()
      : super(TetrominoName.jMino,
            [Point(-1, 0), Point(0, 0), Point(1, 0), Point(1, -1)]);
}

/// [0][Z][2]
/// [3]
class LMino extends Tetromino {
  LMino()
      : super(TetrominoName.lMino,
            [Point(-1, 0), Point(0, 0), Point(1, 0), Point(-1, -1)]);
}
