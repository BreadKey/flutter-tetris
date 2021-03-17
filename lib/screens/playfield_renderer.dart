import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/block_renderer.dart';
import 'package:tetris/screens/tetris_screen/board.dart';

class PlayfieldRenderer extends StatelessWidget {
  final Tetris tetris;
  const PlayfieldRenderer(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: playfieldWidth / visibleHeight,
      child: Board(
        child: Builder(
          builder: (context) {
            context.watch<Tetris>();
            return GridView.count(
              crossAxisCount: playfieldWidth,
              reverse: true,
              children: tetris.playfield
                  .take(visibleHeight)
                  .expand((row) => row)
                  .map((block) => block == null
                      ? const SizedBox()
                      : BlockRenderer(
                          block,
                          key: ValueKey(block),
                        ))
                  .toList());
          },
        ),
      ),
    );
  }
}
