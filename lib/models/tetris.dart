import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tetris/models/audio_manager.dart';
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
  static const tSpinTestOffsets = [
    Point(-1, 1),
    Point(1, 1),
    Point(1, -1),
    Point(-1, -1)
  ];

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

  bool get canUpdate => !_paused && !_isOnBreakLine;

  int _brokenLinesCountInLevel = 0;

  bool _rotationOccuredBeforeLock = false;

  bool _isOnBreakLine = false;

  bool _softDropDoccured = false;

  Timer _gameOverAnimatior;

  TetrominoName _holdingMino;
  final BehaviorSubject<TetrominoName> _holdingMinoSubject = BehaviorSubject();
  Stream<TetrominoName> get holdingMinoStream => _holdingMinoSubject.stream;

  final AudioManager audioManager = AudioManager.instance;

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
    _holdingMinoSubject.close();
    _gameOverAnimatior?.cancel();
    InputManager.instance.unregister(this);
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void startGame() {
    _gameOverAnimatior?.cancel();

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

    AudioManager.instance.stopBgm(Bgm.gameOver);
    AudioManager.instance.startBgm(Bgm.play);
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

    _brokenLinesCountInLevel = 0;

    _holdingMino = null;
    _holdingMinoSubject.sink.add(_holdingMino);
  }

  void spawnNextMino() {
    spawn(_nextMinoQueue.removeFirst());
    _nextMinoQueue.add(_randomMinoGenerator.getNext());
    _nextMinoSubject.sink.add(_nextMinoQueue.first);

    _rotationOccuredBeforeLock = false;
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

  Future<void> lock() async {
    _isStucked = false;
    _softDropDoccured = false;
    _stuckedSeconds = 0;
    _accumulatedPower = 0;
    await checkLines();
    spawnNextMino();
  }

  void commandMove(Direction direction) {
    if (canUpdate) {
      if (_currentDropMode != DropMode.hard) {
        final isMoved = moveCurrentMino(direction);

        if (direction == Direction.down && !isMoved && !_softDropDoccured) {
          _softDropDoccured = true;

          _eventSubject.sink.add(TetrisEvent.softDrop);
        }
      }
    }
  }

  void commandRotate({bool clockwise: true}) {
    if (canUpdate) {
      if (_currentDropMode != DropMode.hard) {
        rotateCurrentMino(clockwise: clockwise);
      }
    }
  }

  bool moveCurrentMino(Direction direction) {
    if (move(_currentTetromino, _playfield, direction)) {
      if (direction.isHorizontal) {
        _setGhostPiece(_currentTetromino, _playfield);
        _rotationOccuredBeforeLock = false;
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
      _rotationOccuredBeforeLock =
          !canMove(_currentTetromino, _playfield, Direction.down);
      notifyListeners();
    }
  }

  void dropHard() {
    _currentDropMode = DropMode.hard;
  }

  Future<void> checkLines() async {
    final linesCanBroken = _playfield
        .where((line) => line.every((block) => block != null && !block.isGhost))
        .toList();

    TetrisEvent event;

    if (linesCanBroken.isNotEmpty) {
      if (isTetris(linesCanBroken)) {
        event = TetrisEvent.tetris;
      } else if (isTSpin(_currentTetromino, _playfield)) {
        if (hasRoof(_currentTetromino, _playfield)) {
          switch (linesCanBroken.length) {
            case 1:
              event = TetrisEvent.tSpinSingle;
              break;
            case 2:
              event = TetrisEvent.tSpinDouble;
              break;
            case 3:
              event = TetrisEvent.tSpinTriple;
              break;
          }
        } else {
          event = TetrisEvent.tSpinMini;
        }
      }

      _eventSubject.sink.add(event);
      scoreUp(_level, linesCanBroken.length, event);
      await breakLines(linesCanBroken);
    } else {
      _eventSubject.sink.add(null);
    }
  }

  bool isTetris(List<List<Block>> brokenLines) => brokenLines.length == 4;
  bool isTSpin(Tetromino tetromino, List<List<Block>> playfield) {
    if (tetromino.name != TetrominoName.T || !_rotationOccuredBeforeLock)
      return false;

    int blockCountArountT = 0;

    for (Point<int> testOffset in tSpinTestOffsets) {
      final testPoint = tetromino.center + testOffset;

      if (playfield.isWall(testPoint) || isBlocked(testPoint, playfield)) {
        blockCountArountT++;

        if (blockCountArountT >= 3) return true;
      }
    }

    return false;
  }

  bool isBlocked(Point<int> point, List<List<Block>> playfield) =>
      !isBlockNullOrGhost(playfield.getBlockAt(point));

  bool hasRoof(Tetromino tetromino, List<List<Block>> playfield) {
    final leftTop = tetromino.center + Point(-1, 1);
    final rightTop = tetromino.center + Point(1, 1);

    return !playfield.isWall(leftTop) && isBlocked(leftTop, playfield) ||
        !playfield.isWall(rightTop) && isBlocked(rightTop, playfield);
  }

  Future<void> breakLines(List<List<Block>> linesCanBroken) async {
    _isOnBreakLine = true;

    for (int x = 0; x < _playfield.width; x++) {
      await Future.delayed(const Duration(milliseconds: 15));
      linesCanBroken.forEach((line) {
        line[x].isGhost = true;

        if (x > 0) {
          line[x - 1] = null;
        }
        notifyListeners();
      });
    }

    for (List<Block> line in linesCanBroken) {
      await Future.delayed(const Duration(milliseconds: 15));
      _playfield.remove(line);
      _playfield.add(List<Block>.generate(_playfield.width, (index) => null));
      notifyListeners();
    }

    _brokenLinesCountInLevel += linesCanBroken.length;

    if (_brokenLinesCountInLevel >= linesCountToLevelUp) {
      levelUp();
      _brokenLinesCountInLevel -= linesCountToLevelUp;
    }

    _isOnBreakLine = false;
  }

  void scoreUp(int level, int brokenLinesLength, TetrisEvent event) {
    if (brokenLinesLength == 0) return;

    switch (event) {
      case TetrisEvent.tetris:
        _score += 800 * level;
        break;
      case TetrisEvent.tSpinMini:
        _score += 200 * brokenLinesLength * level;
        break;
      case TetrisEvent.tSpinSingle:
        _score += 800 * level;
        break;
      case TetrisEvent.tSpinDouble:
        _score += 1200 * level;
        break;
      case TetrisEvent.tSpinTriple:
        _score += 1600 * level;
        break;
      default:
        switch (brokenLinesLength) {
          case 1:
            _score += 100 * level;
            break;
          case 2:
            _score += 300 * level;
            break;
          case 3:
            _score += 500 * level;
            break;
        }
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

    int y = _currentTetromino.center.y + 1;

    _gameOverAnimatior =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _playfield[y].forEach((block) {
        block?.color = Colors.grey;
      });

      notifyListeners();

      y--;

      if (y < 0) {
        timer.cancel();
      }
    });

    AudioManager.instance.stopBgm(Bgm.play);
    AudioManager.instance.startBgm(Bgm.gameOver);
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

  void hold() {
    if (_holdingMino == null) {
      _holdingMino = _nextMinoQueue.removeFirst();
      _nextMinoQueue.add(_randomMinoGenerator.getNext());

      _holdingMinoSubject.sink.add(_holdingMino);
      _nextMinoSubject.sink.add(_nextMinoQueue.first);
    } else {
      _nextMinoQueue.addFirst(_holdingMino);
      _holdingMino = null;

      _holdingMinoSubject.sink.add(_holdingMino);
      _nextMinoSubject.sink.add(_nextMinoQueue.first);
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
