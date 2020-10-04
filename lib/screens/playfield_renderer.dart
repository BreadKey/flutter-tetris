import 'package:flutter/material.dart';
import 'package:tetris/models/rules.dart';
import 'package:tetris/models/tetris.dart';

class PlayfieldRenderer extends StatelessWidget {
  final Tetris tetris;
  const PlayfieldRenderer(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: playfieldWidth / visibleHeight,
      child: Container(
        color: Colors.black,
        child: GridView.count(
            crossAxisCount: playfieldWidth,
            reverse: true,
            children: tetris.playfield
                .expand((row) => row)
                .map((block) => Container(
                      key: block == null ? null : ValueKey(block),
                      color: block?.color,
                    ))
                .toList()),
      ),
    );
  }
}
