import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/rules.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/block_renderer.dart';

class PlayfieldRenderer extends StatelessWidget {
  final Tetris tetris;
  const PlayfieldRenderer(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AspectRatio(
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
                        .map((block) => block == null
                            ? const SizedBox()
                            : BlockRenderer(
                                block,
                                key: ValueKey(block),
                              ))
                        .toList()),
              ),
            ),
          )),
    );
  }
}
