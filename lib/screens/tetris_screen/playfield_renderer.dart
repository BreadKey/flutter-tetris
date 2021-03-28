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
          child: GridView.count(
              crossAxisCount: playfieldWidth,
              reverse: true,
              children: List.generate(visibleHeight, (y) => y)
                  .expand((y) => List.generate(playfieldWidth, (x) {
                        Color lastColor;
                        return Selector<Tetris, Block>(
                          selector: (_, tetris) => tetris.getBlockAt(x, y),
                          shouldRebuild: (previous, next) =>
                              (previous != next) || lastColor != next?.color,
                          builder: (_, block, __) {
                            lastColor = block?.color;
                            return block == null
                                ? const SizedBox()
                                : BlockRenderer(
                                    block,
                                    key: ValueKey(block),
                                  );
                          },
                        );
                      }))
                  .toList())),
    );
  }
}
