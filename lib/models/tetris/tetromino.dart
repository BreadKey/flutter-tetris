part of tetris;

enum TetrominoName { I, O, T, S, Z, J, L }

abstract class Tetromino {
  final TetrominoName name;
  final List<Point<int>> downwardOffsets;

  Direction _heading = Direction.down;
  Direction get heading => _heading;

  final List<Block> blocks;
  Tetromino(this.name, this.downwardOffsets, Point<int> spawnPoint,
      {bool isGhost: false})
      : assert(downwardOffsets.length == 4),
        blocks = List.unmodifiable(List.generate(
            4,
            (index) => Block(
                color: kTetriminoColors[name]!,
                point: spawnPoint + downwardOffsets[index],
                isGhost: isGhost)));

  factory Tetromino.spawn(TetrominoName name, Point<int> spawnPoint) {
    late Tetromino tetromino;

    switch (name) {
      case TetrominoName.I:
        tetromino = IMino(spawnPoint);
        break;
      case TetrominoName.O:
        tetromino = OMino(spawnPoint);
        break;
      case TetrominoName.T:
        tetromino = TMino(spawnPoint);
        break;
      case TetrominoName.S:
        tetromino = SMino(spawnPoint);
        break;
      case TetrominoName.Z:
        tetromino = ZMino(spawnPoint);
        break;
      case TetrominoName.J:
        tetromino = JMino(spawnPoint);
        break;
      case TetrominoName.L:
        tetromino = LMino(spawnPoint);
        break;
    }

    switch (name) {
      case TetrominoName.J:
      case TetrominoName.L:
      case TetrominoName.T:
        tetromino.rotate();
        tetromino.rotate();
        tetromino.move(Direction.down);
        break;
      default:
        break;
    }

    return tetromino;
  }

  factory Tetromino.ghost() => _GhostMino();

  void move(Direction direction) {
    moveDistance(direction.vector);
  }

  void moveDistance(Point<int> distance) {
    blocks.forEach((block) {
      block.point += distance;
    });
  }

  Point<int>? get center;

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
    switch (_heading) {
      case Direction.down:
        _heading = clockwise ? Direction.left : Direction.right;
        break;
      case Direction.left:
        _heading = clockwise ? Direction.up : Direction.down;
        break;
      case Direction.up:
        _heading = clockwise ? Direction.right : Direction.left;
        break;
      case Direction.right:
        _heading = clockwise ? Direction.down : Direction.up;
        break;
    }

    final rotatedPoints = downwardOffsets
        .map((offset) => center! + rotateOffset(offset, heading))
        .toList();

    for (int index = 0; index < blocks.length; index++) {
      blocks[index].point = rotatedPoints[index];
    }
  }
}

///     Z
/// [0][1][2][3]
class IMino extends Tetromino {
  IMino(Point<int> spawnPoint)
      : super(
            TetrominoName.I,
            List.unmodifiable(
                [Point(-1, -1), Point(0, -1), Point(1, -1), Point(2, -1)]),
            spawnPoint) {
    _center = blocks[1].point + Point(0, 1);
  }

  late Point<int> _center;
  @override
  Point<int> get center => _center;

  @override
  void moveDistance(Point<int> distance) {
    super.moveDistance(distance);
    _center += distance;
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

      case Direction.right:
        blocks.forEach((block) {
          block.point += Point(0, -1);
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
            TetrominoName.O,
            List.unmodifiable(
                [Point(0, 0), Point(1, 0), Point(0, -1), Point(1, -1)]),
            spawnPoint);

  @override
  Point<int>? get center => blocks.first.point;

  @override
  Point<int> rotateOffset(Point<int> offset, Direction direction) => offset;
}

/// [0][Z][2]
///    [3]
class TMino extends Tetromino {
  TMino(Point<int> spawnPoint)
      : super(
            TetrominoName.T,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(1, 0), Point(0, -1)]),
            spawnPoint);

  @override
  Point<int>? get center => blocks[1].point;
}

///    [Z][1]
/// [2][3]
class SMino extends Tetromino {
  SMino(Point<int> spawnPoint)
      : super(
            TetrominoName.S,
            List.unmodifiable(
                [Point(0, 0), Point(1, 0), Point(-1, -1), Point(0, -1)]),
            spawnPoint);

  @override
  Point<int>? get center => blocks.first.point;
}

/// [0][Z]
///    [2][3]
class ZMino extends Tetromino {
  ZMino(Point<int> spawnPoint)
      : super(
            TetrominoName.Z,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(0, -1), Point(1, -1)]),
            spawnPoint);

  @override
  Point<int>? get center => blocks[1].point;
}

/// [0][Z][2]
///       [3]
class JMino extends Tetromino {
  JMino(Point<int> spawnPoint)
      : super(
            TetrominoName.J,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(1, 0), Point(1, -1)]),
            spawnPoint);

  @override
  Point<int>? get center => blocks[1].point;
}

/// [0][Z][2]
/// [3]
class LMino extends Tetromino {
  LMino(Point<int> spawnPoint)
      : super(
            TetrominoName.L,
            List.unmodifiable(
                [Point(-1, 0), Point(0, 0), Point(1, 0), Point(-1, -1)]),
            spawnPoint);

  @override
  Point<int>? get center => blocks[1].point;
}

class _GhostMino extends Tetromino {
  _GhostMino()
      : super(TetrominoName.T, List.generate(4, (index) => Point(0, 0)),
            Point(0, 0),
            isGhost: true);
  @override
  Point<int>? get center => blocks.first.point;
}
