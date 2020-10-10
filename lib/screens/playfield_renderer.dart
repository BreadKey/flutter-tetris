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
          child: ChangeNotifierProvider<Tetris>.value(
            value: tetris,
            child: Consumer<Tetris>(
              builder: (context, value, child) => GridView.count(
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
                      .toList()),
            ),
          ),
        ));
  }
}
