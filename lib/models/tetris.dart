import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';

part 'tetris/block.dart';
part 'tetris/random_mino_generator.dart';
part 'tetris/rules.dart';
part 'tetris/super_rotation_system.dart';
part 'tetris/tetromino.dart';
part 'tetris/event.dart';

extension Playfield on List<List<Block>> {
  Block getBlockAt(Point<int> point) => this[point.y][point.x];
  void setBlockAt(Point<int> point, Block block) {
    this[point.y][point.x] = block;
  }

  int get width => first.length;
  int get height => length;

  bool isWall(Point<int> point) =>
      point.x < 0 || point.x >= width || point.y < 0 || point.y >= height;
}

enum DropMode { gravity, soft, hard }
enum OnHardDrop { instantLock, wait }

class Tetris extends ChangeNotifier with InputListener, WidgetsBindingObserver {
  static const fps = 64;
  static const secondsPerFrame = 1 / fps;
  List<List<Block>> _playfield;

  Iterable<Iterable<Block>> get playfield => _playfield;

  Tetromino _currentTetromino;
  Tetromino get currentTetromino => _currentTetromino;

  double _accumulatedPower = 0;

  Timer _frameGenerator;

  RandomMinoGenerator _randomMinoGenerator;

  DropMode _currentDropMode = DropMode.gravity;

  OnHardDrop _onHardDrop = OnHardDrop.instantLock;

  double _stuckedSeconds = 0.0;

  final Tetromino _ghostPiece = Tetromino.ghost();

  final Queue<TetrominoName> _nextMinoQueue = Queue<TetrominoName>();

  final BehaviorSubject<TetrominoName> _nextMinoSubject = BehaviorSubject();
  Stream<TetrominoName> get nextMinoStream => _nextMinoSubject.stream;

  bool _isStucked = false;

  bool _paused = false;

  int _level = 1;
  final BehaviorSubject<int> _levelSubject = BehaviorSubject();
  Stream<int> get levelStream => _levelSubject.stream;

  int _score = 0;
  final BehaviorSubject<int> _scoreSubject = BehaviorSubject();
  Stream<int> get scoreStream => _scoreSubject.stream;

  final PublishSubject<TetrisEvent> _eventSubject = PublishSubject();
  Stream<TetrisEvent> get eventStream => _eventSubject.stream;

  bool _isGameOver = false;

  bool get canUpdate => !_paused;

  Tetris() {
    InputManager.instance.register(this);
    WidgetsBinding.instance?.addObserver(this);
  }

