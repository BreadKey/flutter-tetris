import 'dart:math';

enum Direction { up, down, left, right }

extension DirectionVector on Direction {
  Point<int> get vector {
    switch (this) {
      case Direction.up:
        return Point(0, 1);
      case Direction.down:
        return Point(0, -1);
      case Direction.left:
        return Point(-1, 0);
      case Direction.right:
        return Point(1, 0);
    }
  }

  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }

  bool get isHorizontal => this == Direction.left || this == Direction.right;
}
