part of tetris;

mixin AnimationListener {
  void onAnimationUpdated();
}

class Animator {
  Timer? _gameOverAnimatior;
  AnimationListener? _listener;
  set listener(AnimationListener value) {
    _listener = value;
  }

  void dispose() {
    _gameOverAnimatior?.cancel();
    _listener = null;
  }

  void startGameOver(Tetromino lastTetromino, List<List<Block?>>? playfield) {
    int y = lastTetromino.center!.y + 1;

    _gameOverAnimatior =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      playfield![y].forEach((block) {
        block?.color = Colors.grey;
      });

      _listener!.onAnimationUpdated();

      y--;

      if (y < 0) {
        timer.cancel();
      }
    });
  }

  void stopGameOver() {
    _gameOverAnimatior?.cancel();
  }

  Future<void> clearLines(
      Tetromino? currentTetromino,
      List<List<Block?>>? playfield,
      List<List<Block?>> linesCanCleared,
      TetrisEvent? event) async {
    switch (event) {
      case TetrisEvent.tetris:
        for (List<Block?> line in linesCanCleared) {
          for (Block? block in line) {
            block!.color = RetroColors.justWhite;
          }
        }
        break;
      case TetrisEvent.tSpinMini:
      case TetrisEvent.tSpinSingle:
      case TetrisEvent.tSpinDouble:
      case TetrisEvent.tSpinTriple:
        currentTetromino!.blocks.forEach((block) {
          block.color = RetroColors.justWhite;
        });
        _listener!.onAnimationUpdated();
        await Future.delayed(const Duration(milliseconds: 100));
        break;
      default:
        break;
    }

    for (int x = 0; x < playfield!.width; x++) {
      await Future.delayed(const Duration(milliseconds: 20));
      linesCanCleared.forEach((line) {
        line[x]!.isGhost = true;

        if (x > 0) {
          line[x - 1] = null;
        }
        _listener!.onAnimationUpdated();
      });
    }

    for (List<Block?> line in linesCanCleared) {
      await Future.delayed(const Duration(milliseconds: 20));
      playfield.remove(line);
      playfield.add(List<Block?>.generate(playfield.width, (index) => null));
      _listener!.onAnimationUpdated();
    }

    switch (event) {
      case TetrisEvent.tSpinMini:
      case TetrisEvent.tSpinSingle:
      case TetrisEvent.tSpinDouble:
      case TetrisEvent.tSpinTriple:
        currentTetromino!.blocks.forEach((block) {
          block.color = Colors.purple;
        });
        break;
      default:
        break;
    }
  }
}
