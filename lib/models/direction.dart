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
}