  void dispose() {
    _frameGenerator?.cancel();
    _nextMinoSubject.close();
    _levelSubject.close();
    _scoreSubject.close();
    _eventSubject.close();
    InputManager.instance.unregister(this);
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void startGame() {
    initPlayfield();

    _stuckedSeconds = 0;

    initStatus();

    _frameGenerator =
        Timer.periodic(const Duration(microseconds: 1000000 ~/ fps), (timer) {
      if (canUpdate) {
        _update();
      }
    });

    _randomMinoGenerator = RandomMinoGenerator();

    _nextMinoQueue.clear();

    _nextMinoQueue.addAll(
        [_randomMinoGenerator.getNext(), _randomMinoGenerator.getNext()]);

    spawnNextMino();
  }

  void initPlayfield() {
    _playfield = _generatePlayField();
  }

  List<List<Block>> _generatePlayField() => List.generate(
      playfieldHeight, (y) => List.generate(playfieldWidth, (x) => null));

  void initStatus() {
    _level = 1;
    _levelSubject.sink.add(_level);

    _score = 0;
    _scoreSubject.sink.add(_score);

    _isGameOver = false;
    _eventSubject.sink.add(null);
  }

  void spawnNextMino() {
    spawn(_nextMinoQueue.removeFirst());
    _nextMinoQueue.add(_randomMinoGenerator.getNext());
    _nextMinoSubject.sink.add(_nextMinoQueue.first);
  }

  void spawn(TetrominoName tetrominoName) {
    final tetromino = Tetromino.spawn(tetrominoName, spawnPoint);

    if (canMove(tetromino, _playfield, Direction.down)) {
      tetromino.move(Direction.down);

      _currentTetromino = tetromino;
      tetromino.blocks.forEach((block) {
        _playfield.setBlockAt(block.point, block);
      });

      _setGhostPiece(_currentTetromino, _playfield);
    } else {
      _gameOver();
    }

    notifyListeners();
  }

  bool canMove(
      Tetromino tetromino, List<List<Block>> playfield, Direction direction,
      {Tetromino mask}) {
    for (Block block in tetromino.blocks) {
      final nextPoint = block.point + direction.vector;

      if (playfield.isWall(nextPoint)) {
        return false;
      }

      final blockAtNextpoint = playfield.getBlockAt(nextPoint);

      if (!isBlockNullOrGhost(blockAtNextpoint) &&
          !blockAtNextpoint.isPartOf(mask ?? tetromino)) return false;
    }

    return true;
  }

  bool isBlockNullOrGhost(Block block) => block?.isGhost != false;

  void _update() {
    _handleGravity(_currentDropMode == DropMode.hard ? 20 : gravities[_level]);
    if (_isStucked) {
      _stuckedSeconds += secondsPerFrame;
      if (_stuckedSeconds >= 0.5) {
        if (!canMove(_currentTetromino, _playfield, Direction.down)) {
          lock();
        }
      }
    }
  }

  void _handleGravity(double gravity) {
    _accumulatedPower += gravity;

    if (_accumulatedPower >= 1) {
      final step = _accumulatedPower ~/ 1;

      for (int i = 0; i < step; i++) {
        final isMoved = moveCurrentMino(Direction.down);
        if (isMoved) {
          _stuckedSeconds = 0;
          _isStucked = false;
        } else {
          if (_currentDropMode == DropMode.hard) {
            _currentDropMode = DropMode.gravity;
            _eventSubject.sink.add(TetrisEvent.hardDrop);

            if (_onHardDrop == OnHardDrop.instantLock) {
              lock();
              return;
            }
          }

          _isStucked = true;
          break;
        }
      }

      _accumulatedPower -= step;
    }
  }

  void lock() {
    _isStucked = false;
    _stuckedSeconds = 0;
    _accumulatedPower = 0;
    checkLines();
    spawnNextMino();
  }

  void commandMove(Direction direction) {
    if (_currentDropMode != DropMode.hard) {
      moveCurrentMino(direction);
    }
  }

  void commandRotate({bool clockwise: true}) {
    if (_currentDropMode != DropMode.hard) {
      rotateCurrentMino(clockwise: clockwise);
    }
  }

  bool moveCurrentMino(Direction direction) {
    if (move(_currentTetromino, _playfield, direction)) {
      if (direction.isHorizontal) {
        _setGhostPiece(_currentTetromino, _playfield);
      }
      notifyListeners();

      return true;
    }

    return false;
  }

  bool move(
      Tetromino tetromino, List<List<Block>> playfield, Direction direction) {
    if (tetromino == null) {
      return false;
    }

    if (canMove(tetromino, playfield, direction)) {
      tetromino.blocks.forEach((block) {
        playfield.setBlockAt(block.point, null);
      });

      tetromino.move(direction);
      tetromino.blocks.forEach((block) {
        playfield.setBlockAt(block.point, block);
      });

      return true;
    }

    return false;
  }

  void rotateCurrentMino({bool clockwise: true}) {
    if (rotateBySrs(_currentTetromino, _playfield, clockwise: clockwise)) {
      _setGhostPiece(_currentTetromino, _playfield);
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

    TetrisEvent event;

    final lastLevel = _level;

    if (linesCanBroken.isNotEmpty) {
      if (isTetris(linesCanBroken)) {
        event = TetrisEvent.tetris;
        levelUp();
      } else if (isTSpin(_currentTetromino, linesCanBroken)) {
        switch (linesCanBroken.length) {
          case 1:
            event = TetrisEvent.tSpinSingle;
            break;
          case 2:
            event = TetrisEvent.tSpinDouble;
            break;
          case 3:
            event = TetrisEvent.tSpinTriple;
        }
        levelUp();
      }

      scoreUp(lastLevel, linesCanBroken.length, event);
      brakeLines(linesCanBroken);
    }

    _eventSubject.sink.add(event);
  }

  bool isTetris(List<List<Block>> brokenLines) => brokenLines.length == 4;
  bool isTSpin(Tetromino tetromino, List<List<Block>> brokenLines) => false;

  void brakeLines(List<List<Block>> linesCanBroken) {
    linesCanBroken.forEach((line) {
      _playfield.remove(line);
    });

    _playfield.addAll(List.generate(linesCanBroken.length,
        (index) => List<Block>.generate(playfieldWidth, (index) => null)));
  }

  void scoreUp(int level, int brokenLinesLength, TetrisEvent event) {
    if (brokenLinesLength == 0) return;

    switch (brokenLinesLength) {
      case 1:
        _score += 40 * (_level + 1);
        break;
      case 2:
        _score += 100 * (_level + 1);
        break;
      case 3:
        _score += 300 * (_level + 1);
        break;
      case 4:
        _score += 1200 * (_level + 1);
        break;
    }

    _scoreSubject.sink.add(_score);
  }

  void levelUp() {
    if (_level != maxLevel) {
      _level++;
      _levelSubject.sink.add(_level);
    }
  }

  void _setGhostPiece(Tetromino tetromino, List<List<Block>> playfield) {
    for (Block ghostBlock in _ghostPiece.blocks) {
      if (playfield.getBlockAt(ghostBlock.point)?.isGhost == true) {
        playfield.setBlockAt(ghostBlock.point, null);
      }
    }

    for (int index = 0; index < _currentTetromino.blocks.length; index++) {
      _ghostPiece.blocks[index].point = _currentTetromino.blocks[index].point;
      _ghostPiece.blocks[index].color = _currentTetromino.blocks[index].color;
    }

    while (canMove(_ghostPiece, playfield, Direction.down, mask: tetromino)) {
      _ghostPiece.move(Direction.down);
    }

    final currentMinoPoints = tetromino.blocks.map((block) => block.point);

    _ghostPiece.blocks.forEach((ghostBlock) {
      if (!currentMinoPoints.contains(ghostBlock.point)) {
        _playfield.setBlockAt(ghostBlock.point, ghostBlock);
      }
    });
  }

  void _gameOver() {
    _isGameOver = true;
    _frameGenerator.cancel();
    _eventSubject.sink.add(TetrisEvent.gameOver);
  }

  @override
  void onDirectionEntered(Direction direction) {
    if (_isGameOver) return;
    if (direction == Direction.up) {
      commandRotate();
    } else {
      commandMove(direction);
    }
  }

  @override
  void onButtonEntered(ButtonKey key) {
    if (_isGameOver) {
      startGame();
      return;
    }

    switch (key) {
      case ButtonKey.a:
        commandRotate(clockwise: false);
        break;
      case ButtonKey.b:
        dropHard();
        break;
      case ButtonKey.c:
        commandRotate();
        break;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _paused = true;
    } else if (state == AppLifecycleState.resumed) {
      _paused = false;
    }
  }
}
