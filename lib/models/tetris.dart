import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tetris/models/block.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/random_mino_generator.dart';
import 'package:tetris/models/rules.dart';
import 'package:tetris/models/tetromino.dart';

part 'super_rotation_system.dart';

extension on List<List<Block>> {
  Block getBlockAt(Point<int> point) => this[point.y][point.x];
  void setBlockAt(Point<int> point, Block block) {
    this[point.y][point.x] = block;
  }
}

enum DropMode { gravity, soft, hard }

class Tetris extends ChangeNotifier {
  static const fps = 64;
  List<List<Block>> _playfield;

  Iterable<Iterable<Block>> get playfield => _playfield;

  Tetromino _currentTetromino;
  Tetromino get currentTetromino => _currentTetromino;

  double _gravity = 1 / fps;
  double _accumulatedPower = 0;

  Timer _frameGenerator;

  RandomMinoGenerator _randomMinoGenerator;

  bool _isStuckedBefore = false;

  DropMode _currentDropMode = DropMode.gravity;

  final Tetromino _ghostPiece = Tetromino.ghost();

  void startGame() {
    _playfield = _generatePlayField();

    _frameGenerator =
        Timer.periodic(const Duration(microseconds: 1000000 ~/ fps), (timer) {
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
    final tetromino = Tetromino.from(tetrominoName, spawnPoint);

    if (canMove(tetromino, Direction.down)) {
      tetromino.move(Direction.down);

      _currentTetromino = tetromino;
      tetromino.blocks.forEach((block) {
        _playfield.setBlockAt(block.point, block);
      });

      _setGhostPiece();
    } else {
      _gameOver();
    }

    notifyListeners();
  }

  bool canMove(Tetromino tetromino, Direction direction, {Tetromino mask}) {
    for (Block block in tetromino.blocks) {
      final nextPoint = block.point + direction.vector;

      if (isOutOfPlayfield(nextPoint)) {
        return false;
      }

      final blockAtNextpoint = _playfield.getBlockAt(nextPoint);

      if (blockAtNextpoint?.isGhost == false &&
          !(mask ?? tetromino).blocks.contains(blockAtNextpoint)) return false;
    }

    return true;
  }

  bool isOutOfPlayfield(Point<int> point) =>
      point.x < 0 ||
      point.x >= playfieldWidth ||
      point.y < 0 ||
      point.y >= playfieldHeight;

  void _update() {
    _handleGravity(_currentDropMode == DropMode.hard ? 20 : _gravity);
  }

  void _handleGravity(double gravity) {
    _accumulatedPower += gravity;

    if (_accumulatedPower >= 1) {
      final step = _accumulatedPower ~/ 1;

      for (int i = 0; i < step; i++) {
        final isMoved = move(Direction.down);
        if (isMoved) {
          _isStuckedBefore = false;
        } else {
          _accumulatedPower = 0;
          if (_isStuckedBefore) {
            checkLines();
            spawn(_randomMinoGenerator.getNext());
            return;
          }

          if (_currentDropMode == DropMode.hard) {
            _currentDropMode = DropMode.gravity;
          }

          _isStuckedBefore = true;
          return;
        }
      }

      _accumulatedPower -= step;
    }
  }

  void commandMove(Direction direction) {
    if (_currentDropMode != DropMode.hard) {
      move(direction);
    }
  }

  void commandRotate({bool clockwise: true}) {
    if (_currentDropMode != DropMode.hard) {
      rotate(clockwise: clockwise);
    }
  }

  bool move(Direction direction) {
    if (_currentTetromino == null) {
      return false;
    }

    if (canMove(_currentTetromino, direction)) {
      _currentTetromino.blocks.forEach((block) {
        _playfield.setBlockAt(block.point, null);
      });

      _currentTetromino.move(direction);
      _currentTetromino.blocks.forEach((block) {
        _playfield.setBlockAt(block.point, block);
      });

      if (direction.isHorizontal) {
        _setGhostPiece();
      }

      notifyListeners();

      return true;
    }

    return false;
  }

  void rotate({bool clockwise: true}) {
    if (rotateBySrs(_currentTetromino, _playfield, clockwise: clockwise)) {
      _setGhostPiece();
      notifyListeners();
    }
  }

  void dropHard() {
    _currentDropMode = DropMode.hard;
  }

  void checkLines() {
    final linesCanBroken = _playfield
        .where((line) => line.every((block) => block != null && !block.isGhost))
        .toList();

    linesCanBroken.forEach((line) {
      _playfield.remove(line);
    });

    _playfield.addAll(List.generate(linesCanBroken.length,
        (index) => List<Block>.generate(playfieldWidth, (index) => null)));
  }

  void _setGhostPiece() {
    for (Block ghostBlock in _ghostPiece.blocks) {
      if (_playfield.getBlockAt(ghostBlock.point)?.isGhost == true) {
        _playfield.setBlockAt(ghostBlock.point, null);
      }
    }

    for (int index = 0; index < _currentTetromino.blocks.length; index++) {
      _ghostPiece.blocks[index].point = _currentTetromino.blocks[index].point;
      _ghostPiece.blocks[index].color = _currentTetromino.blocks[index].color;
    }

    while (canMove(_ghostPiece, Direction.down, mask: _currentTetromino)) {
      _ghostPiece.move(Direction.down);
    }

    if (!_ghostPiece.hasSamePoints(_currentTetromino)) {
      _ghostPiece.blocks.forEach((ghostBlock) {
        _playfield.setBlockAt(ghostBlock.point, ghostBlock);
      });
    }
  }

  void _gameOver() {
    _frameGenerator.cancel();
    startGame();
  }
}
