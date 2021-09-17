part of tetris;

class Block {
  Point<int> point;
  MaterialColor color;
  bool isGhost;

  Block({required this.color, this.point = Point.zero, this.isGhost: false});

  bool isPartOf(Tetromino tetromino) => tetromino.blocks.contains(this);
}
