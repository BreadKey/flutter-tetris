part of '../tetris.dart';

extension SuperRotationSystem on Tetris {
  static const testTable = {
    2: Point(-1, 0),
    3: Point(-1, 1),
    4: Point(0, -2),
    5: Point(-1, -2)
  };

  static const testTableI = {
    /// Clockwise
    true: {
      2: Point(-2, 0),
      3: Point(1, 0),
      4: Point(-2, -1),
      5: Point(1, 2),
    },
    false: {
      2: Point(1, 0),
      3: Point(-2, 0),
      4: Point(1, -2),
      5: Point(-2, 1),
    }
  };

  bool rotateBySrs(Tetromino tetromino, List<List<Block>> playfield,
      {bool clockwise: true}) {
    if (tetromino.name == TetrominoName.O) return false;

    tetromino.blocks.forEach((block) {
      playfield.setBlockAt(block.point, null);
    });

    tetromino.rotate(clockwise: clockwise);

    bool rotationSucceed = false;

    if (!isValidPosition(tetromino, playfield)) {
      rotationSucceed = kick(tetromino, playfield, clockwise);
    } else {
      rotationSucceed = true;
    }

    if (!rotationSucceed) {
      tetromino.rotate(clockwise: !clockwise);
    }

    tetromino.blocks.forEach((block) {
      playfield.setBlockAt(block.point, block);
    });

    return rotationSucceed;
  }

  bool kick(Tetromino tetromino, List<List<Block>> playfield, bool clockwise) {
    bool kickSucceed = false;
    for (int testStep = 2; testStep <= 5; testStep++) {
      final testOffset = getTestOffset(tetromino, testStep, clockwise);

      tetromino.moveDistance(testOffset);

      if (isValidPosition(tetromino, playfield)) {
        kickSucceed = true;
        break;
      } else {
        tetromino.moveDistance(Point(-testOffset.x, -testOffset.y));
      }
    }

    return kickSucceed;
  }

  Point<int> getTestOffset(Tetromino tetromino, int testStep, bool clockwise) {
    final testOffset = tetromino.name == TetrominoName.I
        ? testTableI[clockwise][testStep]
        : testTable[testStep];

    int x = testOffset.x;
    int y = testOffset.y;

    switch (tetromino.heading) {
      case Direction.right:
        break;
      case Direction.up:
        if (!clockwise) {
          x *= -1;
          y *= -1;
        } else {
          y *= -1;
        }
        break;
      case Direction.down:
        if (clockwise) {
          x *= -1;
          y *= -1;
        } else {
          y *= -1;
        }
        break;
      case Direction.left:
        x *= -1;
        break;
    }

    return Point(x, y);
  }

  bool isValidPosition(Tetromino tetromino, List<List<Block>> playfield) {
    for (Block block in tetromino.blocks) {
      if (playfield.isWall(block.point)) return false;

      final placedBlock = playfield.getBlockAt(block.point);
      if (!isBlockNullOrGhost(placedBlock)) {
        return false;
      }
    }

    return true;
  }

  Direction calculateKickDirection(Tetromino tetromino) {
    for (Block block in tetromino.blocks) {
      if (block.point.x == -1) {
        return Direction.right;
      } else if (block.point.x == playfieldWidth) {
        return Direction.left;
      } else if (block.point.y == -1) {
        return Direction.up;
      } else if (block.point.y == playfieldHeight) {
        return Direction.down;
      }
    }

    return null;
  }
}
