import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/tetris_screen/board.dart';

class EventBoard extends StatelessWidget {
  final Tetris tetris;

  const EventBoard(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Board(
      child: AspectRatio(
          aspectRatio: 5 / 4,
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            StreamProvider<TetrisEvent>.value(
              value: tetris.eventStream,
              initialData: null,
              updateShouldNotify: (previous, current) =>
                  current != TetrisEvent.softDrop,
              child: Consumer<TetrisEvent>(
                builder: (context, event, child) {
                  return _buildTetrisEvent(context, event);
                },
              ),
            ),
            Selector<Tetris, bool>(
              selector: (_, tetris) => tetris.isBackToBack,
              builder: (_, isBackToBack, __) => isBackToBack
                  ? Text(
                      "Back to Back",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption,
                    )
                  : const SizedBox.shrink(),
            )
          ]))));

  Widget _buildTetrisEvent(BuildContext context, TetrisEvent event) {
    final textTheme =
        Theme.of(context).textTheme.subtitle2.copyWith(color: roseViolet);

    return Text(
      _getEventText(event),
      textAlign: TextAlign.center,
      style: textTheme,
    );
  }

  String _getEventText(TetrisEvent event) {
    switch (event) {
      case TetrisEvent.gameOver:
        return "Game Over!";
      case TetrisEvent.tetris:
        return "Tetris!";
      case TetrisEvent.tSpinSingle:
        return "T-Spin Single!";
      case TetrisEvent.tSpinDouble:
        return "T-Spin Double!";
      case TetrisEvent.tSpinTriple:
        return "T-Spin Triple!";
      case TetrisEvent.tSpinMini:
        return "T-Spin Mini!";
      case TetrisEvent.perfectClear:
        return "Perfect Clear!";
      default:
        return "";
    }
  }
}
