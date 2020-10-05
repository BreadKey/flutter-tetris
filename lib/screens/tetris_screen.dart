import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/controller.dart';
import 'package:tetris/screens/next_mino_renderder.dart';
import 'package:tetris/screens/playfield_renderer.dart';

class TetrisScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen> {
  Tetris tetris;

  @override
  void initState() {
    super.initState();
    tetris = Tetris();

    tetris.startGame();
  }

  @override
  void dispose() {
    tetris.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: antiqueWhite,
      child: Column(
        children: [
          Expanded(
            flex: 2618,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2618,
                  child: PlayfieldRenderer(tetris),
                ),
                Expanded(
                  flex: 1000,
                  child: NextMinoRenderer(
                    tetris,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1000,
            child: Controller(
              longPressInterval:
                  const Duration(milliseconds: 1000 ~/ delayedAutoShiftHz),
            ),
          )
        ],
      ),
    );
  }
}
