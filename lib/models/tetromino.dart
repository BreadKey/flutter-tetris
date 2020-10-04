import 'dart:math';

import 'package:tetris/models/block.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/rules.dart';

enum TetrominoName { iMino, oMino, tMino, sMino, zMino, jMino, lMino }

abstract class Tetromino {
  final TetrominoName name;
  final List<Point<int>> downwardOffsets;
  Direction heading = Direction.down;
  final List<Block> blocks;
  Tetromino(this.name, this.downwardOffsets, Point<int> spawnPoint,
      {bool isGhost: false})
      : assert(downwardOffsets.length == 4),
        blocks = List.unmodifiable(List.generate(
            4,
            (index) => Block(
                color: tetriminoColors[name],
                point: spawnPoint + downwardOffsets[index],
                isGhost: isGhost)));

  factory Tetromino.from(TetrominoName name, Point<int> spawnPoint) {
    assert(name != null);

    switch (name) {
      case TetrominoName.iMino:
        return IMino(spawnPoint);
      case TetrominoName.oMino:
        return OMino(spawnPoint);
      case TetrominoName.tMino:
        return TMino(spawnPoint);
      case TetrominoName.sMino:
        return SMino(spawnPoint);
      case TetrominoName.zMino:
        return ZMino(spawnPoint);
      case TetrominoName.jMino:
        return JMino(spawnPoint);
      case TetrominoName.lMino:
        return LMino(spawnPoint);
    }
  }

  factory Tetromino.ghost() => _GhostMino();

  void move(Direction direction) {
    blocks.forEach((block) {
      block.point += direction.vector;
    });
  }

  Point<int> get center;

  Point<int> rotateOffset(Point<int> offset, Direction direction) {
    switch (direction) {
      case Direction.left:
        return Point(offset.y, -offset.x);

      case Direction.right:
        return Point(-offset.y, offset.x);

      case Direction.up:
        return Point(-offset.x, -offset.y);

      default:
        return offset;
    }
  }

  void rotate({bool clockwise: true}) {
    switch (heading) {
      case Direction.down:
        heading = clockwise ? Direction.left : Direction.right;
        break;
      case Direction.left:
        heading = clockwise ? Direction.up : Direction.down;
        break;
      case Direction.up:
        heading = clockwise ? Direction.right : Direction.left;
        break;
      case Direction.right:
        heading = clockwise ? Direction.down : Direction.up;
        break;
    }

    final rotatedPoints = downwardOffsets
        .map((offset) => center + rotateOffset(offset, heading))
        .toList();

    for (int index = 0; index < blocks.length; index++) {
      blocks[index].point = rotatedPoints[index];
    }
  }

  bool hasSamePoints(Tetromino other) {
    for (int index = 0; index < blocks.length; index++) {
      if (blocks[index].point != other.blocks[index].point) {
        return false;
      }
    }

    return true;
  }
}

///     Z
/// [0][1][2][3]
class IMino extends Tetromino {
  IMino(Point<int> spawnPoint)
      : super(
            TetrominoName.iMino,
            List.unmodifiable(
                [Point(-1, -1), Point(0, -1), Point(1, -1), Point(2, -1)]),
            spawnPoint) {
    _center = blocks[1].point + Point(0, 1);
  }

  Point<int> _center;
  @override
  Point<int> get center => _center;

  @override
  void move(Direction direction) {
    super.move(direction);
    _center += direction.vector;
  }

  @override
  void rotate({bool clockwise = true}) {
    super.rotate(clockwise: clockwise);

    switch (heading) {
      case Direction.left:
        blocks.forEach((block) {
          block.point += Point(1, 0);
        });
        break;

      case Direction.up:
        blocks.forEach((block) {
          block.point += Point(1, -1);
        });
        break;

      default:
        break;
    }
  }
}

/// [Z][1]
/// [2][3]
class OMino extends Tetromino {
  OMino(Point<int> spawnPoint)
      : super(
            TetrominoName.oMino,
            List.unmodifiable(
                [Point(0, 0), Point(1, 0), Point(0, -1), Point(1, -1)]),
            spawnPoint);

  @override
  Point<int> get center => blocks.first.point;

  @override
  Point<int> rotateOffset(Point<int> offset, Direction direction) => offset;
}

/// [0][Z][2]
///    [3]
class TMino extends Tetromino {
  TMino(Point<int> spawnPoint)
      : super(
            TetrominoName.tMino,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(1, 0), Point(0, -1)]),
            spawnPoint);

  @override
  Point<int> get center => blocks[1].point;
}

///    [Z][1]
/// [2][3]
class SMino extends Tetromino {
  SMino(Point<int> spawnPoint)
      : super(
            TetrominoName.sMino,
            List.unmodifiable(
                [Point(0, 0), Point(1, 0), Point(-1, -1), Point(0, -1)]),
            spawnPoint);

  @override
  Point<int> get center => blocks.first.point;
}

/// [0][Z]
///    [2][3]
class ZMino extends Tetromino {
  ZMino(Point<int> spawnPoint)
      : super(
            TetrominoName.zMino,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(0, -1), Point(1, -1)]),
            spawnPoint);

  @override
  Point<int> get center => blocks[1].point;
}

/// [0][Z][2]
///       [3]
class JMino extends Tetromino {
  JMino(Point<int> spawnPoint)
      : super(
            TetrominoName.jMino,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(1, 0), Point(1, -1)]),
            spawnPoint);

  @override
  Point<int> get center => blocks[1].point;
}

/// [0][Z][2]
/// [3]
class LMino extends Tetromino {
  LMino(Point<int> spawnPoint)
      : super(
            TetrominoName.lMino,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(1, 0), Point(-1, -1)]),
            spawnPoint);

  @override
  Point<int> get center => blocks[1].point;
}

class _GhostMino extends Tetromino {
  _GhostMino()
      : super(TetrominoName.tMino, List.generate(4, (index) => Point(0, 0)),
            Point(0, 0),
            isGhost: true);
  @override
  Point<int> get center => blocks.first.point;
}
