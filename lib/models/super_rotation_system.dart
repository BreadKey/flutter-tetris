part of 'tetris.dart';

extension SuperRotationSystem on Tetris {
  bool rotateBySrs(Tetromino tetromino, List<List<Block>> playfield,
      {bool clockwise: true}) {
    tetromino.blocks.forEach((block) {
      playfield.setBlockAt(block.point, null);
    });

    tetromino.rotate(clockwise: clockwise);

    Direction kickDirection = calculateKickDirection(tetromino);

    if (kickDirection != null) {
      tetromino.move(kickDirection);
    }

    final rotationSucceed = isValidRotation(tetromino, playfield);

    if (!rotationSucceed) {
      rollback(tetromino, kickDirection, clockwise);
    }

    tetromino.blocks.forEach((block) {
      playfield.setBlockAt(block.point, block);
    });

    return rotationSucceed;
  }

  bool isValidRotation(Tetromino tetromino, List<List<Block>> playfield) {
    for (Block block in tetromino.blocks) {
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
