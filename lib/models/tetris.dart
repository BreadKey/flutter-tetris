library tetris;

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tetris/dao/rank_dao.dart';
import 'package:tetris/models/audio_manager.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/rank.dart';
import 'package:tetris/retro_colors.dart';

import 'audio_manager.dart';

part 'tetris/animator.dart';
part 'tetris/block.dart';
part 'tetris/event.dart';
part 'tetris/random_mino_generator.dart';
part 'tetris/rules.dart';
part 'tetris/super_rotation_system.dart';
part 'tetris/tetromino.dart';

extension Playfield on List<List<Block?>> {
  Block? getBlockAt(Point<int> point) => this[point.y][point.x];
  void setBlockAt(Point<int> point, Block? block) {
    this[point.y][point.x] = block;
  }

  int get width => first.length;
  int get height => length;

  bool isWall(Point<int> point) =>
      point.x < 0 || point.x >= width || point.y < 0 || point.y >= height;
}

enum DropMode { gravity, soft, hard }
enum OnHardDrop { instantLock, wait }

class Tetris extends ChangeNotifier with AnimationListener {
  static const secondsPerFrame = 1 / kFps;
  static const tSpinTestOffsets = [
    Point(-1, 1),
    Point(1, 1),
    Point(1, -1),
    Point(-1, -1)
  ];

  late List<List<Block?>> _playfield;
  Iterable<Iterable<Block?>> get playfield => _playfield;

  Tetromino? _currentTetromino;
  Tetromino? get currentTetromino => _currentTetromino;

  double _accumulatedPower = 0;

  Timer? _frameGenerator;

  final RandomMinoGenerator _randomMinoGenerator = RandomMinoGenerator();

  DropMode _currentDropMode = DropMode.gravity;

  OnHardDrop _onHardDrop = OnHardDrop.instantLock;

  double _stuckedSeconds = 0.0;

  final Tetromino _ghostPiece = Tetromino.ghost();

  final Queue<TetrominoName> _nextMinoBag = Queue<TetrominoName>();
  List<TetrominoName> get nextMinoBag => _nextMinoBag.toList();

  bool _isStucked = false;

  bool _paused = false;

  int _level = 1;
  int get level => _level;

  int _score = 0;
  int get score => _score;

  final PublishSubject<TetrisEvent?> _eventSubject = PublishSubject();
  Stream<TetrisEvent?> get eventStream => _eventSubject.stream;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;

  bool get canUpdate => !_paused && !_isOnLineClear;

  int _clearedLineCountInLevel = 0;

  bool _rotationOccuredBeforeLock = false;

  bool _isOnLineClear = false;

  bool _softDropOccured = false;

  bool _canHold = true;
  bool get canHold => _canHold;
  TetrominoName? _holdingMino;
  TetrominoName? get holdingMino => _holdingMino;

  final IAudioManager _audioManager = Injector.appInstance.get<IAudioManager>();

  final Animator _animator = Animator();

  final _playerId = 0;
  final RankDao _rankDao = Injector.appInstance.get<RankDao>();
  final BehaviorSubject<Rank> _rankSubject = BehaviorSubject();
  Stream<Rank> get rankStream => _rankSubject.stream;

  bool get isMuted => _audioManager.isMuted;

  TetrisEvent? _lastLineClearEvent;
  bool _isBackToBack = false;
  bool get isBackToBack => _isBackToBack;
  bool _isPerfectClearBefore = false;

  Tetris() {
    _animator.listener = this;

    _loadRank();
  }

  void dispose() {
    _frameGenerator?.cancel();
    _rankSubject.close();
    _eventSubject.close();
    _audioManager.dispose();
    _animator.dispose();
    super.dispose();
  }

  void startGame() {
    _animator.stopGameOver();

    initPlayfield();
    initStatus();
    initNextMinoBag();

    _frameGenerator =
        Timer.periodic(const Duration(microseconds: 1000000 ~/ kFps), (timer) {
      if (canUpdate) {
        _update();
      }
    });

    _audioManager.stopBgm(Bgm.gameOver);
    _audioManager.startBgm(Bgm.play);

    spawnNextMino();
  }

