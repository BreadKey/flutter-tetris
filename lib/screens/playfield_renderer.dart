import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/block.dart';
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
          child: ChangeNotifierProvider<Tetris>.value(
            value: tetris,
            child: Consumer<Tetris>(
              builder: (context, value, child) => GridView.count(
                  crossAxisCount: playfieldWidth,
                  reverse: true,
                  children: tetris.playfield
                      .expand((row) => row)
                      .map((block) => Container(
                          key: block == null ? null : ValueKey(block),
                          decoration: getBlockDecoration(block)))
                      .toList()),
            ),
          ),
        ));
  }

  Decoration getBlockDecoration(Block block) {
    if (block == null)
      return null;
    else if (block.isGhost) {
      return BoxDecoration(color: block.color.withOpacity(0.25));
    } else {
      return BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: LinearGradient(
            colors: [
              block.color[200],
              block.color[500],
              block.color[600],
              block.color[900],
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ));
    }
  }

  Color getBlockColor(Block block) {
    if (block == null) return null;

    if (block.isGhost) {
      return block.color.withOpacity(0.5);
    } else {
      return block.color;
    }
  }
}
