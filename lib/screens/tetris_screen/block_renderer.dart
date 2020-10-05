import 'package:flutter/material.dart';
import 'package:tetris/models/tetris.dart';

class BlockRenderer extends StatelessWidget {
  final Block block;

  const BlockRenderer(this.block, {Key key})
      : assert(block != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(0.25),
        decoration: getBlockDecoration(),
      );

  Decoration getBlockDecoration() {
    return BoxDecoration(color: getBlockColor());
  }

  Color getBlockColor() {
    if (block.isGhost) {
      return block.color.withOpacity(0.5);
    } else {
      return block.color;
    }
  }
}