  void initPlayfield() {
    _playfield = List.generate(
        kPlayfieldHeight, (y) => List.generate(kPlayfieldWidth, (x) => null));
  }

  void initStatus() {
    _level = 1;

    _score = 0;

    _isGameOver = false;
    _eventSubject.sink.add(null);

    _stuckedSeconds = 0;
    _clearedLineCountInLevel = 0;

    _canHold = true;
    _holdingMino = null;

    _lastLineClearEvent = null;
    _isBackToBack = false;
    _isPerfectClearBefore = false;
  }

  void initNextMinoBag() {
    _randomMinoGenerator.clear();

    _nextMinoBag.clear();

    _nextMinoBag.addAll(List.generate(TetrominoName.values.length,
        (index) => _randomMinoGenerator.getNext()));
  }

  void spawnNextMino() {
    spawn(_nextMinoBag.removeFirst());
    addMinoToBag(_randomMinoGenerator.getNext());

    _rotationOccuredBeforeLock = false;
  }

  void addMinoToBag(TetrominoName tetrominoName) {
    _nextMinoBag.add(tetrominoName);
    notifyListeners();
  }

  void spawn(TetrominoName tetrominoName) {
    final tetromino = Tetromino.spawn(tetrominoName, kSpawnPoint);

    if (canMove(tetromino, _playfield, Direction.down)) {
      tetromino.move(Direction.down);

      _currentTetromino = tetromino;
      tetromino.blocks.forEach((block) {
        _playfield.setBlockAt(block.point, block);
      });

      _setGhostPiece(_currentTetromino!, _playfield);
    } else {
      _gameOver();
    }

    notifyListeners();
  }

  bool canMove(
      Tetromino tetromino, List<List<Block?>> playfield, Direction direction,
      {Tetromino? mask}) {
    for (Block block in tetromino.blocks) {
      final nextPoint = block.point + direction.vector;

      if (playfield.isWall(nextPoint)) {
        return false;
      }

      final blockAtNextpoint = playfield.getBlockAt(nextPoint);

      if (!isBlockNullOrGhost(blockAtNextpoint) &&
          !blockAtNextpoint!.isPartOf(mask ?? tetromino)) return false;
    }

    return true;
  }

  bool isBlockNullOrGhost(Block? block) => block?.isGhost != false;

