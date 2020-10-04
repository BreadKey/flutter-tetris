import 'dart:math';

import 'package:tetris/models/block.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/rules.dart';
import 'package:tetris/models/tetromino.dart';

class Tetris {
  List<List<Block>> _playfield = List.generate(
      playfieldHeight, (y) => List.generate(playfieldWidth, (x) => null));

  Iterable<Iterable<Block>> get playfield => _playfield;

  Tetromino _currentTetromino;
  Tetromino get currentTetromino => _currentTetromino;

  void spawn(TetrominoName tetrominoName) {
    final tetromino = Tetromino.from(tetrominoName);

    tetromino.spawn(spawnPoint);

    if (canMove(tetromino, Direction.down)) {
      tetromino.move(Direction.down);

      _currentTetromino = tetromino;
      tetromino.blocks.forEach((block) {
        _playfield[block.point.y][block.point.x] = block;
      });
    }
  }

  bool canMove(Tetromino tetromino, Direction direction) {
    tetromino.blocks.forEach((block) {
      final blockAtNextpoint = getBlockAt(block.point + direction.vector);

      if (blockAtNextpoint != null &&
          !tetromino.blocks.contains(blockAtNextpoint)) return false;
    });

    return true;
  }

  Block getBlockAt(Point<int> point) => _playfield[point.y][point.x];
}
