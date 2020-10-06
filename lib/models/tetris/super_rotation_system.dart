part of '../tetris.dart';

extension SuperRotationSystem on Tetris {
  static const testTable = {
    2: Point<int>(1, 0),
    3: Point<int>(1, -1),
    4: Point<int>(0, 2),
    5: Point<int>(1, 2)
  };

  bool rotateBySrs(Tetromino tetromino, List<List<Block>> playfield,
      {bool clockwise: true}) {
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

  bool kick(Tetromino tetromino, List<List<Block>> playfiled, bool clockwise) {
    bool kickSucceed = false;
    for (int testStep = 2; testStep <= 5; testStep++) {
      int x = testTable[testStep].x;
      int y = testTable[testStep].y;

      if (!clockwise) {
        x *= -1;
        y *= -1;
      }

      if (!tetromino.heading.isHorizontal) {
        x *= -1;
        y *= -1;
      }

      tetromino.moveDistance(Point<int>(x, y));

      if (isValidPosition(tetromino, playfield)) {
        kickSucceed = true;
        break;
      } else {
        tetromino.moveDistance(Point<int>(-x, -y));
      }
    }

    return kickSucceed;
  }

  bool isValidPosition(Tetromino tetromino, List<List<Block>> playfield) {
    for (Block block in tetromino.blocks) {
      if (isOutOfPlayfield(block.point)) return false;

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

  void rollback(Tetromino tetromino, Direction kickDirection, bool clockwise) {
    if (kickDirection != null) {
      tetromino.move(kickDirection.opposite);
    }

    tetromino.rotate(clockwise: !clockwise);
  }
}
