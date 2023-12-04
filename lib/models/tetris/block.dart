part of tetris;

class Block {
  Point<int> point;
  MaterialColor color;
  bool isGhost;

  Block({required this.color, this.point = const Point<int>(0, 0), this.isGhost = false});

  bool isPartOf(Tetromino tetromino) => tetromino.blocks.contains(this);
}
