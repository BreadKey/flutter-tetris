part of 'tetris.dart';

bool rotateBySrs(Tetromino tetromino, List<List<Block>> playfield,
    {bool clockwise: true}) {
  tetromino.blocks.forEach((block) {
    playfield.setBlockAt(block.point, null);
  });

  tetromino.rotate(clockwise: clockwise);

  Direction kickDirection;

  for (Block block in tetromino.blocks) {
    if (block.point.x == -1) {
      kickDirection = Direction.right;
      break;
    } else if (block.point.x == playfieldWidth) {
      kickDirection = Direction.left;
    } else if (block.point.y == -1) {
      kickDirection = Direction.up;
    } else if (block.point.y == playfieldHeight) {
      kickDirection = Direction.down;
    }
  }

  if (kickDirection != null) {
    tetromino.move(kickDirection);
  }

  bool canRotate = true;

  for (Block block in tetromino.blocks) {
    if (playfield.getBlockAt(block.point)?.isGhost == false) {
      canRotate = false;
      break;
    }
  }

  if (!canRotate) {
    if (kickDirection != null) {
      tetromino.move(kickDirection.opposite);
    }

    tetromino.rotate(clockwise: !clockwise);
  }

  tetromino.blocks.forEach((block) {
    playfield.setBlockAt(block.point, block);
  });

  return canRotate;
}
