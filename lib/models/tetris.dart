import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tetris/dao/local/local_rank_dao.dart';
import 'package:tetris/dao/rank_dao.dart';
import 'package:tetris/models/audio_manager.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/input_manager.dart';
import 'package:tetris/models/rank.dart';
import 'package:tetris/retro_colors.dart';

part 'tetris/block.dart';
part 'tetris/random_mino_generator.dart';
part 'tetris/rules.dart';
part 'tetris/super_rotation_system.dart';
part 'tetris/tetromino.dart';
part 'tetris/event.dart';
part 'tetris/animator.dart';

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

class Tetris extends ChangeNotifier
    with InputListener, WidgetsBindingObserver, AnimationListener {
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

  final Queue<TetrominoName> _nextMinoBag = Queue<TetrominoName>();

  final BehaviorSubject<List<TetrominoName>> _nextMinoBagSubject =
      BehaviorSubject();
  Stream<List<TetrominoName>> get nextMinoBagStream =>
      _nextMinoBagSubject.stream;

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

  TetrominoName _holdingMino;
  final BehaviorSubject<TetrominoName> _holdingMinoSubject = BehaviorSubject();
  Stream<TetrominoName> get holdingMinoStream => _holdingMinoSubject.stream;

  final AudioManager _audioManager = AudioManager.instance;

  final Animator _animator = Animator();

  final _playerId = 0;
  final RankDao _rankDao = LocalRankDao();
  final BehaviorSubject<Rank> _rankSubject = BehaviorSubject();
  Stream<Rank> get rankStream => _rankSubject.stream;

  Tetris() {
    InputManager.instance.register(this);
    WidgetsBinding.instance?.addObserver(this);
    _animator.listener = this;

    _loadRank();
  }

  void dispose() {
    _frameGenerator?.cancel();
    _nextMinoBagSubject.close();
    _levelSubject.close();
    _scoreSubject.close();
    _eventSubject.close();
    _rankSubject.close();
    _holdingMinoSubject.close();
    InputManager.instance.unregister(this);
    WidgetsBinding.instance?.removeObserver(this);
    _audioManager.dispose();
    _animator.dispose();
    super.dispose();
  }

  void startGame() {
    _animator.stopGameOver();

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

    _nextMinoBag.clear();

    _nextMinoBag.addAll(List.generate(TetrominoName.values.length,
        (index) => _randomMinoGenerator.getNext()));

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
    spawn(_nextMinoBag.removeFirst());
    _nextMinoBag.add(_randomMinoGenerator.getNext());
    _nextMinoBagSubject.sink.add(_nextMinoBag.toList());

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
          _audioManager.playEffect(Effect.lock);
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
            _audioManager.playEffect(Effect.hardDrop);
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

        if (isMoved) {
          _audioManager.playEffect(Effect.move);
        }

        if (direction == Direction.down) {
          if (!isMoved) {
            if (!_softDropDoccured) {
              _onSoftDrop();
            }
          } else {
            _softDropDoccured = false;
          }
        }
      }
    }
  }

  void _onSoftDrop() {
    _audioManager.playEffect(Effect.softDrop);
    _softDropDoccured = true;

    _eventSubject.sink.add(TetrisEvent.softDrop);
  }

  void commandRotate({bool clockwise: true}) {
    if (canUpdate) {
      if (_currentDropMode != DropMode.hard) {
        final isRotated = rotateCurrentMino(clockwise: clockwise);

        if (isRotated) {
          _audioManager.playEffect(Effect.rotate);
        }
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

  bool rotateCurrentMino({bool clockwise: true}) {
    if (rotateBySrs(_currentTetromino, _playfield, clockwise: clockwise)) {
      _setGhostPiece(_currentTetromino, _playfield);
      _rotationOccuredBeforeLock =
          !canMove(_currentTetromino, _playfield, Direction.down);
      notifyListeners();
      return true;
    }

    return false;
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
        _audioManager.playEffect(Effect.event);
      } else if (isTSpin(_currentTetromino, _playfield)) {
        _audioManager.playEffect(Effect.event);
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
      } else {
        _audioManager.playEffect(Effect.breakLine);
      }

      _eventSubject.sink.add(event);
      scoreUp(_level, linesCanBroken.length, event);
      await breakLines(linesCanBroken, event);
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

  Future<void> breakLines(
      List<List<Block>> linesCanBroken, TetrisEvent event) async {
    _isOnBreakLine = true;

    await _animator.breakLines(
        _currentTetromino, _playfield, linesCanBroken, event);

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
      _audioManager.playEffect(Effect.levelUp);
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

    _animator.startGameOver(_currentTetromino, _playfield);

    AudioManager.instance.stopBgm(Bgm.play);
    AudioManager.instance.startBgm(Bgm.gameOver);

    if (_score > 0) {
      _rankDao.insert(RankData(_playerId, _score)).then((_) {
        _loadRank();
      });
    }
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
      case ButtonKey.special1:
        break;
      case ButtonKey.special2:
        hold();
        break;
    }
  }

  void hold() {
    if (_holdingMino == null) {
      _holdingMino = _nextMinoBag.removeFirst();
      _nextMinoBag.add(_randomMinoGenerator.getNext());

      _holdingMinoSubject.sink.add(_holdingMino);
      _nextMinoBagSubject.sink.add(_nextMinoBag.toList());
    } else {
      _nextMinoBag.addFirst(_holdingMino);
      _holdingMino = null;

      _holdingMinoSubject.sink.add(_holdingMino);
      _nextMinoBagSubject.sink.add(_nextMinoBag.toList());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _paused = true;
      _audioManager.pause();
    } else if (state == AppLifecycleState.resumed) {
      _paused = false;
      _audioManager.resume();
    }
  }

  @override
  void onAnimationUpdated() {
    notifyListeners();
  }

  Future<void> _loadRank() async {
    final ranks = await _rankDao.getRankOrderByDesc(10);
    final playerRank = await _rankDao.getRankByPlayerId(_playerId);

    _rankSubject.sink
        .add(Rank(MapEntry(playerRank, ranks.indexOf(playerRank) + 1), ranks));
  }
}
