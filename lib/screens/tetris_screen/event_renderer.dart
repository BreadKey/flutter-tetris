import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';

class EventRenderer extends StatelessWidget {
  final Tetris tetris;

  const EventRenderer(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 5 / 4,
        child: Material(
          color: neutralBlackC,
          elevation: 4,
          child: Center(
            child: StreamProvider<TetrisEvent>.value(
              value: tetris.eventStream,
              updateShouldNotify: (previous, current) => true,
              child: Consumer<TetrisEvent>(
                builder: (context, event, child) {
                  return _buildTetrisEvent(context, event);
                },
              ),
            ),
          ),
        ),
      );

  Widget _buildTetrisEvent(BuildContext context, TetrisEvent event) {
    final textTheme =
        Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.white);

    return Text(
      event == TetrisEvent.gameOver
          ? "Game Over!"
          : event == TetrisEvent.tetris
              ? "Tetris!"
              : "",
      textAlign: TextAlign.center,
      style: textTheme,
    );
  }
}
