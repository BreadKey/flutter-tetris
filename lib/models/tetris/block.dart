part of '../tetris.dart';

class Block {
  Point<int> point;
  MaterialColor color;
  final bool isGhost;

  Block({@required this.color, this.point, this.isGhost: false})
      : assert(color != null);

  bool isPartOf(Tetromino tetromino) => tetromino.blocks.contains(this);
}
