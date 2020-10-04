import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/models/block.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/random_mino_generator.dart';
import 'package:tetris/models/rules.dart';
import 'package:tetris/models/tetromino.dart';

class Tetris extends ChangeNotifier {
  List<List<Block>> _playfield;

  Iterable<Iterable<Block>> get playfield => _playfield;

  Tetromino _currentTetromino;
  Tetromino get currentTetromino => _currentTetromino;

  double _gravity = 0.1;
  double _accumulatedPower = 0;

  Timer _frameGenerator;

  RandomMinoGenerator _randomMinoGenerator;

  bool _isStuckedBefore = false;

  void startGame() {
    _playfield = _generatePlayField();

    _frameGenerator =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _update();
    });

    _randomMinoGenerator = RandomMinoGenerator();

    spawn(_randomMinoGenerator.getNext());
  }

  List<List<Block>> _generatePlayField() => List.generate(
      playfieldHeight, (y) => List.generate(playfieldWidth, (x) => null));

  void dispose() {
    _frameGenerator?.cancel();
    super.dispose();
  }

  void spawn(TetrominoName tetrominoName) {
    final tetromino = Tetromino.from(tetrominoName);

    tetromino.spawn(spawnPoint);

    if (canMove(tetromino, Direction.down)) {
      tetromino.move(Direction.down);

      _currentTetromino = tetromino;
      tetromino.blocks.forEach((block) {
        setBlockAt(block.point, block);
      });
    } else {
      _gameOver();
    }

    notifyListeners();
  }

  bool canMove(Tetromino tetromino, Direction direction) {
    for (Block block in tetromino.blocks) {
      final nextPoint = block.point + direction.vector;

      if (isOutOfPlayfield(nextPoint)) {
        return false;
      }

      final blockAtNextpoint = getBlockAt(nextPoint);

      if (blockAtNextpoint != null &&
          !tetromino.blocks.contains(blockAtNextpoint)) return false;
    }

    return true;
  }

  bool isOutOfPlayfield(Point<int> point) =>
      point.x < 0 ||
      point.x >= playfieldWidth ||
      point.y < 0 ||
      point.y >= playfieldHeight;

  Block getBlockAt(Point<int> point) => _playfield[point.y][point.x];
  void setBlockAt(Point<int> point, Block block) {
    _playfield[point.y][point.x] = block;
  }

  void _update() {
    _handleGravity(_gravity);
  }

  void _handleGravity(double gravity) {
    _accumulatedPower += _gravity;

    if (_accumulatedPower >= 1) {
      final step = _accumulatedPower ~/ 1;

      for (int i = 0; i < step; i++) {
        final isMoved = move(Direction.down);
        if (isMoved) {
          _isStuckedBefore = false;
        } else {
          if (_isStuckedBefore) {
            spawn(_randomMinoGenerator.getNext());
          }

          _isStuckedBefore = true;
          break;
        }
      }

      _accumulatedPower = 0;
    }
  }

  bool move(Direction direction) {
    if (_currentTetromino == null) {
      return false;
    }

    if (canMove(_currentTetromino, direction)) {
      _currentTetromino.blocks.forEach((block) {
        setBlockAt(block.point, null);
      });

      _currentTetromino.move(direction);
      _currentTetromino.blocks.forEach((block) {
        setBlockAt(block.point, block);
      });

      notifyListeners();

      return true;
    }

    return false;
  }

  void _gameOver() {
    _frameGenerator.cancel();
    startGame();
  }
}