  void _update() {
    _handleGravity(_currentDropMode == DropMode.hard
        ? kHardDropGravityPerFrame
        : kGravitiesPerFrame[_level - 1]);
    if (_isStucked) {
      _stuckedSeconds += secondsPerFrame;
      if (_stuckedSeconds >= 0.5) {
        if (!canMove(_currentTetromino!, _playfield, Direction.down)) {
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
    _softDropOccured = false;
    _stuckedSeconds = 0;
    _accumulatedPower = 0;
    _canHold = true;
    await checkLines();
    spawnNextMino();
  }

  void commandMove(Direction direction) {
    if (canUpdate) {
      if (_currentDropMode != DropMode.hard) {
        final isMoved = moveCurrentMino(direction);

        if (isMoved) {
          HapticFeedback.lightImpact();
        }

        if (direction == Direction.down) {
          if (!isMoved) {
            if (!_softDropOccured) {
              _onSoftDrop();
            }
          } else {
            _softDropOccured = false;
          }
        }
      }
    }
  }

  void _onSoftDrop() {
    _audioManager.playEffect(Effect.softDrop);
    _softDropOccured = true;

    _eventSubject.sink.add(TetrisEvent.softDrop);
  }

  void commandRotate({bool clockwise: true}) {
    if (canUpdate) {
      if (_currentDropMode != DropMode.hard) {
        final isRotated = rotateCurrentMino(clockwise: clockwise);

        if (isRotated) {
          HapticFeedback.lightImpact();
        }
      }
    }
  }

  bool moveCurrentMino(Direction direction) {
    if (move(_currentTetromino, _playfield, direction)) {
      if (direction.isHorizontal) {
        _setGhostPiece(_currentTetromino!, _playfield);
        _rotationOccuredBeforeLock = false;
      }
      notifyListeners();

      return true;
    }

    return false;
  }

  bool move(
      Tetromino? tetromino, List<List<Block?>> playfield, Direction direction) {
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
    if (rotateBySrs(_currentTetromino!, _playfield, clockwise: clockwise)) {
      _setGhostPiece(_currentTetromino!, _playfield);
      _rotationOccuredBeforeLock =
          !canMove(_currentTetromino!, _playfield, Direction.down);
      notifyListeners();

      return true;
    }

    return false;
  }

  void dropHard() {
    _currentDropMode = DropMode.hard;
  }

  Future<void> checkLines() async {
    final linesWillCleared = _playfield
        .where((line) => line.every((block) => block != null && !block.isGhost))
        .toList();

    TetrisEvent? event;

    if (linesWillCleared.isNotEmpty) {
      if (isTetris(linesWillCleared)) {
        event = TetrisEvent.tetris;
        _audioManager.playEffect(Effect.event);
      } else if (isTSpin(_currentTetromino!, _playfield)) {
        event = _calculateTSpin(linesWillCleared.length);
        _audioManager.playEffect(Effect.event);
      } else {
        _audioManager.playEffect(Effect.lineClear);
      }

      _onLineClearEvent(event, linesWillCleared.length);

      await clearLines(linesWillCleared, event);

      if (isPerfectClear()) {
        _onPerfectClear(linesWillCleared.length);
      } else {
        _isPerfectClearBefore = false;
      }
    } else {
      _eventSubject.sink.add(null);
      _isBackToBack = false;
    }
  }

  bool isTetris(List<List<Block?>> clearedLines) => clearedLines.length == 4;
  bool isTSpin(Tetromino tetromino, List<List<Block?>>? playfield) {
    if (tetromino.name != TetrominoName.T || !_rotationOccuredBeforeLock)
      return false;

    int blockCountArountT = 0;

    for (Point<int> testOffset in tSpinTestOffsets) {
      final testPoint = tetromino.center! + testOffset;

      if (playfield!.isWall(testPoint) || isBlocked(testPoint, playfield)) {
        blockCountArountT++;

        if (blockCountArountT >= 3) return true;
      }
    }

    return false;
  }

  TetrisEvent _calculateTSpin(int clearedLineCount) {
    if (hasRoof(_currentTetromino!, _playfield)) {
      switch (clearedLineCount) {
        case 1:
          return TetrisEvent.tSpinSingle;
        case 2:
          return TetrisEvent.tSpinDouble;
        case 3:
          return TetrisEvent.tSpinTriple;
      }
    }
    return TetrisEvent.tSpinMini;
  }

  void _onLineClearEvent(TetrisEvent? event, int clearedLineCount) {
    _eventSubject.sink.add(event);
    _checkBackToBack(event);

    scoreUp(_level, clearedLineCount, event);
  }

  bool isPerfectClear() =>
      _playfield.every((line) => line.every((block) => block == null));

  void _onPerfectClear(int clearedLineCount) {
    _eventSubject.sink.add(TetrisEvent.perfectClear);
    _audioManager.playEffect(Effect.event);
    _isBackToBack = _isPerfectClearBefore;
    scoreUp(_level, clearedLineCount, TetrisEvent.perfectClear);
    _isPerfectClearBefore = true;
  }

  bool isBlocked(Point<int> point, List<List<Block?>> playfield) =>
      !isBlockNullOrGhost(playfield.getBlockAt(point));

  bool hasRoof(Tetromino tetromino, List<List<Block?>> playfield) {
    final leftTop = tetromino.center! + Point(-1, 1);
    final rightTop = tetromino.center! + Point(1, 1);

    return !playfield.isWall(leftTop) && isBlocked(leftTop, playfield) ||
        !playfield.isWall(rightTop) && isBlocked(rightTop, playfield);
  }

  Future<void> clearLines(
      List<List<Block?>> linesCanCleared, TetrisEvent? event) async {
    _isOnLineClear = true;

    await _animator.clearLines(
        _currentTetromino, _playfield, linesCanCleared, event);

    _clearedLineCountInLevel += linesCanCleared.length;

    if (_clearedLineCountInLevel >= kLinesCountToLevelUp) {
      levelUp();
      _clearedLineCountInLevel -= kLinesCountToLevelUp;
    }

    _isOnLineClear = false;
  }

  void _checkBackToBack(TetrisEvent? event) {
    _isBackToBack = event != null && _lastLineClearEvent == event;
    _lastLineClearEvent = event;
  }

  void scoreUp(int level, int clearedLineCount, TetrisEvent? event) {
    if (clearedLineCount == 0) return;

    late int bonus;

    switch (event) {
      case TetrisEvent.tetris:
        bonus = 800 * level;
        break;
      case TetrisEvent.tSpinMini:
        bonus = 200 * clearedLineCount * level;
        break;
      case TetrisEvent.tSpinSingle:
        bonus = 800 * level;
        break;
      case TetrisEvent.tSpinDouble:
        bonus = 1200 * level;
        break;
      case TetrisEvent.tSpinTriple:
        bonus = 1600 * level;
        break;
      case TetrisEvent.perfectClear:
        switch (clearedLineCount) {
          case 1:
            bonus = 800 * level;
            break;
          case 2:
            bonus = 1200 * level;
            break;
          case 3:
            bonus = 1800 * level;
            break;
          case 4:
            bonus = 2000 * level;
            break;
        }
        break;
      default:
        switch (clearedLineCount) {
          case 1:
            bonus = 100 * level;
            break;
          case 2:
            bonus = 300 * level;
            break;
          case 3:
            bonus = 500 * level;
            break;
        }
        break;
    }

    if (isBackToBack) {
      bonus = bonus * 3 ~/ 2;
    }

    _score += bonus;

    notifyListeners();
  }

  void levelUp() {
    if (_level != kMaxLevel) {
      _audioManager.playEffect(Effect.levelUp);
      _level++;
      notifyListeners();
    }
  }

  void _setGhostPiece(Tetromino tetromino, List<List<Block?>> playfield) {
    for (Block ghostBlock in _ghostPiece.blocks) {
      if (playfield.getBlockAt(ghostBlock.point)?.isGhost == true) {
        playfield.setBlockAt(ghostBlock.point, null);
      }
    }

    for (int index = 0; index < _currentTetromino!.blocks.length; index++) {
      _ghostPiece.blocks[index].point = _currentTetromino!.blocks[index].point;
      _ghostPiece.blocks[index].color = _currentTetromino!.blocks[index].color;
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
    _frameGenerator!.cancel();
    _eventSubject.sink.add(TetrisEvent.gameOver);

    _animator.startGameOver(_currentTetromino!, _playfield);

    _audioManager.stopBgm(Bgm.play);
    _audioManager.startBgm(Bgm.gameOver);

    if (_score > 0) {
      _rankDao.insert(RankData(_playerId, _score)).then((_) {
        _loadRank();
      });
    }
  }

  void toggleMute() {
    _audioManager.toggleMute();
    notifyListeners();
  }

  void hold() {
    if (_canHold && canUpdate) {
      if (_holdingMino == null) {
        _holdingMino = _currentTetromino!.name;

        _clearCurrentMino();
        spawnNextMino();
      } else {
        final holding = _holdingMino!;
        _holdingMino = _currentTetromino!.name;

        _clearCurrentMino();
        spawn(holding);
      }
      _audioManager.playEffect(Effect.hold);
      _canHold = false;
    }
  }

  void _clearCurrentMino() {
    _currentTetromino!.blocks.forEach((block) {
      _playfield.setBlockAt(block.point, null);
    });
    _ghostPiece.blocks.forEach((ghostBlock) {
      _playfield.setBlockAt(ghostBlock.point, null);
    });
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

  Block? getBlockAt(int x, int y) => _playfield[y][x];

  void pause() {
    _paused = true;
    _audioManager.pause();
  }

  void resume() {
    _paused = false;
    _audioManager.resume();
  }
}
